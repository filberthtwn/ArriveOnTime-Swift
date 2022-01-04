//
//  Sender.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 06/06/21.
//

import Foundation

class Sender: Codable{
    var name: String = ""
    var address:String = "-"
    var suite:String = "-"
    var city:String = "-"
    var country:String = "-"
    var postalCode:String = "-"
    var cellPhone:String = "-"
    var homePhone:String = "-"
    
    enum CodingKeys:String, CodingKey {
        case name = "company"
        case address = "address"
        case suite = "suit"
        case city = "city"
        case country = "state"
        case postalCode = "zip"
        case cellPhone = "cellPhone"
        case homePhone = "homePhone"
    }
    
    required init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let name = try container.decode(XMLObject.self, forKey: .name)
        self.name = name.text ?? "-"
        
        let address = try container.decode(XMLObject.self, forKey: .address)
        self.address = address.text ?? "-"
        
        let suite = try container.decode(XMLObject.self, forKey: .suite)
        self.suite = suite.text ?? "-"
        
        let city = try container.decode(XMLObject.self, forKey: .city)
        self.city = city.text ?? "-"
        
        let country = try container.decode(XMLObject.self, forKey: .country)
        self.country = country.text ?? "-"
        
        let postalCode = try container.decode(XMLObject.self, forKey: .postalCode)
        self.postalCode = postalCode.text ?? "-"
        
        let cellPhone = try container.decode(XMLObject.self, forKey: .cellPhone)
        self.cellPhone = cellPhone.text ?? "-"
        
        let senderHomePhone = try container.decode(XMLObject.self, forKey: .homePhone)
        self.homePhone = senderHomePhone.text ?? "-"
    }
}
