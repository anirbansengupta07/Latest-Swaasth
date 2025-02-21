import SwiftUI

struct DoctorProfileView: View {
    var doctor: DoctorModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ProfileHeader(doctor: doctor)
                    BadgeView(doctor: doctor)
                    CommunicationView(doctor: doctor)
                }
                .padding()
            }
            .background(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [Color.customBlue.opacity(0.5), Color.customBlue.opacity(1)]),
                                           startPoint: .top,
                                           endPoint: .bottom
                                       )
                                       .frame(height: geometry.size.height / 4)
                                       .edgesIgnoringSafeArea(.top)
                    Color.white
                        .frame(height: 2 * geometry.size.height / 3)
                        .offset(y: geometry.size.height / 3)
                        .edgesIgnoringSafeArea(.all)
                }
            )
            
                        
        }
        

    }
}

struct ProfileHeader: View {
    var doctor: DoctorModel
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                Spacer()
                if let url = URL(string: doctor.image) {
                    AsyncImage(url: url) { image in
                        image.resizable().clipShape(Circle()).frame(width: 120, height: 120)
                                            .foregroundColor(.blueShade)
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(11)
                }
            }
            Text(doctor.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text(doctor.degree)
                .font(.subheadline)
                .foregroundColor(.black)
        }
        .padding(.bottom)
    }
}

struct BadgeView: View {
    var doctor: DoctorModel
    
    var body: some View {
        let departmentImage: Image
        
        switch doctor.department {
        case "Cardiology":
            departmentImage = Image("cardiologyIcon")
        case "Neurology":
            departmentImage = Image("neurologyIcon")
        case "Oncology":
            departmentImage = Image("oncologyIcon")
        case "Orthopedics":
            departmentImage = Image("orthopedicsIcon")
        case "Endocrinilogy":
            departmentImage = Image("endocrinilogyIcon")
        case "Gastroenterology":
            departmentImage = Image("gastroenterologyIcon")
        case "Hematology":
            departmentImage = Image("hematologyIcon")
        case "Pediatrics":
            departmentImage = Image("pediatricsIcon")
        case "Psychiatry":
            departmentImage = Image("psychiatryIcon")
        case "Pulmonology":
            departmentImage = Image("pulmonologyIcon")
        case "Rheumatology":
            departmentImage = Image("rheumatologyIcon")
        case "Urology":
            departmentImage = Image("urologyIcon")
        case "Ophthamology":
            departmentImage = Image("ophthamologyIcon")
        
        
        default:
            departmentImage = Image(systemName: "questionmark")
        }
        
        return HStack(alignment: .top, spacing: 20) {
            VStack {
                ZStack{
                    departmentImage
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                .padding()
                
                Text(doctor.department)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.customBlue)
                Text("Department")
                    .foregroundColor(.black)
                    .font(.system(size: 14))

            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.bottom)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            VStack {
                ZStack{
                    Image("experienceIcon")
                        .resizable()
                        .foregroundColor(.blue)
                        .frame(width: 50, height: 50)
                }
                .padding()
                
                Text(doctor.experience)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.customBlue)
                Text("Experience")
                    .foregroundColor(.black)
                    .font(.system(size: 14))
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.bottom)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}


struct CommunicationView: View {
    var doctor: DoctorModel
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Communication")
                .font(.title2)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            HStack{
                ZStack{
                    Image("phoneIcon")
                        .resizable()
                        .frame(width: 40, height: 40)
                }

                .cornerRadius(10)
                VStack(alignment: .leading){
                    Text("Phone")
                        .font(.system(size: 16, weight: .semibold))
                    Text(doctor.contact)
                }
            }
            HStack{
                ZStack{
                    Image("mailIcon")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .cornerRadius(10)
                VStack(alignment: .leading){
                    Text("Email")
                        .font(.system(size: 16, weight: .semibold))
                    Text(doctor.email)
                }
                
            }
            HStack{
                ZStack{
                    Image("cabinIcon")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .cornerRadius(10)
                VStack(alignment: .leading){
                    Text("Cabin Number")
                        .font(.system(size: 16, weight: .semibold))
                    Text(doctor.cabinNumber)
                }
                
            }
        }
        .padding(.leading,-90)
    }
}

struct DoctorProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleDoctor = DoctorModel(
            id: "1",
            name: "Dr. John Doe",
            department: "Cardiology",
            email: "john.doe@example.com",
            contact: "+1234567890",
            experience: "10 Years",
            employeeID: "123456",
            image: "doctor_image",
            specialisation: "Cardiologist",
            degree: "MBBS, MD",
            cabinNumber: "A123"
        )
        return DoctorProfileView(doctor: sampleDoctor)
    }
}


