//
//  phoneVerificationView.swift
//  HMS
//
//  Created by Sarthak 
//

import SwiftUI

struct phoneVerificationView: View {
  @State private var verificationCode = "" // State variable for user input
  @State private var resendTimer = 0 // State variable for resend timer (seconds)
   
  // Function to handle resend code button tap (replace with actual logic)
  func resendCode() {
    print("Resend code button tapped (placeholder)")
    // Implement logic to send a new verification code to the user's phone number
    resendTimer = 60 // Set resend timer to 60 seconds (example)
  }
   
  var body: some View {
    NavigationView { // Assuming navigation is desired
      VStack {
        Text("Verification")
          .font(.largeTitle)
          .padding(.bottom)
         
        Text("Phone verification")
          .foregroundColor(.gray)
          .padding(.bottom)
         
        Text("We'll send a code to your number to confirm you own it.")
          .padding(.bottom)
         
        HStack {
          TextField("", text: $verificationCode)
            .frame(width: 44) // Assuming 4-digit code
            .background(Color.gray.opacity(0.2))
            .cornerRadius(5)
            .keyboardType(.numberPad) // Set keyboard type for numbers
          // Add more text fields for remaining digits (repeat the above)
        }
         
        if resendTimer > 0 {
          Text("Resend code in \(resendTimer)")
            .foregroundColor(.gray)
            .padding(.top)
        } else {
          Button("Resend code") {
            resendCode()
          }
          .foregroundColor(.blue)
          .padding(.top)
        }
         
        // Button to verify code (replace with actual logic)
        NavigationLink {
         // Replace with your phone verification view
         EmptyView()
        } label: {
         Text("Verify")
          .fontWeight(.heavy)
          .font(.title3)
          .frame(width: 300)
          .padding()
          .foregroundColor(.white)
          .background(Color(Color.black))
          .cornerRadius(40)
        }
        .disabled(verificationCode.count < 4) // Disable Verify button until 4 digits entered
        .foregroundColor(.white)
        .padding()
        .cornerRadius(5)
        .opacity(verificationCode.count < 4 ? 0.5 : 1.0) // Reduce opacity if less than 4 digits
         
        Spacer() // Add spacer to push verification button down
      }
      .padding()
      // Set navigation bar title (optional)
    }.padding(.bottom,100)
  }
}

#Preview {
  phoneVerificationView()
}
