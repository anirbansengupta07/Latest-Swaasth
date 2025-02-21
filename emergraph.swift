import SwiftUI
import Charts
import FirebaseFirestore

struct ChartUi: View {
    @State private var emergencyData: [EmergencyDataPoint] = []
    @State private var emergencyCountByDate: [String: Int] = [:] // Dictionary to store count of emergencies by date
    
    var body: some View {
        VStack {
            Text("Emergency")
                .font(.title2)
                .padding()
            if !emergencyCountByDate.isEmpty {
                Chart {
                    ForEach(emergencyCountByDate.sorted(by: { $0.key < $1.key }), id: \.key) { (date, count) in
                        LineMark(
                            x: .value("Date", date),
                            y: .value("Count", Double(count))
                        )
                    }
                }
                .padding()
            } else {
                Text("Loading...")
            }
        }.frame(height: 250)
        .onAppear {
            fetchEmergencyData()
        }
    }
    
    func fetchEmergencyData() {
        let db = Firestore.firestore()
        db.collection("Emergency").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error ?? NSError())")
                return
            }
            
            // Count the number of emergencies for each date
            var counts: [String: Int] = [:]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy 'at' HH:mm:ss 'UTC'Z"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Setting the locale
            for document in documents {
                if let timestamp = document.data()["timeStamp"] as? Timestamp {
                    let date = timestamp.dateValue()
                    let dayString = dateFormatter.string(from: date).prefix(2) // Extracting only the day component
                    counts[String(dayString), default: 0] += 1
                }
            }
            
            // Assign counts to the emergencyCountByDate dictionary
            self.emergencyCountByDate = counts
            
            // Update emergencyData array if needed
            let baseDateString = "01 January 2022 at 00:00:00 UTC"
            let baseDateFormatter = DateFormatter()
            baseDateFormatter.dateFormat = "dd MMMM yyyy 'at' HH:mm:ss 'UTC'Z"
            baseDateFormatter.locale = Locale(identifier: "en_US_POSIX")
            self.emergencyData = counts.compactMap { key, value in
                if let date = baseDateFormatter.date(from: "\(key) \(baseDateString)") {
                    return EmergencyDataPoint(date: date, time: "")
                } else {
                    print("Failed to parse date for key: \(key)")
                    return nil
                }
            }
        }
    }
}

struct EmergencyDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let time: String
}

struct ContentView_Previews1: PreviewProvider {
    static var previews: some View {
        ChartUi()
    }
}
