//
//  DAppointments.swift
//  HMS
//
//  Created by Sarthak 
//

import SwiftUI
import Firebase

struct DAppointments: View {
    @EnvironmentObject var userTypeManager: UserTypeManager
    @State private var doctor: DoctorModel?

    @State var storedAppointment: [AppointmentModel] = []
    
    @State var currentWeek: [Date] = []
    @State var currentDay: Date = Date()
    @State var filteredAppointment: [AppointmentModel]?
    @State var DocID = ""
    @StateObject var prescriptionViewModel = PrescriptionViewModel()
    @State private var showPrescriptionForm = false
    @Namespace var animation
    
    
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: false){
                
                LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]){
                    
                    Section{
                        
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 10){
                                
                                ForEach(currentWeek, id: \.self){ day in
                                    
                                    VStack(spacing: 10){
                                        
                                        Text(extractDate(date: day, format: "EEE"))
                                            .font(.system(size: 14))
                                            .fontWeight(.semibold)
                                        
                                        Text(extractDate(date: day, format: "dd"))
                                            .font(.system(size: 15))
                                            .fontWeight(.bold)
                                        
                                        Circle()
                                            .fill(.yellow)
                                            .frame(width: 8, height: 8)
                                            .opacity(isToday(date: day) ? 1 : 0)
                                        
                                    }
                                    .foregroundColor(isToday(date: day) ? .black : .customBlue)
                                    .frame(width: 45, height: 90)
//                                    .background(
//                                        ZStack{
//                                            if isToday(date: day){
//                                                Capsule()
//                                                    .fill(.black)
//                                                    .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
//                                            }
//                                        }
//                                    )
                                    .contentShape(Capsule())
                                    .onTapGesture {
                                        currentDay = day
                                    }
                                    
                                }
                                
                            }
                            .padding(.horizontal)
                        }
                        TasksView()
                        
                    } header: {
                        HeaderView()
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .top)
        }
        .onAppear{
            if !userTypeManager.userID.isEmpty {
                fetchDoctor()
                fetchCurrentWeek()
            }
        }
    }
    
    func fetchDoctor() {
            let db = Firestore.firestore()
            let doctorsRef = db.collection("doctors")
            doctorsRef
                .whereField("authID", isEqualTo: userTypeManager.userID)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting doctor: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty,
                          let document = querySnapshot.documents.first else {
                        print("No documents or doctor fetched")
                        return
                    }
                    
                    let doctorData = document.data()
                    let fetchedDoctor = DoctorModel(from: doctorData, id: document.documentID)
                    DispatchQueue.main.async {
                        self.doctor = fetchedDoctor
                        print("Fetched Doctor ID: \(fetchedDoctor.employeeID)")
                        fetchAppointments()
                    }
                }
        }
    
    func fetchAppointments() {
        let db = Firestore.firestore()
        let appointmentsRef = db.collection("appointments")
        appointmentsRef
            .whereField("DocID", isEqualTo: doctor?.employeeID)
            .getDocuments {(querySnapshot, error) in
                if let error = error {
                    print("Error getting appointments: \(error.localizedDescription)")
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    print("No documents fetched")
                    return
                }
                
                var fetchedAppointments: [AppointmentModel] = []
                for document in querySnapshot.documents {
                    if let appointment = AppointmentModel(document: document.data(), id: document.documentID) {
                        fetchedAppointments.append(appointment)
                    }
                }
                
                DispatchQueue.main.async {
                    storedAppointment = fetchedAppointments
                    filterTodayAppointments()
                }
            }
    }
    
    func TasksView() -> some View{
        LazyVStack(spacing: 18){
            if let appointments = filteredAppointment{
                if appointments.isEmpty{
                    Text("No Appoinments!!!")
                        .font(.system(size: 16))
                        .fontWeight(.light)
                        .offset(y: 100)
                }
                else{
                    ForEach(appointments){ appointment in
                        NavigationLink {
                            AddPrescriptionForm(patientId: appointment.patientID, appointmentID: appointment.id)
                                    } label: {
                                        AppointmentCardView(appointment: appointment)
                                    }
                    }
                }
            }
            else{
                ProgressView()
                    .offset(y: 100)
            }
        }
        .padding()
        .padding(.top)
        .onChange(of: currentDay){ newValue in
            fetchAppointments()
            
        }
    }

    struct AppointmentCardView: View {
        var appointment: AppointmentModel
        @State private var pName: String = "Loading..."

        var body: some View {
            HStack(alignment: .top, spacing: 30) {
                VStack(spacing: 10) {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 15, height: 15)
                        .background(
                            Circle()
                                .stroke(Color.black, lineWidth: 1)
                                .padding(-3)
                        )
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 3)
                }
                
                VStack {
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 12) {
                            if appointment.patientID == "Leave"{
                                Text("Leave")
                                    .font(.title2.bold())
                            }else{
                                Text(pName)
                                    .font(.title2.bold())
                            }
                            Text(appointment.reason)
                                .font(.title3)
                        }
                        .hLeading()
                        
                        Text(appointment.timeSlot)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .hLeading()
                .background(
                    Color.customBlue
                        .cornerRadius(25)
                )
            }
            .hLeading()
            .onAppear{
                fetchPName()
            }
        }
        private func fetchPName() {
            let db = Firestore.firestore()
            let documentID = appointment.patientID
            db.collection("Patients").document(documentID).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    if let patientName = data?["name"] as? String {
                        print("Patient Name: \(patientName)")
                        pName = patientName
                    } else {
                        print("Patient name not found in the document.")
                    }
                } else {
                    print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

    
    func HeaderView() -> some View {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.gray)
                    
                    Text("Today")
                        .font(.largeTitle.bold())
                }
                .hLeading()
                
                NavigationLink(destination: DLeaveAppView(DocID: doctor?.employeeID ?? "")) {
                    Text("Leave")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 30)
                        .background(Color.customBlue)
                        .cornerRadius(11)
                }
            }
            .padding()
            .padding(.top, getSafeArea().top)
            .background(Color.white)
        }
    
    func filterTodayAppointments() {
        DispatchQueue.global(qos: .userInteractive).async {
            let calendar = Calendar.current
            // Ensure that we compare only the date components (Year, Month, Day)
            let todayStart = calendar.startOfDay(for: self.currentDay)

            let filtered = self.storedAppointment.filter { appointment in
                let appointmentDay = calendar.startOfDay(for: appointment.date)
                return appointmentDay == todayStart
            }

            DispatchQueue.main.async {
                withAnimation {
                    self.filteredAppointment = filtered
                    print("Filtered Appointments: \(self.filteredAppointment?.count ?? 0)")
                }
            }
        }
    }


    
    func fetchCurrentWeek(){
        let today = Date()
        let calendar = Calendar.current
       
        
        
        let week = calendar.dateInterval(of: .weekOfMonth, for: today)
        guard let firstWeekDay = week?.start else{
             return
         }
         // Iterating to get the full week
        (0..<100).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                currentWeek.append(weekday)
            }
        }

    }
    
    func extractDate(date: Date, format: String) -> String{
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    func isToday(date: Date) -> Bool{
        let calendar = Calendar.current
        
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
}

extension View{
    func hLeading() -> some View{
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func hTrailing() -> some View{
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    func hCenter() -> some View{
        self
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func getSafeArea() -> UIEdgeInsets{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .zero
        }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else{
            return .zero
        }
        return safeArea
    }
}

#Preview {
    DAppointments()
}
