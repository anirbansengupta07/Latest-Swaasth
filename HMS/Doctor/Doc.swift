
//  Doc.swift
//  HMS
//
// 
//

import SwiftUI

struct Doc: View {
    var body: some View {
        TabView{
            DoctorHome()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
           
//            DoctorHealthEventsView()
//                .tabItem {
//                    Image(systemName: "calendar")
//                    Text("Events")
//                }
            
            ManagePatientDoc()
                .tabItem { Image(systemName: "person.3.fill")
                    Text("Manage discharge") }
            
            DoctorAccountView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
            
        }
        .navigationBarHidden(true) // Hide the navigation bar
        .navigationBarBackButtonHidden(true)
        
        .onAppear {
            UITabBar.appearance().tintColor.customMirror // Set tab bar color
        }
    }
}


#Preview {
    Doc()
}

