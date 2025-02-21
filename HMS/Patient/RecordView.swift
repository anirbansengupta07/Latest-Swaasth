//
//  RecordView.swift
//  HMS
//


import SwiftUI
import Firebase
import FirebaseStorage
import MobileCoreServices
import QuickLook
import PDFKit

struct HealthRecordAdd: View {
    @EnvironmentObject var userTypeManager: UserTypeManager
    @State private var healthRecordPDFData: Data? = nil
    @State private var selectedPDFName: String? = nil
    @State private var isDocumentPickerPresented = false
    @State private var uploadProgress: Double = 0.0
    @State private var isUploading: Bool = false
    @State private var uploadedDocuments: [StorageReference] = []
    @State private var searchText = ""
    @State private var isPDFLoading = false
    @State private var isPreviewPresented = false
    @State private var previewURL: URL?

    private func handlePDFSelection(result: Result<[URL], Error>) {
        if case let .success(urls) = result, let url = urls.first {
            do {
                let pdfData = try Data(contentsOf: url)
                healthRecordPDFData = pdfData
                selectedPDFName = url.lastPathComponent
                uploadPDFToFirebase()
            } catch {
                print("Error converting PDF to data: \(error)")
            }
        }
    }
    var body: some View {
        ZStack{
            NavigationView {
                VStack {
                    VStack{
                        Section{
                          ForEach(uploadedDocuments.indices, id: \.self) { index in
                            let documentRef = uploadedDocuments[index]
                            if searchText.isEmpty || documentRef.name.lowercased().contains(searchText.lowercased()) {
                                HStack {
                                    Button(action: {
                                        viewDocument(documentRef: documentRef)
                                    }) {
                                        Text(documentRef.name)
                                    }
                                    Spacer()
                                    Image(systemName: "square.and.arrow.down")
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color.blue)
                                        .onTapGesture {
                                            downloadDocument(documentRef: documentRef)
                                        }
                                    Image(systemName: "trash")
                                        .foregroundColor(Color.red)
                                        .onTapGesture {
                                            deleteDocument(at: index)
                                        }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .listRowBackground(Color.white)}
                    Spacer()
                    VStack{
                        Section{
                        Button(action: {
                            isDocumentPickerPresented.toggle()
                        }) {
                            Text("Upload Record").padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blueShade.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    }.padding(.horizontal)

                }
                
                .background(Color.clear)
                .sheet(isPresented: $isDocumentPickerPresented) {
                    DocumentPicker { urls in
                        handlePDFSelection(result: .success(urls))
                    }
                }
                .navigationTitle("Health Records")
                
            }
          
            .scrollContentBackground(.hidden)
            .onAppear {
                fetchUploadedDocuments()
            }
            .sheet(isPresented: $isPreviewPresented) {
                if let previewURL = previewURL, let pdfDocument = PDFDocument(url: previewURL) {
                    PDFPreviewView(pdfDocument: pdfDocument)
                } else {
                    Text("Error displaying PDF")
                }
            }

            if isPDFLoading { // Show loading animation if PDF is loading
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .foregroundColor(.blue)
            }
        }
   
    }

    func uploadPDFToFirebase() {
        guard let pdfData = healthRecordPDFData else {
            print("No PDF data to upload")
            return
        }
        
        isUploading = true
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let documentUUID = userTypeManager.userID
        let pdf = selectedPDFName ?? ""
        let pdfRef = storageRef.child("health_records/\(documentUUID)/\(pdf)")
        
        pdfRef.putData(pdfData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading PDF: \(error.localizedDescription)")
            } else {
                print("PDF uploaded successfully")
                // Fetch the uploaded documents after successful upload
                fetchUploadedDocuments()
            }
            isUploading = false
        }
    }

    func fetchUploadedDocuments() {
        let storage = Storage.storage()
        let documentUUID = userTypeManager.userID
        let storageRef = storage.reference().child("health_records/\(documentUUID)")

        storageRef.listAll { result, error in
            if let error = error {
                print("Error fetching uploaded documents from Storage: \(error.localizedDescription)")
            } else {
                // Assign the list of StorageReferences to uploadedDocuments
                uploadedDocuments = result!.items
            }
        }
    }

    func viewDocument(documentRef: StorageReference) {
        documentRef.downloadURL { url, error in
            guard let downloadURL = url, error == nil else {
                print("Error getting document URL: \(error?.localizedDescription ?? "")")
                return
            }
            
            // Set isPDFLoading to true when starting to load PDF
            isPDFLoading = true

            // Perform asynchronous download using URLSession
            URLSession.shared.dataTask(with: downloadURL) { data, response, error in
                defer {
                    // Set isPDFLoading to false when PDF loading completes (whether successfully or with an error)
                    DispatchQueue.main.async {
                        isPDFLoading = false
                    }
                }
                guard let data = data, error == nil else {
                    print("Error downloading document: \(error?.localizedDescription ?? "")")
                    return
                }
                
                // Process downloaded data
                DispatchQueue.main.async {
                    if let pdfDocument = PDFDocument(data: data) {
                        // You can further customize the PDFView here (zoom, annotations etc.)
                        previewURL = downloadURL
                        isPreviewPresented = true
                    } else {
                        // Handle potential data error
                    }
                }
            }.resume()
        }
    }

    func downloadDocument(documentRef: StorageReference) {
        // Get the documents directory URL
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Generate a unique file name for the downloaded file
        let uniqueFilename = UUID().uuidString + ".pdf"
        let destinationURL = documentsDirectory.appendingPathComponent(uniqueFilename)
        
        // Download the document to the destination URL
        documentRef.write(toFile: destinationURL) { url, error in
            if let error = error {
                print("Error downloading document: \(error.localizedDescription)")
            } else if let url = url {
                print("Document downloaded successfully at: \(url)")
            }
        }
    }

    func deleteDocument(at index: Int) {
        guard index >= 0 && index < uploadedDocuments.count else {
            print("Invalid index")
            return
        }
        
        let documentRef = uploadedDocuments[index]
        
        // Delete the document from Firebase Storage
        documentRef.delete { error in
            if let error = error {
                print("Error deleting document from Firebase Storage: \(error.localizedDescription)")
            } else {
                print("Document deleted successfully from Firebase Storage")
                
                // Remove the deleted document from the uploadedDocuments array
                uploadedDocuments.remove(at: index)
            }
        }
    }

}

struct HealthRecordAdd_Previews: PreviewProvider {
    static var previews: some View {
        HealthRecordAdd()
    }
}

struct PDFPreviewView: View {
    let pdfDocument: PDFDocument

    var body: some View {
        ZStack {
            PDFKitRepresentedView(pdfDocument: pdfDocument)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true // Enable auto scaling
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // Update the view if needed
    }
}




