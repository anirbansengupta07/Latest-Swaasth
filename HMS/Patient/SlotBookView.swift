import SwiftUI
import Firebase

struct TimeButton: View {
    var time: String
    var bookedSlots: [String]
    var selectedDate: Date // Add selectedDate as a parameter
    @Binding var selectedSlot: String?
    
    
    let currentTime = Calendar.current.dateComponents([.hour, .minute], from: Date())
    
    var body: some View {
        let isBooked = bookedSlots.contains(time)
        let isSelected = selectedSlot == time
        let isPastSlot = !isFutureTimeSlot(time)
        let isSelectable = !isBooked && !isPastSlot
        
        Button(action: {
            if isSelectable {
                selectedSlot = time
            }
        }) {
            RoundedRectangle(cornerRadius: 11)
                .fill(isBooked ? Color.white : (isSelected ? Color.customBlue : (isPastSlot ? Color.white : Color.white)))
                .overlay(
                    Text(time)
                        .font(.headline)
                        .foregroundColor(isBooked ? .gray : (isSelected ? .white :(isPastSlot ? Color.gray : Color.customBlue)))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(isBooked ? Color.gray : Color.customBlue, lineWidth: 1)
                )
                .opacity(isBooked ? 0.5 : 1.0)
                .disabled(!isSelectable) // Disable button if slot is booked or in the past
        }
        .frame(width: 90, height: 50)
    }
    
    // Function to check if the time slot is in the future
    func isFutureTimeSlot(_ time: String) -> Bool {
        let slotComponents = time.components(separatedBy: ":")
        guard let hour = Int(slotComponents[0]), let minute = Int(slotComponents[1]) else {
            return false
        }
        
        let calendar = Calendar.current
        let slotDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: selectedDate)!
        
        return slotDate > Date() // Compare slot's date with current date
    }
}



struct SlotBookView: View {
    @EnvironmentObject var userTypeManager: UserTypeManager
    
//    let appointments: AppointmentModel
    @State private var reason: String = ""

    let doctor: DoctorModel
    let gridItems = Array(repeating: GridItem(.flexible()), count: 3)
    let times = ["9:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"]
    
    @State private var bookedSlots: [String] = [] // Initialize as empty
    @State private var selectedSlot: String? = nil
    @State private var selectedDate = Date()
    @State private var paymentConfirmationActive = false // Flag to control navigation to PaymentConfirmationPage
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Choose your desired date format
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            ScrollView{
                Spacer()
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.customBlue.opacity(0.5), Color.customBlue.opacity(1)]),
                                startPoint: .leading,
                                endPoint: .trailing))
                            .frame(width: 361, height: 180)
                            .shadow(color: Color.black.opacity(0.15), radius: 20)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(doctor.name)
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(doctor.specialisation)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                
                                Text(doctor.degree)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                Text("Experience: \(doctor.experience) years")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            
                            if let url = URL(string: doctor.image) {
                                AsyncImage(url: url) { image in
                                    image.resizable().clipShape(RoundedRectangle(cornerRadius: 11.0 )).frame(width: 100, height: 120)
                                    
                                } placeholder: {
                                    ProgressView()
                                }
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 150)
                                .clipped()
                                .cornerRadius(10)
                            }
                        }
                        .padding(.leading, 30)
                        .padding(.trailing, 20)
                        Spacer()
                    }
                    .frame(width: 380, height: 200)
                    
                    Text("Appointment Date")
                        .font(.headline)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 11)
                            .fill(Color(hex: "f5f5f5"))
                            .frame(width: 360, height: 70)
                        
                        HStack {
                            Text("Select a date")
                                .foregroundColor(.black) // Set text color
                                .font(.headline) // Set font style
                                .padding(.leading, 25) // Adjust leading padding
                            
                            Spacer() // Add spacer to push DatePicker to the right
                            
                            DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .padding(.trailing, 25)
                        }
                    }
                    
                    Text("Select a Slot")
                        .font(.headline)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 11)
                            .fill(Color(hex: "f5f5f5"))
                            .frame(width: 360, height: 200)
                        
                        LazyVGrid(columns: gridItems, spacing: 10) {
                            ForEach(times, id: \.self) { time in
                                TimeButton(time: time, bookedSlots: bookedSlots, selectedDate: selectedDate, selectedSlot: $selectedSlot)
                            }
                        }
                        .padding()
                    }
                    
                    Text("Reason")
                        .font (.headline)
                    
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 11)
                            .foregroundColor(Color.blueShade.opacity(0.1))
                            .shadow(radius: 5)
                            .frame(width: 360, height: 55)
                        
                        TextField("Enter reason...", text: $reason)
                            .frame(height: 40)
                            .padding(.leading, 25)
                            .cornerRadius(11)
                    }
                    
                    
                    Button(action: {
                        // Action to perform when the book button is tapped
                        print(selectedDate.formatted(date: .numeric, time: .omitted) , selectedSlot!)
                        
                        guard let slot = selectedSlot else { return }
                        
                        paymentConfirmationActive = true
                    }) {
                        // Button label
                        Text("Book Slot")
                            .font(.title3.bold())
                            .padding() // Add padding around the text
                            .foregroundColor(.white) // Set text color
                            .background(Color.customBlue) // Set background color
                            .cornerRadius(11) // Apply corner radius to create rounded corners
                            .frame(width: 200,height: 100)
                    }
                    .disabled(selectedSlot == nil)
                    .padding(.top)
                    
                    NavigationLink(destination: CheckoutView(doctorName: doctor.name,selectedDate: selectedDate.formatted(date: .numeric, time: .omitted), selectedSlot: selectedSlot ?? "",Bill: 1000,
                                                             DocID: doctor.employeeID,
                                                             PatID: userTypeManager.userID,
                                                             reason: reason ), isActive: $paymentConfirmationActive) {
                        EmptyView()
                    }
                                                             .hidden()
                }
                .onAppear {
                    fetchAppointments()
                }
                .onChange(of: selectedDate) { _ in
                    fetchAppointments()
                }
                //.navigationBarTitle("Book Appointment", displayMode: .inline )
                .navigationBarTitleDisplayMode(.inline)
            }
            
        }
        .navigationTitle("Book Appointment")
    }
    
    func fetchAppointments() {
        let db = Firestore.firestore()
        let appointmentsRef = db.collection("appointments")
        let formattedDate = selectedDate.formatted(date: .numeric, time: .omitted)
        
        appointmentsRef
            .whereField("DocID", isEqualTo: doctor.employeeID)
            .whereField("Date", isEqualTo: formattedDate)
            .getDocuments {(querySnapshot, error) in
                if let error = error {
                    print("Error getting appointments: \(error.localizedDescription)")
                } else if let querySnapshot = querySnapshot {
                    // Clear out the old booked slots
                    bookedSlots.removeAll()
                    let slots = querySnapshot.documents.compactMap { $0.data()["TimeSlot"] as? String }
                    
                    DispatchQueue.main.async {
                        bookedSlots = slots
                    }
                }
            }
    }
}

//struct SlotBookView_Previews: PreviewProvider {
//    static var previews: some View {
//        let dummyDoctor = DoctorModel(
//            id: "1",
//            name: "Dr. Jane Doe",
//            department: "Cardiology",
//            email: "jane.doe@example.com",
//            contact: "1234567890",
//            experience: "10",
//            employeeID: "D0001",
//            image: "",
//            specialisation: "Cardiologist",
//            degree: "MD",
//            cabinNumber: "101"
//        )
//        
//        SlotBookView(doctor: dummyDoctor)
//    }
//}

extension Color {
    static let customColor = Color(hex: "#002D62")
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
