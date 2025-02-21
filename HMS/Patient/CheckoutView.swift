//
//  PaymentDetailsView.swift
//  HMS
//

import SwiftUI
import Firebase

struct CheckoutView: View {
    
    var doctorName: String
    var selectedDate: String
    var selectedSlot: String
    var Bill: Int
    var DocID: String
    var PatID: String
    var reason: String
    
    @State private var selectedPaymentMethod: String?
    
    var PrefPaymentOpt = ["Paytm UPI", "Google Pay" , "Pay at the end(Cash/UPI)"]
    var otherPaymentOpt = ["asdf@okhdfcbank", "omvin@aubank"]
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()


    var body: some View {
        VStack{
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    
                    // Booking Details
                    VStack{
                        VStack(alignment: .leading) {
                            Text(doctorName)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .padding()
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("From")
                                Text(selectedDate)
                                    .fontWeight(.bold)
                                Text(selectedSlot)
                                    .fontWeight(.bold)
                            }

                            Spacer()
                            Divider()
                                .frame(height: 50.0)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("To")
                                Text(selectedDate)
                                    .fontWeight(.bold)
                                if let selectedSlotDate = timeFormatter.date(from: selectedSlot) {
                                    if let nextHourDate = Calendar.current.date(byAdding: .hour, value: 1, to: selectedSlotDate) {
                                        Text(timeFormatter.string(from: nextHourDate))
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                        }
                        .padding([.leading, .trailing])
                        
                        Divider()
                        
                        // Price Details
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Price")
                                    .font(.title2)
                                Spacer()
                                Text("Rs.1000")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .padding([.leading, .trailing, .top])
                            
                            HStack {
                                Spacer()
                                Text("Incl. of all taxes")
                                    .foregroundColor(.secondary)
                            }
                            .padding([.leading, .trailing])
                        }
                    }
                    .padding()
                    .frame(width:360)
                    .background (.white)
                    .clipShape (RoundedRectangle (cornerRadius: 11))
                    .padding()
                    .shadow(radius: 10)
                    
                    // Payment options
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Preferred payment options")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        ForEach(PrefPaymentOpt, id: \.self) { paymentOption in
                            PaymentMethodView(
                                methodName: paymentOption,
                                doctorName: doctorName,
                                selectedDate: selectedDate,
                                selectedSlot: selectedSlot,
                                Bill: Bill,
                                DocID: DocID,
                                PatID: PatID,
                                reason: reason,
                                selectedPaymentMethod: $selectedPaymentMethod
                            )
                        }

                        
                        Text("Pay by any UPI App")
                            .font(.headline)
                            .padding(.top)
                        
                        VStack {
                            ForEach(otherPaymentOpt, id: \.self) { paymentOption in
                                PaymentMethodView(
                                    methodName: paymentOption,
                                    doctorName: doctorName,
                                    selectedDate: selectedDate,
                                    selectedSlot: selectedSlot,
                                    Bill: Bill,
                                    DocID: DocID,
                                    PatID: PatID,
                                    reason: reason,
                                    selectedPaymentMethod: $selectedPaymentMethod
                                )
                            }

                            
                            Button("Add New UPI ID") {
                                // Implement the Add New UPI action
                            }
                            .foregroundColor(.blue)
                        }
                        
                    }
                    .padding(.horizontal)
                    
                }
            }

        }
        .navigationTitle("Final Step")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PaymentMethodView: View {
    var methodName: String
    var doctorName: String
    var selectedDate: String
    var selectedSlot: String
    var Bill: Int
    var DocID: String
    var PatID: String
    var reason: String
    @State private var isBookingSuccessful = false
    @Binding var selectedPaymentMethod: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Text(methodName)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: selectedPaymentMethod == methodName ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selectedPaymentMethod == methodName ? .blue : .gray)
            }

            if selectedPaymentMethod == methodName {
                NavigationLink(destination: PaymentConfirmationPage(doctorName: doctorName, selectedDate: selectedDate, selectedSlot: selectedSlot), isActive: $isBookingSuccessful) {
                    EmptyView()
                }

                Button(action: {
                    createBooking()
                }) {
                    Text("Pay via \(methodName)")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customBlue)
                        .cornerRadius(11)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
        .onTapGesture {
            self.selectedPaymentMethod = methodName
        }
    }
    
    func createBooking() {
        let db = Firestore.firestore()
        let appointmentsRef = db.collection("appointments")

        let appointmentData: [String: Any] = [
            "Bill": Bill,
            "Date": selectedDate,
            "DocID": DocID,
            "PatID": PatID,
            "TimeSlot": selectedSlot,
            "isComplete": false,
            "reason": reason
        ]

        appointmentsRef.addDocument(data: appointmentData) { error in
            if let error = error {
                print("Error creating booking: \(error.localizedDescription)")
            } else {
                print("Booking created successfully")
                self.isBookingSuccessful = true
            }
        }
    }
}
