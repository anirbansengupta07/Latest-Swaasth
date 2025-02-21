//
//  SosView.swift
//  HMS
//

import SwiftUI

struct SosView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var userTypeManager: UserTypeManager
    @State var isOn: Bool = false
    @State private var countdownTimer: Timer?
    @State var countdown: Int = 5 // Initial countdown value
    @State var timerFinished: Bool = false // Track whether timer has finished
    @State var latitude = ""
    @State var longitude = ""
    
    var body: some View {
        ZStack {
            Image("BackBlur")
                .resizable()
                .blur(radius: 50.0)
            
            VStack {
                Text("Medical Emergency")
                    .font(.title)
                    .fontWeight(.bold)
                
                Toggle("", isOn: $isOn)
                    .toggleStyle(CustomToggleStyle(isOn: $isOn))

                
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 130)
                    .padding(80)
                    .overlay(
                        Text("\(countdown)")
                            .foregroundColor(.red)
                            .font(.title)
                    )
                    .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                        if isOn && countdown > 0 {
                            countdown -= 1
                        } else if countdown == 0 {
                            timerFinished = true // Set timerFinished to true when countdown reaches 0
                        }
                    }
                
                VStack {
                    Button(action: {
                        resetTimer() // Reset the timer
                    }) {
                        Image("closebutton")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 70, height: 70)
                    }
                    Text("Cancel")
                }
                
                if timerFinished {
                    VStack(alignment: .leading) {
                        Text("Location sent successfully! ")

                        
                    }
                    .onAppear {
                        printLocation()
                        EmergencyManager.shared.addEmergency(patientId: userTypeManager.userID, latitude: "\(locationManager.location?.coordinate.latitude ?? 0.0)", longitude: "\(locationManager.location?.coordinate.longitude ?? 0.0)")
                                            
                        
                    }
                }
            }
        }
    }
    
    func resetTimer() {
        countdownTimer?.invalidate() // Stop the countdown timer
        countdown = 5 // Reset the countdown value
        isOn = false // Turn off the toggle
        timerFinished = false // Reset timerFinished flag
    }
    
    func printLocation() {
        if let latitude = locationManager.location?.coordinate.latitude,
           let longitude = locationManager.location?.coordinate.longitude {
            print("Latitude: \(latitude), Longitude: \(longitude)")
        } else {
            print("Location is not available.")
        }
    }
}

struct CustomToggleStyle: ToggleStyle {
    var onImageName: String = "img1"
    var offImageName: String = "img2"
    @Binding var isOn: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        let dragGesture = DragGesture(minimumDistance: 1)
            .onChanged { _ in
                withAnimation {
                    configuration.isOn.toggle()
                }
            }
        
        return HStack {
            configuration.label
            
            ZStack{
                Rectangle()
                    .foregroundColor(configuration.isOn ? .red : .gray.opacity(0.8))
                    .frame(width: 250, height: 80)
                    .overlay(
                        Image("imgSos")
                            .resizable()
                            .frame(width: 75,height: 75)
                            .offset(x: isOn ? 85 : -85, y: 0) // Adjust offset dynamically
                            .animation(Animation.linear(duration: 0.1))
                    )
                    .cornerRadius(40)
                    .gesture(dragGesture)
                
                Text("Emergency")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SosView().environmentObject(LocationManager())
    }
}

