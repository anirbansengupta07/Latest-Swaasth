
import SwiftUI
import Firebase
struct LoginView: View {
    @State var usernameTitle : String = "Email"
    @State var passwordTitle : String = "Password"
    
    @EnvironmentObject var userTypeManager: UserTypeManager

    @State var username : String = ""
    @State var password : String = ""
    
    @State private var showForgotPasswordSheet = false
    @State private var emailForReset = ""
    @State private var showingResetPasswordAlert = false
    @State private var resetPasswordAlertMessage = ""

    @State private var showAlert = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                VStack {
                    Text("Welcome Back !").font(.largeTitle).fontWeight(.bold).padding(.bottom,42).foregroundColor(.customBlue)
                    VStack(spacing:16.0){
                        InputFieldView(data: $username, title: usernameTitle).autocorrectionDisabled()
                        ZStack {
                            SecureField("", text: $password)
                                .padding(.horizontal, 10)
                                .frame(width: 360, height: 52)
                                .overlay(
                                    RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                                        .stroke(Color.customBlue, lineWidth: 1)
                                )
                            HStack {
                                Text("Password")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.customBlue)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 2)
                                    .background(Color(Color.white))
                                Spacer()
                            }
                            .padding(.leading, 18)
                            .offset(CGSize(width: 0, height: -25))
                        }.padding(.top, 1)
                    }.padding(.bottom,25)
                    
                    Button(action: {
                        login() // Call login method when button is tapped
                    }) {
                        Text("Log In")
                            .fontWeight(.heavy)
                            .font(.title3)
                            .frame(width: 300)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.customBlue)
                            .cornerRadius(11)
                    }
                    
                    HStack {
                        Spacer().frame(maxWidth: 160)
                        Button("Forgot Password?") {
                            self.showForgotPasswordSheet = true
                        }
                        .foregroundColor(Color.blue)
                        .underline()
                        .sheet(isPresented: $showForgotPasswordSheet) {
                            VStack {
                                Text("Reset Password")
                                    .font(.headline)
                                    .padding()
                                Text("Enter your email to reset your password.")
                                TextField("Email", text: $emailForReset)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                Button("Submit") {
                                    self.resetPassword(email: self.emailForReset)
                                    self.showForgotPasswordSheet = false // Close the sheet
                                }
                                .padding()
                            }
                            .padding()
                        }
                        .alert(isPresented: $showingResetPasswordAlert) {
                            Alert(title: Text("Reset Password"), message: Text(resetPasswordAlertMessage), dismissButton: .default(Text("OK")))
                        }
                    }
                    .padding(.top, 15)

                    
                    Image("Line or").padding(.leading,-6)
                    
                    NavigationLink{
                        SignUpView()
                    } label: {
                        Text("Sign Up")
                            .fontWeight(.heavy)
                            .font(.title3)
                            .frame(width:300)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color(Color.customBlue))
                            .cornerRadius(11)
                    }.padding()
                    
                    
                    Text(" or sign in with").font(.title2)
                    
                    
                    HStack{
                        Button(action: {print("Apple")}){
                            Image("apple")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .foregroundColor(.black)
                        }.padding(.bottom,-150).padding()
                        
                        
                        Button(action: {print("Apple")}){
                            Image("google")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .foregroundColor(.black)
                        }.padding(.bottom,-150)
                        
                        
                        
                    }
                    
                }
                
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text("The supplied username or password is incorrect."), dismissButton: .default(Text("OK")))
            }
        }
    }
    func login() {
        Auth.auth().signIn(withEmail: username, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                self.showAlert = true
            } else if let result = result {
                let userUID = result.user.uid
                print("User UID: \(userUID)")
                fetchUserType(userUID: userUID) // Call fetchUserType after successful login
            }
        }
    }
    
    func fetchUserType(userUID: String) {
        let db = Firestore.firestore()
        let ref = db.collection("userType").whereField("authID", isEqualTo: userUID)

        ref.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if let querySnapshot = querySnapshot, let document = querySnapshot.documents.first {
                // Assuming that each userUID will only have one userType document
                if let userTypeString = document.data()["user"] as? String {
                    print("User Type: \(userTypeString)")

                    // Update UserTypeManager with the fetched userType string
                    DispatchQueue.main.async {
                        self.userTypeManager.userType = UserType(rawValue: userTypeString) ?? .unknown
                        self.userTypeManager.userID = userUID
                    }
                } else {
                    print("User type not found for UID: \(userUID)")
                    DispatchQueue.main.async {
                        self.userTypeManager.userType = .unknown
                    }
                }
            }
        }
    }
    
    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.resetPasswordAlertMessage = error.localizedDescription
            } else {
                self.resetPasswordAlertMessage = "A link to reset your password has been sent to \(email)."
            }
            self.showingResetPasswordAlert = true // Show alert after the task completes
        }
    }

}

