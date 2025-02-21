//  earnings.swift
//  HMS
//
//

import SwiftUI
import FirebaseFirestore

// Define a model for appointment data
struct Appointment {
    var date: Date
    // You can add more properties as needed
}

struct EarningsLineChartView: View {
    @State private var appointments: [Appointment] = []
    @State private var dataPoints: [CGFloat] = []

    var body: some View {
        VStack {
            Text("Patients Per Month")
                .font(.title)
                .padding()

            if !appointments.isEmpty {
                BarGraphView(dataPoints: dataPoints)
                    .frame(height: 300)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blueShade.opacity(0.6), Color.blueShade]),
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                    )
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            fetchAppointmentsFromFirestore()
        }
    }
    
    func fetchAppointmentsFromFirestore() {
        let db = Firestore.firestore()
        db.collection("appointments").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error)")
                return
            }
            self.appointments = documents.compactMap { document in
                let data = document.data()
                let timestamp = data["date"] as? Timestamp ?? Timestamp(date: Date())
                let date = timestamp.dateValue() // Convert Timestamp to Date
                return Appointment(date: date)
            }
            
            // Once appointments are fetched, update the data points for the graph
            DispatchQueue.main.async {
                self.calculateDataPoints()
            }
        }
    }
    
    func calculateDataPoints() {
        let calendar = Calendar.current

        // Initialize a dictionary with all months and their counts set to 0
        var monthlyPatientCounts: [Int: Int] = Dictionary(uniqueKeysWithValues: (1...12).map { ($0, 0) })

        // Update the counts with actual data
        for appointment in appointments {
            let month = calendar.component(.month, from: appointment.date)
            monthlyPatientCounts[month, default: 0] += 1
        }

        // Extract patient counts for each month
        self.dataPoints = (1...12).map { month in
            let count = monthlyPatientCounts[month] ?? 0
            return CGFloat(count)
        }
    }
}

struct BarGraphView: View {
    var dataPoints: [CGFloat]

    var body: some View {
        GeometryReader { geometry in
            let stepWidth = geometry.size.width / 12
            let stepHeight = geometry.size.height / 100

            HStack(spacing: 16) {
                ForEach(dataPoints.indices, id: \.self) { index in
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: stepWidth - 16, height: stepHeight * dataPoints[index])
                        Text("\(index + 1)")
                            .foregroundColor(.primary)
                            .padding(.top, 8)
                            .font(.caption)
                            .frame(width: stepWidth - 16)
                    }
                }
            }
        }
    }
}

struct EarningsLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        EarningsLineChartView()
    }
}
