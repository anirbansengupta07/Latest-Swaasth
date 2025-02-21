//
//  PrescriptionModel.swift
//  HMS
//


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct PrescriptionModel: Codable, Identifiable {
    var id: String
    let doctorId: String
    let patentId: String
    var appointmentID: String
    var prescription: String
    var patientStatus: String
    var description: String
    var referedDoctorId: String?
    var prescribedMedicines: [String: MedicineDetails]
    var prescribedTest: [String]?
    var isAdmitted: Bool
    
    struct MedicineDetails: Codable {
        let dosage: String
        let intakePattern: [IntakeTime]
        let beforeFood: Bool
        let afterFood: Bool
    }
    
    enum IntakeTime: String, Codable {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case night = "Night"
    }

    // Initializer to decode from Firestore dictionary
    init?(dictionary: [String: Any], id: String) {
        guard let doctorId = dictionary["doctorId"] as? String,
              let patentId = dictionary["patentId"] as? String,
              let appointmentID = dictionary["appointmentID"] as? String,
              let prescription = dictionary["prescription"] as? String,
              let patientStatus = dictionary["patientStatus"] as? String,
              let description = dictionary["description"] as? String,
              let isAdmitted = dictionary["isAdmitted"] as? Bool,
              let prescribedMedicinesDict = dictionary["prescribedMedicines"] as? [String: Any] else {
            // Return nil if any required field is missing
            return nil
        }

        var prescribedMedicines = [String: MedicineDetails]()
        for (medicineName, medicineDetailsDict) in prescribedMedicinesDict {
            guard let detailsDict = medicineDetailsDict as? [String: Any],
                  let dosage = detailsDict["dosage"] as? String,
                  let intakePatternRaw = detailsDict["intakePattern"] as? [String],
                  let beforeFood = detailsDict["beforeFood"] as? Bool,
                  let afterFood = detailsDict["afterFood"] as? Bool else {
                continue
            }

            let intakePattern: [IntakeTime] = intakePatternRaw.compactMap { IntakeTime(rawValue: $0) }
            let medicineDetails = MedicineDetails(dosage: dosage, intakePattern: intakePattern, beforeFood: beforeFood, afterFood: afterFood)
            prescribedMedicines[medicineName] = medicineDetails
        }

        let prescribedTest = dictionary["prescribedTest"] as? [String]
        let referedDoctorId = dictionary["referedDoctorId"] as? String

        self.id = id
        self.doctorId = doctorId
        self.patentId = patentId
        self.appointmentID = appointmentID
        self.prescription = prescription
        self.patientStatus = patientStatus
        self.description = description
        self.referedDoctorId = referedDoctorId
        self.prescribedMedicines = prescribedMedicines
        self.prescribedTest = prescribedTest
        self.isAdmitted = isAdmitted
    }
}


final class PrescriptionManager {
    static let shared = PrescriptionManager()
    private init() {}
    
    private let prescriptionCollection = Firestore.firestore().collection("prescriptions")
    
    private func prescriptionDocument(id: String) -> DocumentReference {
        prescriptionCollection.document(id)
    }
    
//    func addPatientRecord(patientId: String, doctorId: String, prescriptionData: PrescriptionModel) {
//        do {
//            
//            let id = UUID()
//            var prescriptionDataWithSameID = prescriptionData
//            prescriptionDataWithSameID.id = id
//            let data = try Firestore.Encoder().encode(prescriptionDataWithSameID)
//            let documentRef = prescriptionDocument(id: id.uuidString)
//            
//            documentRef.setData(data) { error in
//                if let error = error {
//                    print("Error adding document: \(error)")
//                } else {
//                    print("Document added successfully")
//                }
//            }
//        } catch {
//            print("Error encoding prescription data: \(error)")
//        }
//    }
    

    func addPatientRecord(patientId: String, doctorId: String, prescriptionData: PrescriptionModel) {
        do {
            let id = UUID().uuidString // Generate a UUID string
            var prescriptionDataWithSameID = prescriptionData
            prescriptionDataWithSameID.id = id
            
            let data = try Firestore.Encoder().encode(prescriptionDataWithSameID)
            let documentRef = Firestore.firestore().collection("prescriptions").document(id) // Assuming "prescriptions" is your Firestore collection
            
            documentRef.setData(data) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added successfully")
                }
            }
        } catch {
            print("Error encoding prescription data: \(error)")
        }
    }



    
    func editPatientRecord(patientId: String, doctorId: String, updatedPrescriptionData: PrescriptionModel) {
        do {
            let updatedData = try Firestore.Encoder().encode(updatedPrescriptionData)
            
            prescriptionCollection.document(patientId).updateData(updatedData) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document updated successfully")
                }
            }
        } catch {
            print("Error encoding updated prescription data: \(error)")
        }
    }
    
//    func getPrescriptionData(patientId: String) async throws -> PrescriptionModel? {
//        do {
//            let document = try await prescriptionCollection.document(patientId).getDocument()
//            guard let data = document.data() else {
//                // Document does not exist or does not contain any data
//                return nil
//            }
//            let prescriptionData = try Firestore.Decoder().decode(PrescriptionModel.self, from: data)
//            return prescriptionData
//        } catch {
//            // Handle any errors that occur during fetching
//            throw error
//        }
//    }
//    
//    func getPrescriptionThroughAppointmentId(appointmentID: String) async throws -> PrescriptionModel? {
//        do {
//            let querySnapshot = try await prescriptionCollection.whereField("appointmentID", isEqualTo: appointmentID).getDocuments()
//            guard let document = querySnapshot.documents.first else {
//                return nil
//            }
//            let prescriptionData = try Firestore.Decoder().decode(PrescriptionModel.self, from: document.data())
//            return prescriptionData
//        } catch {
//            throw error
//        }
//    }
    
}


@MainActor
final class PrescriptionViewModel: ObservableObject {
    
    @Published var currentUser: User?
    @Published var prescriptionDataFromAppointment: PrescriptionModel?
        
    init() {
        
        self.prescriptionDataFromAppointment = nil
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        if let currentUser = Auth.auth().currentUser {
            self.currentUser = currentUser
        } else {
            // No user is signed in.
            print("No user is signed in.")
        }
    }
    
//    func addPatientRecord(patientId: String, prescriptionData: PrescriptionModel) {
//        guard let currentUserID = currentUser?.uid else {
//            print("Current user ID not available.")
//            return
//        }
//        PrescriptionManager.shared.addPatientRecord(patientId: patientId, doctorId: currentUserID, prescriptionData: prescriptionData)
//    }
    
//    
//    func fetchPrescriptionThroughAppointmentID(appointmentID: String) async {
//            do {
//                if let prescriptionData = try await PrescriptionManager.shared.getPrescriptionThroughAppointmentId(appointmentID: appointmentID) {
//                    self.prescriptionDataFromAppointment = prescriptionData
//                    print(prescriptionData)
//                    
//                } else {
//                    // Handle the case when no prescription data is available for the appointmentID
//                    print("No prescription data available for appointmentID: \(appointmentID)")
//                }
//                
//            } catch {
//                print("Error fetching prescription data: \(error)")
//                // Handle error
//            }
//        
//        }

}
