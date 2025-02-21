//
//  gview.swift
//  HMS
//
//
import SwiftUI
import Charts
import FirebaseFirestore

struct MonthlyFinanceChartView: View {
    @State private var monthlyFinance: [ChartData1] = []
    
    var body: some View {
        VStack {
            Text("Monthly Finance")
                .font(.title2)
                .padding()
            
            if !monthlyFinance.isEmpty {
                // Add padding around the BarChart
                VStack {
                    BarChart1(data: monthlyFinance)
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
            fetchMonthlyFinanceFromFirestore()
        }
    }
    
    func fetchMonthlyFinanceFromFirestore() {
        let db = Firestore.firestore()
        db.collection("appointments")
            .whereField("Bill", isEqualTo: 1000) // Filter appointments where bill is 1000
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error)")
                    return
                }
                
                var financeByMonth: [String: Double] = [:]
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
                    
                    // Increment the finance for the month and year key
                    financeByMonth[monthYearKey, default: 0] += 1000 // Assuming each appointment earns 1000
                }
                
                // Sort the finance by month and year
                let sortedFinance = financeByMonth.sorted { $0.key < $1.key }
                
                // Convert sorted finance data to ChartData format
                self.monthlyFinance = sortedFinance.map { (key, value) in
                    let components = key.components(separatedBy: "-")
                    let month = Int(components[1]) ?? 1 // Default to January if unable to parse
                    let monthSymbol = DateFormatter().monthSymbols[month - 1]
                    let label = "\(monthSymbol) \(components[0])"
                    return ChartData1(label: label, value: value)
                }
            }
    }

}

struct MonthlyFinanceChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyFinanceChartView()
    }
}

struct ChartData1: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

struct BarChart1: View {
    let data: [ChartData1]
    var body: some View {
        let maxBarWidth: CGFloat = 20 // Adjust the maximum width of the bars as needed
        let barSpacing: CGFloat = 2 // Adjust the spacing between bars as needed

        return Chart() {
            ForEach(data, id: \.id) { item in
                BarMark(
                    x: .value("Month", item.label),
                    y: .value("Finance (in Rs.)", item.value)
                )
                .cornerRadius(10)
            }
        }
        .chartYScale(domain: [0, data.map { $0.value }.max() ?? 100])
        .padding(.horizontal, barSpacing)
    }
}
