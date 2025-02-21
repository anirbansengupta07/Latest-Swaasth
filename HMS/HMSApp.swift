//
//  HMSApp.swift
//  HMS
//
//  Created by Sarthak 
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//      let provideFactory = AppCheckDebugProviderFactory()
//      AppCheck.setAppCheckProviderFactory(provideFactory)
    FirebaseApp.configure()

    return true
  }
}

enum UserType: String {
    case patient
    case admin
    case doctor
    case unknown
}

class UserTypeManager: ObservableObject {
    @Published var userType: UserType {
        didSet {
            UserDefaults.standard.set(userType.rawValue, forKey: "userType")
        }
    }
    @Published var userID: String {
        didSet {
            UserDefaults.standard.set(userID, forKey: "userID")
        }
    }

    init() {
        let savedUserType = UserDefaults.standard.string(forKey: "userType") ?? UserType.unknown.rawValue
        self.userType = UserType(rawValue: savedUserType) ?? .unknown
        self.userID = UserDefaults.standard.string(forKey: "userID") ?? ""
    }
}


@main
struct HMSApp: App {
    @StateObject var userTypeManager = UserTypeManager()
    @StateObject var locationManager = LocationManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isOnboardingCompleted") var isOnboardingCompleted: Bool = UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
    @State private var splashIsActive = false
    
    @State private var size = 0.6
    @State private var opa = 0.5

//    init() {
//                // Reset for development purposes
//                UserDefaults.standard.set(false, forKey: "isLoggedIn")
//                UserDefaults.standard.set(false, forKey: "isOnboardingCompleted")
//
//                // Initialize the @AppStorage property
//                _isOnboardingCompleted = AppStorage(wrappedValue: false, "isOnboardingCompleted")
//
//                // Initialize the state objects with updated values from UserDefaults
//                _userAuth = StateObject(wrappedValue: UserAuth())
//            }
    
    var body: some Scene {
        WindowGroup {
            if splashIsActive{
                if isOnboardingCompleted {
                    if userTypeManager.userType == .unknown {
                        LoginView()
                            .environmentObject(userTypeManager)

                    } else {
                        MainTabs()
                            .environmentObject(userTypeManager)
                    }
                } else {
                    OnBoarding(isOnboardingCompleted: $isOnboardingCompleted)
                }
            }
            else{
                VStack{
                    
                    Image("demoLogo")
                    
                        .scaleEffect(size)
                        .opacity(opa)
                        .onAppear {
                            withAnimation(.easeIn(duration: 2.0)){
                                size = 0.9
                                opa = 1.0
                            }
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation {
                                    splashIsActive = true
                                }
                            }
                        }
                }
            }
        }.environmentObject(locationManager)
    }
}
    


struct MainTabs: View {
    @EnvironmentObject var userTypeManager: UserTypeManager
    
    var body: some View {
        NavigationStack{
            switch userTypeManager.userType {
            case .patient:
                Patient()
            case .admin:
                Admin()
            case .doctor:
                Doc()
            case .unknown:
                ContentView()
            }
        }
    }
}
