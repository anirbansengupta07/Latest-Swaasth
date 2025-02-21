//
//  DoctorModel.swift
//  HMS
//


import Foundation
import UIKit

struct DoctorModel: Hashable, Codable, Identifiable {
    var id: String?
    var name: String
    var department: String
    var email: String
    var contact: String
    var experience: String
    var employeeID: String
    var image: String
    var specialisation: String
    var degree: String
    var cabinNumber: String
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case department
        case email
        case contact
        case experience
        case employeeID = "DocID"
        case image
        case specialisation
        case degree
        case cabinNumber = "cabin"
    }
    
    enum Specialization: String, Codable {
        case Cardiologist = "Cardiologist"
        case Orthopedic = "Orthopedic"
        case Endocrinologist = "Endocrinologist"
        case Gastroenterologist = "Gastroenterologist"
        case Hematologist = "Hematologist"
        case Neurologist = "Neurologist"
        case Oncologist = "Oncologist"
        case Orthopedist = "Orthopedist"
        case Pediatrician = "Pediatrician"
        case Psychiatrist = "Psychiatrist"
        case Pulmonologist = "Pulmonologist"
        case Rheumatologist = "Rheumatologist"
        case Urologist = "Urologist"
        case Ophthalmologist = "Ophthalmologist"
        case Gynecologist = "Gynecologist"
    }
    
    init(id: String? = nil, name: String, department: String, email: String, contact: String, experience: String, employeeID: String, image: String, specialisation: String, degree: String, cabinNumber: String) {
        self.id = id
        self.name = name
        self.department = department
        self.email = email
        self.contact = contact
        self.experience = experience
        self.employeeID = employeeID
        self.image = image
        self.specialisation = specialisation
        self.degree = degree
        self.cabinNumber = cabinNumber
    }
    
    // Existing initializer for dictionary data - keep if needed
    init(from dictionary: [String: Any], id: String) {
        self.id = id
        self.name = dictionary["name"] as? String ?? ""
        self.department = dictionary["department"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.contact = dictionary["contact"] as? String ?? ""
        self.experience = dictionary["experience"] as? String ?? ""
        self.employeeID = dictionary["DocID"] as? String ?? ""
        self.image = dictionary["image"] as? String ?? ""
        self.specialisation = dictionary["specialisation"] as? String ?? ""
        self.degree = dictionary["degree"] as? String ?? ""
        self.cabinNumber = dictionary["cabin"] as? String ?? ""
    }
    
}
