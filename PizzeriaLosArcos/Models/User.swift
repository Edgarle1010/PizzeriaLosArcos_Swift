//
//  User.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 09/01/22.
//

import Foundation

public struct User: Codable {
    let userId: String
    let name: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let streaks: Int
    let isBaned: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId
        case name
        case lastName
        case email
        case phoneNumber
        case streaks
        case isBaned
    }
    
    
}
