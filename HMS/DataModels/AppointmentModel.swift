//
//  DataModel.swift
//  HMS
//


import Foundation

struct AppointmentModel: Identifiable {
    let id: String
    let doctorID: String
    let patientID: String
    let bill: Int
    let date: Date
    let timeSlot: String
    let isComplete: Bool
    let reason: String
    
    // Additional fields to store doctor's details after fetching
    var patientName: String?
    var doctorName: String?
    var doctorSpecialisation: String?
//    var pCont: String?
    // Any additional fields for doctor details here...

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy" // Adjust according to your needs
        return formatter.string(from: date)
    }

    // Initialize from a Firestore document
    init?(document: [String: Any], id: String) {
        guard let bill = document["Bill"] as? Int,
              let dateString = document["Date"] as? String,
              let timeSlot = document["TimeSlot"] as? String,
              let doctorID = document["DocID"] as? String,
              let patientID = document["PatID"] as? String,
              let isComplete = document["isComplete"] as? Bool,
              let reason = document["reason"] as? String,
              let date = DateFormatter.appointmentDateFormatter.date(from: dateString)
        else {
            return nil
        }
        
        self.id = id
        self.doctorID = doctorID
        self.patientID = patientID
        self.bill = bill
        self.date = date
        self.timeSlot = timeSlot
        self.isComplete = isComplete
        self.reason = reason
    }
    
    init(id:String,doctorID:String,patientID:String,bill: Int,
         date: Date,
         timeSlot: String,
         isComplete: Bool,
         reason: String,
         patientName: String,
         doctorName: String,
         pCont: String,
         doctorSpecialisation: String) {
        self.id = id
        self.doctorID = doctorID
        self.patientID = patientID
        self.bill = bill
        self.date = date
        self.timeSlot = timeSlot
        self.isComplete = isComplete
        self.reason = reason
        self.patientName = patientName
        self.doctorName = doctorName
//        self.pCont = pCont
        self.doctorSpecialisation = doctorSpecialisation
    }
    
    
    
}

