//
//  gview.swift
//  HMS
//
//
import SwiftUI
import Charts
import FirebaseFirestore

struct MonthlyAppointmentsChartView: View {
    @State private var monthlyAppointments: [ChartData] = []
    
    var body: some View {
        VStack {
            Text("Monthly Appointments")
                .font(.title2)
                .padding()
            
            if !monthlyAppointments.isEmpty {
                // Add padding around the BarChart
                VStack {
                    BarChart(data: monthlyAppointments)
                        .frame(height: 300)
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                }
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .shadow(color: .gray, radius: 5, x: 0, y: 2)
                )
                .cornerRadius(25)
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            fetchMonthlyAppointmentsFromFirestore()
        }
    }
    
    func fetchMonthlyAppointmentsFromFirestore() {
        let db = Firestore.firestore()
        db.collection("appointments")
            .whereField("Bill", isEqualTo: 1000) // Filter appointments where bill is 1000
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error)")
                    return
                }
                
                var appointmentsByMonth: [String: Int] = [:]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy" // Adjusted date format
                
                for document in documents {
                    let data = document.data()
                    guard let dateString = data["Date"] as? String else {
                        print("Error: Date not found")
                        continue
                    }
                    
                    guard let date = dateFormatter.date(from: dateString) else {
                        print("Error: Unable to parse date")
                        continue
                    }
                    
                    // Extract month and year from the date
                    let calendar = Calendar.current
                    let month = calendar.component(.month, from: date)
                    let year = calendar.component(.year, from: date)
                    
                    // Create a string key for the month and year
                    let monthYearKey = "\(year)-\(month)"
                    
                    // Increment the appointment count for the month and year key
                    appointmentsByMonth[monthYearKey, default: 0] += 1
                }
                
                // Sort the appointments by month and year
                let sortedAppointments = appointmentsByMonth.sorted { $0.key < $1.key }
                
                // Convert sorted appointments data to ChartData format
                self.monthlyAppointments = sortedAppointments.map { (key, value) in
                    let components = key.components(separatedBy: "-")
                    let month = Int(components[1]) ?? 1 // Default to January if unable to parse
                    let monthSymbol = DateFormatter().monthSymbols[month - 1]
                    let label = "\(monthSymbol) \(components[0])"
                    return ChartData(label: label, value: Double(value))
                }
            }
    }

}

struct MonthlyAppointmentsChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyAppointmentsChartView()
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

struct BarChart: View {
    let data: [ChartData]
    var body: some View {
        let maxBarWidth: CGFloat = 20 // Adjust the maximum width of the bars as needed
        let barSpacing: CGFloat = 2 // Adjust the spacing between bars as needed

        return Chart() {
            ForEach(data, id: \.id) { item in
                BarMark(
                    x: .value("Month", item.label),
                    y: .value("Appointments", item.value)
                )
                .cornerRadius(10)
            }
        }
        .chartYScale(domain: [0, data.map { $0.value }.max() ?? 100])
        .padding(.horizontal, barSpacing)
    }
}
