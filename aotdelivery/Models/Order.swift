//
//  Order.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import Foundation

class Order: Codable {
    var id:String = ""
    var driverId: String = ""
    var orderDate: String = ""
    
    var accountName: String = ""
    var accountNotes: String = ""
    
    var senderName: String = ""
    var senderAddress: String = ""
    var senderSuite: String = ""
    var senderCity: String = ""
    var senderCountry: String = ""
    var senderPostalCode: String = ""
    var senderCellPhone: String = ""
    var senderHomePhone: String = ""
    var senderInstruction: String = ""
    
    var recipientName: String = ""
    var recipientAddress: String = ""
    var recipientSuite: String = ""
    var recipientCity: String = ""
    var recipientCountry: String = ""
    var recipientPostalCode: String = ""
    var recipientCellPhone: String = ""
    var recipientHomePhone: String = ""
    var recipientInstruction: String = ""
    
    var serviceName:String = ""
    var pickupDate:String = ""

    var status:String = ""
    
    var isShipperRelease:Bool = false
    var isSignatureRequired:Bool = false
    var isRoundTrip:Bool = false
    
    var requestor:String = ""
    var piece:String = ""
    var weight:String = ""
    var adminNotes:String = ""
    
    var signRoundTrip:String = ""

    var sender: Sender?
    var recipient: Recipient?
    
    var deliveryLat: String = ""
    var deliveryLong: String = ""
    
    var expectedDeliveryTime: String = ""
    var expectedPickupTime: String = ""
    
    var partialPiece: Int = 0
    var partialDeliver: Int = 0
    
    private var pieceAlt: String = ""
    
    enum CodingKeys:String, CodingKey {
        case id = "order_id"
        case driverId = "driver_id"
        case orderDate = "RDDateFormat"
        
        case accountName = "accountName"
        case accountNotes = "notes"
        
        case senderName = "company"
        case senderAddress = "address"
        case senderSuite = "suit"
        case senderCity = "city"
        case senderCountry = "state"
        case senderPostalCode = "zip"
        case senderCellPhone = "cellPhone"
        case senderHomePhone = "homePhone"
        case senderInstruction = "PUInstruction"
        
        case recipientName = "dlcompany"
        case recipientAddress = "dladdress"
        case recipientSuite = "dlsuit"
        case recipientCity = "dlcity"
        case recipientCountry = "dlstate"
        case recipientPostalCode = "dlzip"
        case recipientCellPhone = "dl_cellPhone"
        case recipientHomePhone = "dl_homePhone"
        case recipientInstruction = "DLInstruction"
        
        case serviceName = "serviceName"
        case pickupDate = "RDDate"
        
        case status = "orderStatus"
        
        case isShipperRelease = "shipper"
        case isSignatureRequired = "signature"
        case isRoundTrip = "isRoundTrip"
        
        case requestor = "requestor"
        case piece = "Piece"
        case pieceAlt = "piece"

        case weight = "weight"
        case adminNotes = "adminNotes"
        
        case sender = "PUAddress"
        case recipient = "DLAddress"
        
        case signRoundTrip = "SignRoundTrip"
        
        case deliveryLat = "dllat"
        case deliveryLong = "dllog"
        
        case expectedDeliveryTime = "EDDateFormat"
        
        case partialPiece = "partial_piece"
        case partialDeliver = "partial_deliver"
    }
    
    required init() {
        
    }
    
    required init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decodeIfPresent(XMLObject.self, forKey: .id)
        self.id = id?.text ?? "-"
        
        let driverId = try container.decodeIfPresent(XMLObject.self, forKey: .driverId)
        self.driverId = driverId?.text ?? "-"
        
        let orderDate = try container.decodeIfPresent(XMLObject.self, forKey: .orderDate)
        self.orderDate = orderDate?.text ?? "-"
        
        let accountName = try container.decodeIfPresent(XMLObject.self, forKey: .accountName)
        self.accountName = accountName?.text ?? "-"
        
        let accountNotes = try container.decodeIfPresent(XMLObject.self, forKey: .accountNotes)
        self.accountNotes = accountNotes?.text ?? "-"
        
        let senderName = try container.decodeIfPresent(XMLObject.self, forKey: .senderName)
        self.senderName = senderName?.text ?? "-"
        
        let senderAddress = try container.decodeIfPresent(XMLObject.self, forKey: .senderAddress)
        self.senderAddress = senderAddress?.text ?? "-"
        
        let senderSuite = try container.decodeIfPresent(XMLObject.self, forKey: .senderSuite)
        self.senderSuite = senderSuite?.text ?? "-"
        
        let senderCity = try container.decodeIfPresent(XMLObject.self, forKey: .senderCity)
        self.senderCity = senderCity?.text ?? "-"
        
        let senderCountry = try container.decodeIfPresent(XMLObject.self, forKey: .senderCountry)
        self.senderCountry = senderCountry?.text ?? "-"
        
        let senderPostalCode = try container.decodeIfPresent(XMLObject.self, forKey: .senderPostalCode)
        self.senderPostalCode = senderPostalCode?.text ?? "-"
        
        let senderInstruction = try container.decodeIfPresent(XMLObject.self, forKey: .senderInstruction)
        self.senderInstruction = senderInstruction?.text ?? "-"
        
        
        let recipientName = try container.decodeIfPresent(XMLObject.self, forKey: .recipientName)
        self.recipientName = recipientName?.text ?? "-"
        
        let recipientAddress = try container.decodeIfPresent(XMLObject.self, forKey: .recipientAddress)
        self.recipientAddress = recipientAddress?.text ?? "-"
        
        let recipientSuite = try container.decodeIfPresent(XMLObject.self, forKey: .recipientSuite)
        self.recipientSuite = recipientSuite?.text ?? "-"
        
        let recipientCity = try container.decodeIfPresent(XMLObject.self, forKey: .recipientCity)
        self.recipientCity = recipientCity?.text ?? "-"
        
        let recipientCountry = try container.decodeIfPresent(XMLObject.self, forKey: .recipientCountry)
        self.recipientCountry = recipientCountry?.text ?? "-"
        
        let recipientPostalCode = try container.decodeIfPresent(XMLObject.self, forKey: .recipientPostalCode)
        self.recipientPostalCode = recipientPostalCode?.text ?? "-"
        
        let recipientInstruction = try container.decodeIfPresent(XMLObject.self, forKey: .recipientInstruction)
        self.recipientInstruction = recipientInstruction?.text ?? "-"
        
        let serviceName = try container.decodeIfPresent(XMLObject.self, forKey: .serviceName)
        self.serviceName = serviceName?.text ?? "-"
        
        let pickupDate = try container.decodeIfPresent(XMLObject.self, forKey: .pickupDate)
        self.pickupDate = pickupDate?.text ?? "-"
        
        
        let isShipperRelease = try container.decodeIfPresent(XMLObject.self, forKey: .isShipperRelease)
        self.isShipperRelease = (isShipperRelease?.text == "0") ? false : true
        
        let isSignatureRequired = try container.decodeIfPresent(XMLObject.self, forKey: .isSignatureRequired)
        self.isSignatureRequired = (isSignatureRequired?.text == "0") ? false : true
        
        let isRoundTrip = try container.decodeIfPresent(XMLObject.self, forKey: .isRoundTrip)
        self.isRoundTrip = (isRoundTrip?.text == "0") ? false : true
        
        let requestor = try container.decodeIfPresent(XMLObject.self, forKey: .requestor)
        self.requestor = requestor?.text ?? "-"
        
        if let piece = try container.decodeIfPresent(XMLObject.self, forKey: .piece){
            self.piece = piece.text ?? "-"
        }else{
            let pieceAlt = try container.decodeIfPresent(XMLObject.self, forKey: .pieceAlt)
            self.piece = pieceAlt?.text ?? "-"
        }
        
        let weight = try container.decodeIfPresent(XMLObject.self, forKey: .weight)
        self.weight = weight?.text ?? "-"
        
        let adminNotes = try container.decodeIfPresent(XMLObject.self, forKey: .adminNotes)
        self.adminNotes = adminNotes?.text ?? "-"
        
        if let status = try container.decodeIfPresent(XMLObject.self, forKey: .status){
            self.status = status.text ?? ""
        }
        
        let sender = try container.decodeIfPresent(Sender.self, forKey: .sender)
        self.sender = sender
        
        let recipient = try container.decodeIfPresent(Recipient.self, forKey: .recipient)
        self.recipient = recipient
        
        let signRoundTrip = try container.decodeIfPresent(XMLObject.self, forKey: .signRoundTrip)
        self.signRoundTrip = (signRoundTrip?.text == "null") ? "" : (signRoundTrip?.text ?? "")
        
        let deliveryLong = try container.decodeIfPresent(XMLObject.self, forKey: .deliveryLong)
        self.deliveryLong = deliveryLong?.text ?? ""
        
        let deliveryLat = try container.decodeIfPresent(XMLObject.self, forKey: .deliveryLat)
        self.deliveryLat = deliveryLat?.text ?? ""
        
        let expectedPickupTime = try container.decodeIfPresent(XMLObject.self, forKey: .orderDate)
        self.expectedPickupTime = expectedPickupTime?.text ?? ""
        
        let expectedDeliveryTime = try container.decodeIfPresent(XMLObject.self, forKey: .expectedDeliveryTime)
        self.expectedDeliveryTime = expectedDeliveryTime?.text ?? ""
        
        let partialPiece = try container.decodeIfPresent(XMLObject.self, forKey: .partialPiece)
        self.partialPiece = Int(partialPiece?.text ?? "0")!
        
        let partialDeliver = try container.decodeIfPresent(XMLObject.self, forKey: .partialDeliver)
        self.partialDeliver = Int(partialDeliver?.text ?? "0")!
    }
}

struct XMLObject: Codable{
    var text:String?
    
    enum CodingKeys:String, CodingKey {
        case text = "text"
    }
}
