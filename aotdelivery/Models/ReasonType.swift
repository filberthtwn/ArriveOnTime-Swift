//
//  ReasonType.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 20/11/21.
//

import Foundation

class ReasonType: Codable{
    var id: String = "-1"
    var reason: String = ""
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case reason = "reason"
    }
}
