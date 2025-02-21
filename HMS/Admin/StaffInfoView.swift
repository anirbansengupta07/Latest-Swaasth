import SwiftUI
import Firebase
import FirebaseStorage

struct StaffInfoView: View {
    @State private var searchText = ""
    @State private var staffData: [DoctorModel] = []
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack{
                    SearchBar(text: $searchText, placeHolder: "Search Doctor") // Search bar inside VStack
                                        .padding(.leading, 20)
                    NavigationLink(destination: DAddView(), label: {
                        Image(systemName: "plus")
                            .font(.title)
                    })
                    .padding(.trailing, 17)
                    
                }
                List {
                    ForEach(filteredStaff) { staff in
                        NavigationLink(destination: DoctorProfileView(doctor: staff)) {
                            HStack {

                                if let url = URL(string: staff.image) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().clipShape(Circle()).frame(width: 100, height: 100)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 150)
                                    .clipped()
                                    .cornerRadius(10)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(staff.name)
                                        .fontWeight(.bold)
                                    Text(staff.specialisation)
                                        .foregroundColor(.gray)
                                    Text("Employee Id: \(staff.employeeID)")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }

                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete") {
                            // Action to delete the item
                        }
                        .tint(.red)
                    }
                }
//                .searchable(text: $searchText)
                .refreshable {
                    await refreshData()
                }
                .navigationTitle("Staff info")
            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: DAddView(), label: {
//                        Image(systemName: "plus")
//                            .font(.title)
//                    })
//                }
//            }
            .onAppear {
                Task {
                    staffData = await fetchAllDoctors()
                }
            }
        }
    }
    
    private var filteredStaff: [DoctorModel] {
        if searchText.isEmpty {
            return staffData
        } else {
            return staffData.filter { staff in
                staff.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func refreshData() async {
        isRefreshing = true
        staffData = await fetchAllDoctors()
        isRefreshing = false
    }
    
    func fetchAllDoctors() async -> [DoctorModel] {
        let db = Firestore.firestore()
        do {
            let querySnapshot = try await db.collection("doctors").getDocuments()
            var doctors: [DoctorModel] = []
            for document in querySnapshot.documents {
                let data = document.data()
                let doctor = DoctorModel(from: data, id: document.documentID)
                doctors.append(doctor)
            }
            return doctors
        } catch {
            print("Error fetching doctors: \(error.localizedDescription)")
            return []
        }
    }
}

// Preview
struct StaffInfoView_Previews: PreviewProvider {
    static var previews: some View {
        StaffInfoView()
    }
}
