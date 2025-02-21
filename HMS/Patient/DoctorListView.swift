import SwiftUI
import Firebase

struct DoctorListView: View {
    @State private var isFiltering = false
    @State private var searchText = ""
    @State private var experienceFilter = 0
    @State private var selectedExperience: ClosedRange<Int>? = nil
    
    @State var doctors: [DoctorModel] = []

    var filteredDoctors: [DoctorModel] {
        var filtered = doctors
        
        // Apply search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Apply experience filter
        if let experienceRange = selectedExperience {
                    filtered = filtered.filter { Int($0.experience) ?? 0 >= experienceRange.lowerBound && Int($0.experience) ?? 0 <= experienceRange.upperBound }
                }
        
        return filtered
        
    }

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                SearchBar(text: $searchText, placeHolder: "Search Doctor")
                    .padding(.horizontal)
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(filteredDoctors) { doctor in
                            DoctorCardView(doctor: doctor)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("All Doctors")
            .navigationBarItems(leading:
               
                Button(action: {
                    isFiltering = true // Show the filtering modal sheet when button is clicked
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .imageScale(.large)
                        .foregroundColor(.customBlue)
                }
                                )
           
            .navigationBarItems(trailing:
                Button(action: {
                    // Clear all filters
                    searchText = ""
                    selectedExperience = nil
                }) {
                    Text("Clear Filters")
                        .foregroundColor(.customBlue)
                }
            )
            .sheet(isPresented: $isFiltering) {
                            // Modal sheet for filtering based on experience
                FilterExperienceView(isFiltering: $isFiltering, selectedExperience: $selectedExperience)
                        }
        }
        .onAppear {
            Task {
                doctors = await fetchAllDoctors()
            }
        }
        
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

struct DoctorCardView: View {
    let doctor: DoctorModel
    @State private var isFavorite = false
    @State private var showBookButton = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack{
                if let url = URL(string: doctor.image) {
                    AsyncImage(url: url) { image in
                        image.resizable().clipShape(Circle()).frame(width: 120, height: 120)
                                            .foregroundColor(.blueShade)
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(11)
                }

//                Image(systemName: "person.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 100, height: 120, alignment: .leading)
//                    .cornerRadius(10)
//                    .foregroundColor(.blueShade)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(doctor.name)
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
//                        if showBookButton {
//                            Button(action: {
//                                isFavorite.toggle()
//                            }) {
//                                Image(systemName: isFavorite ? "heart.fill" : "heart")
//                                    .foregroundColor(isFavorite ? .red : .gray)
//                            }
//                        }
                    }
                    
                    Text(doctor.specialisation)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    Text("\(doctor.experience) Years")
                        .font(.system(size: 15))
                    HStack{
                        NavigationLink(destination: DoctorProfileView(doctor:doctor)) {
                            Text("Details")
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.customBlue)
                                .cornerRadius(11)
                        }
                        Spacer()
                        NavigationLink(destination: SlotBookView(doctor:doctor)) {
                            Text("Book")
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.customBlue)
                                .cornerRadius(11)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blueShade.opacity(0.1))
        .cornerRadius(10)
//        .shadow(radius: 5)
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeHolder:String
    
    var body: some View {
        HStack {
            TextField(placeHolder, text: $text)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            Button(action: {
                self.text = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
        }
    }
}

struct FilterExperienceView: View {
    @Binding var isFiltering: Bool
    @Binding var selectedExperience: ClosedRange<Int>?
    @State private var isExperienceExpanded = false

    
    let experienceRanges: [ClosedRange<Int>] = [
        0...5,
        6...10,
        11...15,
        16...Int.max
    ]
    var body: some View {
        NavigationView {
            VStack {
                Text("Filter Based on Experience")
                    .font(.headline)
                    .padding()
                VStack {
                    Button(action: {
                        isExperienceExpanded.toggle()
                    }) {
                        HStack {
                            Text("Experience")
                                .foregroundColor(.customBlue)
                            Spacer()
                            Image(systemName: isExperienceExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.customBlue)
                        }
                        .padding()
                        .foregroundColor(.blue)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    if isExperienceExpanded {
                        Picker("Experience", selection: Binding<Int>(
                            get: {
                                if let selectedRange = selectedExperience {
                                    return experienceRanges.firstIndex(where: { $0 == selectedRange }) ?? 0
                                } else {
                                    return 0
                                }
                            },
                            set: { index in
                                if index == experienceRanges.count - 1 {
                                    selectedExperience = nil // For "20+ years" option
                                } else {
                                    selectedExperience = experienceRanges[index]
                                }
                            }
                        )) {
                            ForEach(experienceRanges.indices, id: \.self) { index in
                                let range = experienceRanges[index]
                                if range.upperBound == Int.max {
                                    Text("15+ Years").tag(index)
                                } else {
                                    Text("\(range.lowerBound)-\(range.upperBound) Years").tag(index)
                                }
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()

                    }
                }
                
                
                Spacer()
                
                Button(action: {
                    // Apply filtering
                    isFiltering = false
                }) {
                    Text("Apply Filter")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.customBlue)
                        .cornerRadius(11)
                }
                .padding()
            }
            .navigationTitle("Filter")
            .navigationBarItems(trailing:
                Button("Close") {
                    isFiltering = false // Close the modal sheet
                }
                .foregroundColor(.customBlue)
            )
        }
    }
}



// Update the preview provider if necessary
struct DoctorListView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorListView()
    }
}

// The SearchBar view remains unchanged, as it's just a UI element.
// ...
