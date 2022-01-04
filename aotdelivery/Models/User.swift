//
//  User.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import Foundation

struct User: Codable {
    var id:String = "-"
    var name:String = "-"
    var role:String = "-"
    var location:String = "-"
    
    enum CodingKeys:String, CodingKey {
        case id = "user_id"
        case name = "Name"
        case role = "roleName"
        case location = "locationName"
    }
}
