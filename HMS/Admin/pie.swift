//
//  pie.swift
//  HMS
//
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct CircularGraphicalView: View {
    @State private var totalAppointments: Int = 0
    @State private var totalPrescriptions: Int = 0
    
    var body: some View {
        ZStack {
            // Appointments graph
            VStack {
                ZStack {
                    Circle()
                        .stroke(Color.blue, lineWidth: 10)
                        .opacity(0.3)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(totalAppointments) / 100) // Assuming maximum appointments is 100
                        .stroke(Color.blue, lineWidth: 10)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut)
                }
                .frame(width: 200, height: 200)
                .padding()
         
            }
            
            // Prescription graph
            VStack {
                ZStack {
                    Circle()
                        .stroke(Color.green, lineWidth: 10)
                        .opacity(0.3)
                   
                    Circle()
                        .trim(from: 0, to: CGFloat(totalPrescriptions) / 100) // Assuming maximum prescriptions is 100
                        .stroke(Color.green, lineWidth: 10)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut)
                }
                .frame(width: 100, height: 100) // Prescription graph size
                .padding()
                
            }
        }
        .onAppear {
            fetchTotalAppointments()
            fetchTotalPrescriptions()
        }
    }
    
    private func fetchTotalAppointments() {
        let db = Firestore.firestore()
        db.collection("appointments").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching appointments: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            self.totalAppointments = documents.count
        }
    }
    
    private func fetchTotalPrescriptions() {
        let db = Firestore.firestore()
        db.collection("prescriptions").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching prescriptions: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            self.totalPrescriptions = documents.count
        }
    }
}

// Usage:
struct PieView: View {
    var body: some View {
        CircularGraphicalView()
    }
}

struct PieView_Previews: PreviewProvider {
    static var previews: some View {
        PieView()
    }
}
