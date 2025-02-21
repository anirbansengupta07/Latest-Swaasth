import SwiftUI

struct AdminHomePage: View {
    var body: some View {
        NavigationView {
            ZStack{
                ScrollView {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Hey Admin                        ")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.leading)
                            
                            NavigationLink(destination: AdminProfile(admin: AdminDetails(name: "Admin Name", email: "admin@admin.com", contact: "123-456-7890"))) {
                                Image(systemName: "person.circle")
                                    .font(.largeTitle)
                            }
                            .padding(.trailing)
                        }
                        
                        TotalUsersView()
                            .padding(.horizontal)
                        
                        // Add more views/components below
                        MonthlyAppointmentsChartView()
                        MonthlyFinanceChartView()
                        ChartUi()
                        //                    EmergencyLineChartView()
                    }
                    .padding(.top, 20) // Adjusted top padding to add space between the components and the top edge
                }
                .navigationBarTitleDisplayMode(.inline) // Set navigation bar title display mode to inline
                //consult ai
//                VStack {
//                    Spacer()
//                    HStack {
//                        Spacer()
//                        NavigationLink(destination: ConsultGeminiAIView()) {
//                            Image(systemName: "questionmark.circle.fill")
//                                .font(.largeTitle)
//                                .foregroundColor(.white)
//                                .padding()
//                                .background(.newBlue)
//                                .clipShape(Circle()) // Make it circular
//                                .frame(width: 80, height: 80) // Adjust size to make it round
//                                .shadow(radius: 5)
//                        }
//                        .padding(.trailing, 20)
//                        .padding(.bottom, 30)
//                    }
//                }
                //here
            }
            .padding(.top, 50)
            .ignoresSafeArea(.container, edges: .top)
        }
    }
}

struct AdminHomePage_Previews: PreviewProvider {
    static var previews: some View {
        AdminHomePage()
    }
}
