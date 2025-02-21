//
//  health-events.swift
//  HMS
//
//  Created by Protyush Kundu on 29/04/24.
//

import SwiftUI

// Model to represent a health event
struct HealthEvent {
    var title: String
    var date: String
    var time: String
    var venue: String
    var imageName: String // Image name for the event
}

// Sample data for demonstration
let sampleEvents: [HealthEvent] = [
    HealthEvent(title: "Fitness Workshop", date: "May 10, 2024", time: "10:00 AM - 12:00 PM", venue: "Fitness Center", imageName: "fitness_workshop"),
    HealthEvent(title: "Nutrition Seminar", date: "May 15, 2024", time: "2:00 PM - 4:00 PM", venue: "Conference Room", imageName: "nutrition_seminar"),
    HealthEvent(title: "Mental Health Awareness Session", date: "May 20, 2024", time: "3:00 PM - 5:00 PM", venue: "Auditorium", imageName: "mental_health_session"),
    HealthEvent(title: "Yoga Retreat", date: "May 25, 2024", time: "8:00 AM - 10:00 AM", venue: "Outdoor Park", imageName: "yoga_retreat")
]

struct HealthEventsView: View {
    var events: [HealthEvent]
    
    var body: some View {
        NavigationView {
            List(events, id: \.title) { event in
                VStack(alignment: .leading, spacing: 8) {
                    Image(event.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(10)
                    
                    Text(event.title)
                        .font(.headline)
                    Text("Date: \(event.date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Time: \(event.time)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Venue: \(event.venue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        // Add action for attending the event
                        print("Attending \(event.title)")
                    }) {
                        Text("Attend")
                            .font(.headline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Health Events")
        }
    }
}

struct HealthEventsView_Previews: PreviewProvider {
    static var previews: some View {
        HealthEventsView(events: sampleEvents)
    }
}
