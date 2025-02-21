//
//  EventsModel.swift
//  HMS
//


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct HealthEvent: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var date: String
    var time: String
    var venue: String
    var imageName: String // Image name for the event
    var attendees: Int // Number of attendees
    
    init(from document: DocumentSnapshot) throws {
        guard let data = document.data() else {
            throw NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document data was empty."])
        }
        
        guard let id = document.documentID as? String else {
            throw NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document ID couldn't be cast to String."])
        }
        
        self.id = id
        self.title = data["title"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.date = data["date"] as? String ?? ""
        self.time = data["time"] as? String ?? ""
        self.venue = data["venue"] as? String ?? ""
        self.imageName = data["imageName"] as? String ?? ""
        self.attendees = data["attendees"] as? Int ?? 0
    }

    init(id: String, title: String, description: String, date: String, time: String, venue: String, imageName: String, attendees: Int = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.time = time
        self.venue = venue
        self.imageName = imageName
        self.attendees = attendees
    }
    
    
//    init(from decoder: any Decoder) throws {
//           let container = try decoder.container(keyedBy: CodingKeys.self)
//           self.id = try container.decode(String.self, forKey: .id)
//           self.title = try container.decode(String.self, forKey: .title)
//           self.description = try container.decode(String.self, forKey: .description)
//           self.date = try container.decode(String.self, forKey: .date)
//           self.time = try container.decode(String.self, forKey: .time)
//           self.venue = try container.decode(String.self, forKey: .venue)
//           self.imageName = try container.decode(String.self, forKey: .imageName)
//        self.attendees = try container.decode(Int.self, forKey: .attendees)
//       }
    
    
}

final class HealthEventsManager {
    static let shared = HealthEventsManager()
    private init() {}

    private let healthEvents = Firestore.firestore().collection("HealthEvents")

    private func healthDocument(id: String) -> DocumentReference {
        healthEvents.document(id)
    }

    func addHealthEvent(_ event: HealthEvent) {
        do {
            _ = try healthDocument(id: event.id).setData(from: event, merge: false)
        } catch {
            print("Error adding health event to Firestore: \(error)")
        }
    }

    func getAllHealthEvents(completion: @escaping ([HealthEvent]?) -> Void) {
        healthEvents.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting health events: \(error)")
                completion(nil)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents")
                completion(nil)
                return
            }
            
            let events = documents.compactMap { document -> HealthEvent? in
                do {
                    let event = try document.data(as: HealthEvent.self)
                    return event
                } catch {
                    print("Error decoding health event: \(error)")
                    return nil
                }
            }
            
            completion(events)
        }
    }
    
    func updateAttendees(eventId: String, newAttendeesCount: Int) {
        healthDocument(id: eventId).updateData(["attendees": newAttendeesCount]) { error in
            if let error = error {
                print("Error updating attendees count: \(error)")
            } else {
                print("Attendees count updated successfully for event \(eventId)")
            }
        }
    }
    func deleteParticularEvent(eventId: String) {
        healthEvents.document(eventId).delete() { error in
            if let error = error {
                print("Error deleting event: \(error)")
            } else {
                print("Event successfully deleted!")
                print(eventId)
            }
        }
    }

}

@MainActor
final class EventsViewModel: ObservableObject {
   
    @Published var events: [HealthEvent] = []
    
    func getAllEvents(){
        HealthEventsManager.shared.getAllHealthEvents { [weak self] fetchedEvents in
            if let fetchedEvents = fetchedEvents {
                // Update the events array on the main thread
                DispatchQueue.main.async {
                    self?.events = fetchedEvents
                }
            }
        }
    }
    
    func deleteEvent(eventId: String){
        HealthEventsManager.shared.deleteParticularEvent(eventId: eventId)
    }
}



