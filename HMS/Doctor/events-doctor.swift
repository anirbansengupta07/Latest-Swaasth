//
//  events-doctor.swift
//  HMS
//
//

import SwiftUI

struct DoctorHealthEventsView: View {
    @State private var showConfirmationAlert = false
    @StateObject var viewModel = EventsViewModel()
    @State private var confirmedEvents: Set<String> = Set()
    
    var body: some View {
        NavigationView {
            List(viewModel.events , id: \.id) { event in
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
                .contentShape(Rectangle()) // Set the content shape to rectangle to ensure the whole view is tappable
                .onTapGesture {
                    // Handle tapping on event details
                    // You can add any custom action here if needed
                }
                
                // Attend Button
                Button(action: {
                    // Log the event when the "Attend" button is clicked
                    logEvent(event)
                    // Show confirmation alert
                    showConfirmationAlert.toggle()
                    // Update the attendees count
                    updateAttendeesCount(eventId: event.id)
                }) {
                    Text(confirmedEvents.contains(event.id) ? "Confirmed" : "Attend") // Change button label based on confirmation
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 8)
                }
                .disabled(confirmedEvents.contains(event.id) || event.attendees > 150 )
            }
            .navigationTitle("Health Events")
            .alert(isPresented: $showConfirmationAlert) {
                Alert(title: Text("Thank You!"), message: Text("You have confirmed attendance for this event."), dismissButton: .default(Text("OK")))
            }
            .task {
                try? await viewModel.getAllEvents()
            }
            .refreshable {
                try? await viewModel.getAllEvents()
            }
        }
    }
    
    // Function to log the event
    func logEvent(_ event: HealthEvent) {
        print("Attending \(event.title)")
        // Add your logic to log the event here
    }
    
    // Function to update the attendees count
    func updateAttendeesCount(eventId: String) {
        guard let eventIndex = viewModel.events.firstIndex(where: { $0.id == eventId }) else {
            return
        }
        var eventToUpdate = viewModel.events[eventIndex]
        eventToUpdate.attendees += 1
        viewModel.events[eventIndex] = eventToUpdate
        
        HealthEventsManager.shared.updateAttendees(eventId: eventId, newAttendeesCount: eventToUpdate.attendees)
        confirmedEvents.insert(eventId) // Mark the event as confirmed
    }
}

struct DoctorHealthEventsView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorHealthEventsView()
    }
}
