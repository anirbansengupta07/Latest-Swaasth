//
//  EmergencyModel.swift
//  HMS
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct EmergencyModel: Codable, Hashable {
    
    let patientId: String
    let latitude: String
    let longitude: String
    let timeStamp: Date
    
    init(patientId: String, latitude: String, longitude: String, timeStamp: Date) {
        self.patientId = patientId
        self.latitude = latitude
        self.longitude = longitude
        self.timeStamp = Date()
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.patientId = try container.decode(String.self, forKey: .patientId)
        self.latitude = try container.decode(String.self, forKey: .latitude)
        self.longitude = try container.decode(String.self, forKey: .longitude)
        self.timeStamp = try container.decode(Date.self , forKey: .timeStamp)
    }
    
    
    
}

final class EmergencyManager {
    static let shared = EmergencyManager()
    private init() {}
    
    private let emergenciesCollection = Firestore.firestore().collection("Emergency")
    
    func addEmergency(patientId: String, latitude: String, longitude: String) {
        let currentDate = Date()
        let emergencyData = EmergencyModel(patientId: patientId, latitude: latitude, longitude: longitude, timeStamp: currentDate)
            do {
                _ = try emergenciesCollection.addDocument(from: emergencyData)
                print(patientId)
            } catch {
                print("Error adding emergency data to Firestore: \(error)")
            }
        }
    
    func fetchEmergency(completion: @escaping ([EmergencyModel]?, Error?) -> Void) {
            emergenciesCollection.getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching emergency documents: \(error)")
                    completion(nil, error)
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    completion([], nil)
                    return
                }
                
                var emergencies: [EmergencyModel] = []
                for document in documents {
                    do {
                        if let emergency = try document.data(as: EmergencyModel?.self) {
                            emergencies.append(emergency)
                        }
                    } catch {
                        print("Error decoding emergency document: \(error)")
                    }
                }
                completion(emergencies, nil)
            }
        }
}

@MainActor
final class EmergencyViewModel: ObservableObject {
    
    private let emergencyManager = EmergencyManager.shared

    @Published private(set) var emergencies: [EmergencyModel] = []

    func getAllEmergencies() {
        emergencyManager.fetchEmergency { [weak self] emergencies, error in
            if let error = error {
                print("Error fetching emergencies: \(error)")
                return
            }

            guard let emergencies = emergencies else {
                print("No emergencies found")
                return
            }

            DispatchQueue.main.async {
                self?.emergencies = emergencies
            }
        }
    }
}

