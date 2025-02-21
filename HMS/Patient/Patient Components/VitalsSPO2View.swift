//
//  VitalsSPO2View.swift
//  HMS
//
//  Created by Shashwat Singh on 22/04/24.
//

import SwiftUI

struct VitalsSPO2View: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
                    .frame(width: 180, height: 150)
                    .foregroundColor(Color.red.opacity(0.2))
                    .overlay(
                        VStack{
                            HStack{
                                Image(systemName: "waveform.path.ecg")
                                    .foregroundColor(.red.opacity(0.8))
                                
                                Text("SPO2")
                                    .foregroundColor(.red.opacity(0.8))
                                .font(.headline)
                            }
                            HStack{
                                Text("24")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 50))
                                    .fontWeight(.bold)
                                Text("min")
                                    .foregroundColor(.black)
                                    .font(.system(size: 20))
                                    .padding(.top)
                            }
                        }
                    )
    }
}

#Preview {
    VitalsSPO2View()
}
