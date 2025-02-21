import Foundation

struct PatientModel: Hashable, Codable, Identifiable {
    var id: String?
    var name: String?
    var height: Float?
    var weight: Float?
    var bloodGroup: BloodGroup?
    var address: String?
    var contact: String?
    var email: String?
    var emergencyContact: String?
    var gender: Gender?

    enum Gender: String, CaseIterable, Codable {
        case male = "Male"
        case female = "Female"
        case others = "Others"
    }

    enum BloodGroup: String, CaseIterable, Codable {
        case APositive = "A+"
        case ANegative = "A-"
        case BPositive = "B+"
        case BNegative = "B-"
        case ABPositive = "AB+"
        case ABNegative = "AB-"
        case OPositive = "O+"
        case ONegative = "O-"
    }

    init(id: String? = nil, name: String? = nil, height: Float? = nil, weight: Float? = nil, bloodGroup: BloodGroup? = nil, address: String? = nil, contact: String? = nil, email: String? = nil, emergencyContact: String? = nil, gender: Gender? = nil) {
        self.id = id
        self.name = name
        self.height = height
        self.weight = weight
        self.bloodGroup = bloodGroup
        self.address = address
        self.contact = contact
        self.email = email
        self.emergencyContact = emergencyContact
        self.gender = gender
    }

    // Initializer to create a PatientModel from a dictionary (like Firebase Firestore data)
    init?(dictionary: [String: Any], id: String) {
        self.id = id
        self.name = dictionary["name"] as? String
        self.height = (dictionary["height"] as? NSNumber)?.floatValue
        self.weight = (dictionary["weight"] as? NSNumber)?.floatValue
        self.bloodGroup = BloodGroup(rawValue: dictionary["bloodGroup"] as? String ?? "")
        self.address = dictionary["address"] as? String
        self.contact = dictionary["contact"] as? String
        self.email = dictionary["email"] as? String
        self.emergencyContact = dictionary["emergencyContact"] as? String

        if let genderString = dictionary["gender"] as? String {
            self.gender = Gender(rawValue: genderString)
        }
    }
}

