//
//  File.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 20/11/21.
//

import Foundation

class UpdatedOrder: Codable{
    var id: String = ""
    var lastName: String = ""
    var isLiveHere: String = ""
    var recepientRelationship: String = ""
    var fileName: String = ""
    var waitTime: Int = 0
    var numOfBoxes: Int = 0
    var transportation: String = ""
    var isRoundTrip: String = ""
    var reasonType: String = ""
    var status: String = ""
}
