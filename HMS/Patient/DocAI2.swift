//
//  DocAI2.swift
//  HMS
//
//  Created by Anirban Sengupta on 23/10/24.
//
import Foundation
import GoogleGenerativeAI
import SwiftUI



enum DocAI2 {
    static var `default` : String {
        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        else {
            fatalError("Couldn't find file 'GoogleService-Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find 'API_KEY' in 'GoogleService-Info.plist'.")
        }
        if value.starts(with: "_") {
            fatalError("Follow these instructions at https://ai.google.dev/tutorials/setup to get an API key")
        }
        return value  
    }
}

