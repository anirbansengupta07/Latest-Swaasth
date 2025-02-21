//
//  Manage.swift
//  HMS
//
//

import SwiftUI
import Firebase
import FirebaseStorage

struct ManagePatient: View {
    @State private var searchText = ""
    @State private var patientData: [PatientModel] = []
    @State private var isRefreshing = false

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText, placeHolder: "Search Patient")
                    .padding(.horizontal, 16)

                List {
                    ForEach(filteredPatients(), id: \.id) { pat in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(pat.name ?? "Unknown Name")
                                    .font(.headline)
                                    .fontWeight(.bold)

                                Text("Emergency Contact: \(pat.emergencyContact ?? "Unknown Contact")")
                                    .foregroundColor(.gray)

                                Text("ID: \(pat.id ?? "N/A")")
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Discharge") {
                                Task {
                                    await deleteAdmittedPatient(patientId: pat.id ?? "")
                                                                }
                            }
                            .tint(.red)
                        }
                    }
                    
                }
                .refreshable {
                    await refreshData()
                }
                .navigationTitle("Manage Admission")
            }
            .onAppear {
                Task {
                    await loadAdmittedPatients()
                }
            }
        }
    }

    private func filteredPatients() -> [PatientModel] {
        guard !searchText.isEmpty else { return patientData }
        return patientData.filter { $0.name?.lowercased().contains(searchText.lowercased()) ?? false }
    }

    private func refreshData() async {
        isRefreshing = true
        await loadAdmittedPatients()
        isRefreshing = false
    }

    private func loadAdmittedPatients() async {
        do {
            patientData = try await fetchAdmittedPatients()
            print("Fetched \(patientData.count) patients.")
        } catch {
            print("Error loading admitted patients: \(error.localizedDescription)")
        }
    }

    func fetchAdmittedPatients() async throws -> [PatientModel] {
        let db = Firestore.firestore()
        var patients: [PatientModel] = []

        do {
            // Fetch all admits
            let querySnapshot = try await db.collection("admits").getDocuments()
            let admits = querySnapshot.documents.compactMap { doc -> Admit? in
                guard let admit = Admit(dictionary: doc.data(), id: doc.documentID) else { return nil }
                return admit
            }

            print("Fetched \(admits.count) admits.")

            // Fetch patient information using their IDs
            for admit in admits {
                let patientDoc = try await db.collection("Patients").document(admit.patientId)
                    .getDocument()
                if let patientData = patientDoc.data() {
                    if let patient = PatientModel(dictionary: patientData, id: patientDoc.documentID) {
                        patients.append(patient)
                    } else {
                        print("Invalid patient data for patientId: \(admit.patientId)")
                    }
                } else {
                    print("No patient document found for patientId: \(admit.patientId)")
                }
            }
            print("Fetched \(patients.count) patients from admits.")
            return patients
        } catch {
            print("Error fetching patients from admits: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteAdmittedPatient(patientId: String) async {
            let db = Firestore.firestore()
            let admitsRef = db.collection("admits")
            do {
                // Find the admit document(s) to delete
                let querySnapshot = try await admitsRef.whereField("patientId", isEqualTo: patientId).getDocuments()
                for document in querySnapshot.documents {
                    try await admitsRef.document(document.documentID).delete()
                    print("Deleted admit document with ID: \(document.documentID)")
                }
                // Refresh patient data after deletion
                await loadAdmittedPatients()
            } catch {
                print("Error deleting admitted patient: \(error.localizedDescription)")
            }
        }
}

#Preview {
    ManagePatient()
}
