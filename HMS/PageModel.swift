//
//  PageModel.swift
//  HMS
//


import Foundation


struct Page: Identifiable,Equatable {
    let id = UUID()
    var name: String
    var description: String
    var imageUrl: String
    var tag: Int
    
   static var samplePage = Page(name: "This is a Sample Page", description: "this os a sample description", imageUrl: "ob1", tag: 0)
    
    static var samplePages: [Page] = [
    Page(name: "Welcome to HMS App", description: "The best App for Your Hospital Management", imageUrl: "ob1", tag: 0),
    Page(name: "Book Appointments", description: "Fastest way to Book Appoitment", imageUrl: "ob2", tag: 1),
    Page(name: "Vitals", description: "You can see your everyday vitals", imageUrl: "ob3", tag: 2)
    ]
    
}
