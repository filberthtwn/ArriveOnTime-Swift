//
//  OrderType.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import Foundation

//struct OrderType{
//    static let DELIVERED = "Delivered"
//    static let PRESENT = "Present"
//    static let DISPATCH = "Dispatch"
//    static let OPEN = "Open/Next Day"
//}

enum OrderType{
    case DELIVER
    case PRESENT
    case DISPATCH
    case OPEN
    case FUTURE
    case PARTIAL
}
