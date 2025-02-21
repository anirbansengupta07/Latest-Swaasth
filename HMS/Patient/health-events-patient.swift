//
//  health-events-patient.swift
//  HMS
//

import SwiftUI

struct HealthEventsView: View {
    @State private var showConfirmationAlert = false
    @StateObject var viewModel = EventsViewModel()
    @State private var attendedEvents: Set<String> = Set()
    
    var body: some View {
        NavigationView {
            List(viewModel.events, id: \.id) { event in
                VStack(alignment: .leading, spacing: 8) {
                    if let url = URL(string: event.imageName) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(10)
                    }
                    
                    Text(event.title)
                        .font(.headline)
                    Text(event.description) // Display event description
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Date: \(event.date)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text("Time: \(event.time)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text("Venue: \(event.venue)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text("Attendees: \(event.attendees)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // Handle tapping on event details
                }
                
                Button(action: {
                    logEvent(event)
                    attendedEvents.insert(event.id) // Mark the event as attended
                    showConfirmationAlert.toggle()
                    updateAttendeesCount(eventId: event.id)
                }) {
                    Text(attendedEvents.contains(event.id) ? "Attended" : "Attend") // Change button label based on attendance
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 8)
                }
                .disabled(attendedEvents.contains(event.id) || event.attendees > 150 )
            }
            .navigationTitle("Health Events")
            .alert(isPresented: $showConfirmationAlert) {
                Alert(title: Text("Thank You!"), message: Text("You have confirmed attendance for this event."), dismissButton: .default(Text("OK")))
            }
            .task {
                try? await viewModel.getAllEvents()
            }
            
        }
    }
    
    func logEvent(_ event: HealthEvent) {
        print("Attending \(event.title)")
        // Add your logic to log the event here
    }
    
    func updateAttendeesCount(eventId: String) {
        guard let eventIndex = viewModel.events.firstIndex(where: { $0.id == eventId }) else {
            return
        }
        var eventToUpdate = viewModel.events[eventIndex]
        eventToUpdate.attendees += 1
        viewModel.events[eventIndex] = eventToUpdate
        
        HealthEventsManager.shared.updateAttendees(eventId: eventId, newAttendeesCount: eventToUpdate.attendees)
    }
}

struct HealthEventsView_Previews: PreviewProvider {
    static var previews: some View {
        HealthEventsView()
    }
}
