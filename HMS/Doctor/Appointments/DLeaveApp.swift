import SwiftUI
import Firebase

struct DLeaveAppView: View {
    @EnvironmentObject var userTypeManager: UserTypeManager
    @State private var showAlert = false
    var DocID: String
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var reason = ""
    @State private var selectedSlots: [String] = []
    @State private var leaveSlots: [String] = [] // Initialize as empty
    let gridItems = Array(repeating: GridItem(.flexible()), count: 3)
    let times = ["9:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"]
   
    var body: some View {
        NavigationStack{
        ScrollView {
            Text("Leave Application")
                .font(.largeTitle)
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .foregroundColor(Color.blueShade.opacity(0.1))
                        .shadow(radius: 5)
                        .frame(width: 400, height: 150)
                    
                    VStack {
                        HStack {
                            Text("Start date")
                                .foregroundColor(.black)
                                .font(.headline)
                                .padding(.leading, 25)
                            
                            Spacer()
                            
                            DatePicker("", selection: $startDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .padding(.trailing, 25)
                                .onChange(of: startDate) { newStartDate in
                                    if newStartDate > endDate {
                                        endDate = newStartDate
                                        fetchAppointments(for: newStartDate)
                                    }
                                }
                        }
                        
                        HStack {
                            Text("End date")
                                .foregroundColor(.black)
                                .font(.headline)
                                .padding(.leading, 25)
                            
                            Spacer()
                            
                            DatePicker("", selection: $endDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .padding(.trailing, 25)
                                .onChange(of: endDate) { newEndDate in
                                    if newEndDate < startDate {
                                        startDate = newEndDate
                                        fetchAppointments(for: startDate)
                                    }
                                }
                        }
                    }
                }
                
                Text("Why are you taking a leave?")
                    .font (.title3)
                    .fontWeight (.semibold)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .foregroundColor(Color.blueShade.opacity(0.1))
                        .shadow(radius: 5)
                        .frame(width: 400, height: 55)
                    
                    TextField("reason", text: $reason)
                        .frame(height: 40)
                        .padding()
                        .cornerRadius(11)
                }
                
                if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11)
                            .fill(Color(hex: "f5f5f5"))
                            .frame(width: 360, height: 200)
                        
                        LazyVGrid(columns: gridItems, spacing: 10) {
                            ForEach(times, id: \.self) { time in
                                LeaveButton(time: time, bookedSlots: leaveSlots, selectedDate: startDate, selectedSlots: $selectedSlots)
                                    .onTapGesture {
                                        if let index = selectedSlots.firstIndex(of: time) {
                                            selectedSlots.remove(at: index)
                                        } else {
                                            selectedSlots.append(time)
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
                
                Button(action: {
                    if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
                        createOneDayLeave()
                    } else {
                        createMultipleDayLeave()
                    }
                    showAlert=true
                    
                }) {
                    Text("Submit")
                        .font(.title3.bold())
                        .padding() // Add padding around the text
                        .foregroundColor(.white) // Set text color
                        .background(Color.customBlue) // Set background color
                        .cornerRadius(11) // Apply corner radius to create rounded corners
                        .frame(width: 200, height: 100)
                }
            }
            .padding()
            
            
        }.onAppear {
            print(DocID)
            fetchAppointments(for: startDate)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Leave Submitted!"),
                message: Text("Leave submitted successfully"),
                dismissButton: .default(
                    Text("OK")
                    
                )
            )
        }
    }
        
        
        
    }
    
    func createOneDayLeave() {
        let db = Firestore.firestore()
        let appointmentsRef = db.collection("appointments")
        let alertsRef = db.collection("Alerts")
        let formattedDate = startDate.formatted(date: .numeric, time: .omitted)

        for selectedSlot in selectedSlots {
            // Check if there's already an appointment for this date and slot
            appointmentsRef
                .whereField("DocID", isEqualTo: DocID)
                .whereField("Date", isEqualTo: formattedDate)
                .whereField("TimeSlot", isEqualTo: selectedSlot)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error checking appointments: \(error.localizedDescription)")
                        return
                    }

                    if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                        // Move existing appointments to the Alerts collection
                        for document in querySnapshot.documents {
                            let data = document.data()
                            alertsRef.addDocument(data: [
                                "PatID": data["PatID"] as? String ?? "Unknown",
                                "DocID": data["DocID"] as? String ?? "Unknown",
                                "Date": data["Date"] as? String ?? formattedDate,
                                "TimeSlot": data["TimeSlot"] as? String ?? selectedSlot,
                                "reason": "Doctor is on leave"
                            ])
                            // Delete the conflicting appointment
                            appointmentsRef.document(document.documentID).delete()
                        }
                    }

                    // Create the new leave appointment
                    let appointmentData: [String: Any] = [
                        "Bill": 0,
                        "Date": formattedDate,
                        "DocID": DocID,
                        "PatID": "Leave",
                        "TimeSlot": selectedSlot,
                        "isComplete": false,
                        "reason": reason
                    ]

                    appointmentsRef.addDocument(data: appointmentData) { error in
                        if let error = error {
                            print("Error creating leave booking: \(error.localizedDescription)")
                        } else {
                            print("Leave booking created successfully for \(selectedSlot) on \(formattedDate)")
                        }
                    }
                }
        }
    }
    
    func createMultipleDayLeave() {
        let db = Firestore.firestore()
        let appointmentsRef = db.collection("appointments")
        let alertsRef = db.collection("Alerts")
        var currentDate = startDate

        while currentDate <= endDate {
            let formattedDate = currentDate.formatted(date: .numeric, time: .omitted)

            for selectedSlot in times {
                // Check if there's already an appointment for this date and slot
                appointmentsRef
                    .whereField("DocID", isEqualTo: DocID)
                    .whereField("Date", isEqualTo: formattedDate)
                    .whereField("TimeSlot", isEqualTo: selectedSlot)
                    .getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error checking appointments: \(error.localizedDescription)")
                            return
                        }

                        if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                            // Move existing appointments to the Alerts collection
                            for document in querySnapshot.documents {
                                let data = document.data()
                                alertsRef.addDocument(data: [
                                    "PatID": data["PatID"] as? String ?? "Unknown",
                                    "DocID": data["DocID"] as? String ?? "Unknown",
                                    "Date": data["Date"] as? String ?? formattedDate,
                                    "TimeSlot": data["TimeSlot"] as? String ?? selectedSlot,
                                    "reason": "Doctor is on leave"
                                ])
                                // Delete the conflicting appointment
                                appointmentsRef.document(document.documentID).delete()
                            }
                        }

                        // Create the new leave appointment
                        let appointmentData: [String: Any] = [
                            "Bill": 0,
                            "Date": formattedDate,
                            "DocID": DocID,
                            "PatID": "Leave",
                            "TimeSlot": selectedSlot,
                            "isComplete": false,
                            "reason": reason
                        ]

                        appointmentsRef.addDocument(data: appointmentData) { error in
                            if let error = error {
                                print("Error creating leave booking: \(error.localizedDescription)")
                            } else {
                                print("Leave booking created successfully for \(selectedSlot) on \(formattedDate)")
                            }
                        }
                    }
            }

            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
    }

    func fetchAppointments(for date: Date) {
        let db = Firestore.firestore()
        let appointmentsRef = db.collection("appointments")
        let formattedDate = date.formatted(date: .numeric, time: .omitted)
        
        appointmentsRef
            .whereField("DocID", isEqualTo: DocID)
            .whereField("Date", isEqualTo: formattedDate)
            .whereField("PatID", isEqualTo: "Leave")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting appointments: \(error.localizedDescription)")
                } else if let querySnapshot = querySnapshot {
                    leaveSlots = querySnapshot.documents.compactMap { $0.data()["TimeSlot"] as? String }
                }
            }
    }
}

struct LeaveButton: View {
    var time: String
    var bookedSlots: [String]
    var selectedDate: Date
    @Binding var selectedSlots: [String]
    @State private var showEditSheet: Bool = false
    let currentTime = Calendar.current.dateComponents([.hour, .minute], from: Date())
    
    var body: some View {
        let isBooked = bookedSlots.contains(time)
        let isSelected = selectedSlots.contains(time)
        let isPastSlot = !isFutureTimeSlot(time)
        let isSelectable = !isBooked && !isPastSlot
        
        Button(action: {
            if isSelectable {
                if let index = selectedSlots.firstIndex(of: time) {
                    selectedSlots.remove(at: index)
                } else {
                    selectedSlots.append(time)
                }
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
                .disabled(!isSelectable)
        }
        .frame(width: 90, height: 50)
    }
    
    func isFutureTimeSlot(_ time: String) -> Bool {
        let slotComponents = time.components(separatedBy: ":")
        guard let hour = Int(slotComponents[0]), let minute = Int(slotComponents[1]) else {
            return false
        }
        
        let calendar = Calendar.current
        let slotDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: selectedDate)!
        
        return slotDate > Date()
    }
}

