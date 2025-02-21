import SwiftUI

struct Patient: View {
    @State private var selectedTab: Int = 0 // Track the selected tab index
    
    var body: some View {
//        NavigationView {
            TabView(selection: $selectedTab) {
                HomeScreenView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)
                
                AppointmentsView()
                    .tabItem {
                        Image(systemName: "book")
                        Text("Record")
                    }
                    .tag(1)
                
                SosView()
                    .tabItem {
                        Label("SOS", systemImage: "exclamationmark.circle")
                            .foregroundColor(.red)
                    }
                    .tag(2)
                
                DoctorListView()
                    .tabItem {
                        Image(systemName: "plus.app")
                        Text("Book")
                    }
                    .tag(3)
                
//                HealthEventsView()
//                    .tabItem {
//                        Image(systemName: "heart.text.square.fill")
//                        Text("Health Events")
//                    }
//                    .tag(4)
            }
            .navigationBarHidden(true) // Hide the navigation bar
            .navigationBarBackButtonHidden(true)
            
            .onAppear {
                            // correct the transparency bug for Tab bars
                            let tabBarAppearance = UITabBarAppearance()
                            tabBarAppearance.configureWithOpaqueBackground()
                            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                            // correct the transparency bug for Navigation bars
                            let navigationBarAppearance = UINavigationBarAppearance()
                            navigationBarAppearance.configureWithOpaqueBackground()
                            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
                        }
//        }
//        .navigationBarBackButtonHidden(true)

    }
}

struct Patient_Previews: PreviewProvider {
    static var previews: some View {
        Patient()
    }
}
