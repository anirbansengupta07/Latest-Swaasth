import SwiftUI

struct HealthEventTabs: View {
    let title: String
    let subTitle: String
    let time: String
    let eventCount: Int
    let dayOfWeek: String
    
    var body: some View {
        VStack{
           
                ZStack {
                    Rectangle()
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 350, height: 150)
                        .cornerRadius(30)
                    
                    HStack(spacing: 5) {
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 100, height: 130)
                            .cornerRadius(30)
                            .padding(.leading, 60)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(subTitle)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(time)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(width: 310, height: 100)
                        .padding(.leading,-37)
                    }
                    .overlay(
                        VStack {
                            Text("\(eventCount)")
                                .font(.system(size: 50))
                                .bold()
                                .foregroundColor(.white)
                                .padding(5)
                                .cornerRadius(10)
                                .padding(.top, 20)
                                .padding(.leading, 75)
                                .italic()
                            Text(dayOfWeek)
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.leading, 75)
                                .padding(.top, -15)
                        },
                        alignment: .topLeading
                    )
                    Spacer()
                }
                .padding(.leading, -20)
            }
        }
    
}
struct HealthEventTabs_Previews: PreviewProvider {
    static var previews: some View {
        HealthEventTabs(title: "Blood Donation", subTitle: "Camp", time: "09:30 AM Onwards", eventCount: 12, dayOfWeek: "Tue")
    }
}


