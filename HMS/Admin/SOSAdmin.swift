//
//  SOSAdmin.swift
//  HMS
//
//


import SwiftUI

import Firebase
import FirebaseFirestore

struct SOSAdmin: View {
    @StateObject private var emergencyViewModel = EmergencyViewModel()
    @State private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                
                ForEach(emergencyViewModel.emergencies, id: \.self) { emergency in
                    LocationCard(patid: emergency.patientId,
                                 latitude: emergency.latitude,
                                 longitude: emergency.longitude,
                                 dateTime: formattedDate(from: emergency.timeStamp))
                }
                
            }
            .padding()
            .onAppear {

                emergencyViewModel.getAllEmergencies()
            }
            .onReceive(timer) { _ in
                                emergencyViewModel.getAllEmergencies()
                            }
            
        }
    }
    
    private func formattedDate(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm a"
            return formatter.string(from: date)
        }
    
}
struct LocationCard: View {
    @State private var pName: String = "Loading..."
    let patid: String
    let latitude: String
    let longitude: String
    let dateTime: String

    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 10) {
                Text(pName)
                    .font(.title)
                Text("Location:")
                    .font(.title2)
                Text("Latitude: ")
                    + Text("\(latitude)").bold()
                    .font(.title3)
                Text("Longitude: ")
                    + Text("\(longitude)").bold()
                    .font(.title3)
                Text("Date & Time:")
                    + Text("\(dateTime)").bold()
                    .font(.title3)
                HStack {
                    Spacer()
                    Button(action: {
                        openMaps(latitude: latitude, longitude: longitude)
                    }) {
                        Text("Locate")
                            .foregroundStyle(Color.white)
                    }
                    .font(.title3)
                    .frame(width:100,height: 50)
                    .background(Color.customBlue)
                    .cornerRadius(11)
                }
                .padding()
            }
            .padding()
            .background(Color.white)
            RoundedRectangle(cornerRadius: 11)
                .strokeBorder(Color.black, lineWidth: 1)
                .shadow(radius: 4)
        }
        .onAppear{
            fetchPName()
        }


    }

    func openMaps(latitude: String, longitude: String) {
        if let url = URL(string: "http://maps.apple.com/?q=\(latitude),\(longitude)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    private func fetchPName() {
        let db = Firestore.firestore()
        let documentID = patid
        db.collection("Patients").document(documentID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if let patientName = data?["name"] as? String {
                    print("Patient Name: \(patientName)")
                    pName=patientName
                } else {
                    print("Patient name not found in the document.")
                }
            } else {
                print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
}





struct SOSAdmin_Previews: PreviewProvider {
    static var previews: some View {
        SOSAdmin()
    }
}
