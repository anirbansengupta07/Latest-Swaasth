import SwiftUI



struct WaveDivider: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        
        path.move(to: CGPoint(x: 0, y: 0))
        
        
        path.addLine(to: CGPoint(x: width, y: 0))
        
        
        path.addQuadCurve(to: CGPoint(x: width * 0.25, y: height * 0.25),
                          control: CGPoint(x: width * 0.125, y: -height * 0.0625))
        
        
        path.addQuadCurve(to: CGPoint(x: width * 0.5, y: 0),
                          control: CGPoint(x: width * 0.375, y: height * 0.0625))
        
        
        path.addQuadCurve(to: CGPoint(x: width * 0.75, y: height * 0.25),
                          control: CGPoint(x: width * 0.625, y: -height * 0.0625))
        
        
        path.addQuadCurve(to: CGPoint(x: width, y: 0),
                          control: CGPoint(x: width * 0.875, y: height * 0.0625))
        
        
        path.addLine(to: CGPoint(x: width, y: 0))
        
        return path
    }
}

struct PaymentConfirmationPage: View {
    
    var doctorName: String
    var selectedDate: String
    var selectedSlot: String
    
    var body: some View {
        NavigationView{
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .foregroundColor(Color.customBlue)
                
                Text("Payment Successful")
                    .font(.system(size: 35))
                    .fontWeight(.bold)
                    .padding(.top, 25)
                
                Text("You have successfully booked an appointment with")
                    .multilineTextAlignment(.center)
                    .padding(.top,-2)
                    
                Text(doctorName)
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.top,-10)
                    .bold()
                    .font(.system(size: 20))
                
                Divider()
                    .background(Color.customBlue)
                    .padding(.horizontal, 20)
                    .frame(height: 2)
                    .padding(.vertical, 20)
                
                HStack {
                    Image(systemName:"person.crop.circle")
                        .foregroundColor(Color.customBlue)
                    Text("patient")
                        .font(.headline)
                    Spacer()
                    Image(systemName:"clock.fill")
                        .foregroundColor(Color.customBlue)
                    Text(selectedSlot)
                        .font(.headline)
                        .padding(.bottom, 5)
                }
                .padding(.horizontal)
                
                HStack() {
                    Image(systemName:"calendar.circle.fill")
                        .foregroundColor(Color.customBlue)
                    Text(selectedDate)
                        .font(.headline)
                        .padding(.bottom, 5)
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
                
                
                WaveDivider()
                    .stroke(Color.customBlue, lineWidth: 2)
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                
                
                
                    NavigationView{
                        NavigationLink(destination: Patient()) {
                            Text("Go to Home")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.customBlue)
                                .cornerRadius(11)
                        }

                    }
                    .navigationBarBackButtonHidden(true)
                    
               
                
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}


struct PaymentConfirmationPage_Previews: PreviewProvider {
    static var previews: some View {
        return PaymentConfirmationPage(doctorName: "Dr. Kenny Adeola", selectedDate: "19 Nov, 2023", selectedSlot: "8:30 AM")
    }
}
