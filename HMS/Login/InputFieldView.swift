//
//  InputFieldView.swift
//  HMS
//
//  Created by Sarthak 
//

import SwiftUI

struct InputFieldView: View {
   
  @Binding var data:String
  var title: String?
   
  var body: some View {
    ZStack {
     TextField("", text: $data)
      .padding(.horizontal, 10)
      .frame(width: 360, height: 52)
      .overlay(
       RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
         .stroke(Color.customBlue, lineWidth: 1)
      ).onChange(of: data) { newValue in
          // Validate contact number format only if it's the contact field
          if title == "Contact" {
              if !newValue.isEmpty && !newValue.hasPrefix("+91") {
                  // Prepend "+91" to the number
                  data = "+91 " + newValue.filter { $0.isNumber }
              }
          }
      }
     HStack {
      Text(title ?? "Input")
       .font(.headline)
       .fontWeight(.medium)
       .foregroundColor(Color.customBlue)
       .multilineTextAlignment(.leading)
       .padding(.bottom,4)
       .background(Color(Color.white))
      Spacer()
     }
     .padding(.leading, 18)
     .offset(CGSize(width: 0, height: -25))
    }.padding(4)
  }
}

#Preview {
  InputFieldView(data: .constant(""))
}
