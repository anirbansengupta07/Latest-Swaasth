//
//  VitalsHeartView.swift
//  HMS
//
//  Created by Shashwat Singh on 22/04/24.
//

import SwiftUI

struct VitalsHeartView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
                    .frame(width: 180, height: 150)
                    .foregroundColor(Color.blue.opacity(0.2))
                    .overlay(
                        VStack{
                            HStack{
                                Image(systemName: "heart")
                                    .foregroundColor(.blue)
                                
                                Text("Heart Rate")
                                    .foregroundColor(.blue)
                                .font(.headline)
                            }
                            HStack{
                                Text("80")
                                    .foregroundColor(.black)
                                    .font(.system(size: 50))
                                    .fontWeight(.bold)
                                Text("bmp")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 20))
                                    .padding(.top)
                            }
                        }
                    )
    }
}

#Preview {
    VitalsHeartView()
}
