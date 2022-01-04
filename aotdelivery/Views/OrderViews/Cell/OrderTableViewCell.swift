//
//  OrderTableViewCell.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import UIKit

protocol OrderCellDelegate {
    func didSelectItem(order:Order)
}

class OrderTableViewCell: UITableViewCell {
    @IBOutlet var orderIdL: UILabel!
    @IBOutlet var orderDateL: UILabel!
    @IBOutlet var statusL: UILabel!
    @IBOutlet var senderNameL: UILabel!
    @IBOutlet var senderAddressL: UILabel!
    @IBOutlet var recepientNameL: UILabel!
    @IBOutlet var recepientAddressL: UILabel!
    @IBOutlet var expectedPickupTimeL: UILabel!
    @IBOutlet var expectedDeliveryTimeL: UILabel!
    
    @IBOutlet var statusV: UIView!
    
    @IBOutlet var roundTripIconContainerV: RoundedView!
    @IBOutlet var selectBtnV: UIView!
    @IBOutlet var selectL: UILabel!
    
    var delegate:OrderCellDelegate?
    var order:Order?
    
    /// Is Select Varaible for Dispatch & Open Order
    var isSelect = false {
        didSet{
            if (self.isSelect){
                guard let order = order else {return}
                
                switch order.status {
                case Status.DISPATCHED:
                    self.selectL.text = "Confirmed"
                    self.selectBtnV.backgroundColor = Colors.DISPATCH_COLOR
                case Status.OPEN_ORDER:
                    self.selectL.text = order.status
                    self.selectBtnV.backgroundColor = Colors.PICKED_UP_COLOR
                    self.selectBtnV.layer.borderColor = Colors.PICKED_UP_COLOR.cgColor
                default:
                    break
                }
                
                self.selectL.textColor = .white
                return
            }
            
            guard let order = order else {return}
            switch order.status {
            case Status.DISPATCHED:
                self.selectL.text = "Confirm"
                self.selectBtnV.backgroundColor = .clear
                self.selectL.textColor = Colors.DISPATCH_COLOR
            case Status.OPEN_ORDER:
                self.selectL.text = order.status
                self.selectBtnV.backgroundColor = Colors.PRIMARY_COLOR
                self.selectL.textColor = .white
            default:
                break
            }
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.selectBtnV.layer.borderWidth = 1
        self.selectBtnV.layer.borderColor = Colors.DISPATCH_COLOR.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.statusV.layer.cornerRadius = self.statusV.frame.height/2
        self.selectBtnV.layer.cornerRadius = self.selectBtnV.frame.height/2
    }
    
    func configure(order: Order){
        
        orderIdL.text = String(format: "#%@", order.id)
        orderDateL.text = order.orderDate
        statusL.text = order.status

        senderNameL.text = order.senderName
        senderAddressL.text = order.senderAddress

        recepientNameL.text = order.recipientName
        recepientAddressL.text = order.recipientAddress
        
        /// Hide/ show round trip icon container view
        roundTripIconContainerV.isHidden = !order.isRoundTrip
        
        /// Setup Button Label except for Dispatch Order
        if order.status != Status.DISPATCHED{
            selectL.text = order.status
            /// Do When Order is Partial Pickup
            if order.status == Status.PICKED_UP,
               order.partialPiece > 0,
               order.partialPiece < Int(order.piece)! {
                selectL.text = "Picked \(order.partialPiece)/\(order.piece)"
            }
            
            if order.status == Status.DELIVERED,
               order.partialDeliver > 0,
               order.partialDeliver < Int(order.piece)! {
                selectL.text = "Delivered \(order.partialDeliver)/\(order.piece)"
            }
        }
        
        if order.senderName == "CORAM OF EL PASO"{
            expectedPickupTimeL.text = "Exp. Pickup Time: \(order.expectedPickupTime)"
            expectedDeliveryTimeL.text = "Exp. Delivery Time: \(order.expectedDeliveryTime)"
            
            expectedPickupTimeL.isHidden = false
            expectedDeliveryTimeL.isHidden = false
        }else{
            expectedPickupTimeL.isHidden = true
            expectedDeliveryTimeL.isHidden = true
        }
        
        switch order.status {
        case Status.OPEN_ORDER:
            selectBtnV.layer.borderColor = Colors.OPEN_COLOR.cgColor
            selectBtnV.backgroundColor = Colors.OPEN_COLOR
            roundTripIconContainerV.backgroundColor = Colors.OPEN_COLOR
        case Status.PICKED_UP:
            selectBtnV.layer.borderColor = Colors.PICKED_UP_COLOR.cgColor
            selectBtnV.backgroundColor = Colors.PICKED_UP_COLOR
            roundTripIconContainerV.backgroundColor = Colors.PICKED_UP_COLOR
            
            if order.partialPiece > 0,
                order.partialPiece < Int(order.piece)! {
                selectBtnV.layer.borderColor = Colors.ROUND_TRIP_COLOR.cgColor
                selectBtnV.backgroundColor = Colors.ROUND_TRIP_COLOR
            }
        case Status.DELIVERED:
            selectBtnV.layer.borderColor = Colors.DELIVERED_COLOR.cgColor
            selectBtnV.backgroundColor = Colors.DELIVERED_COLOR
            roundTripIconContainerV.backgroundColor = Colors.DELIVERED_COLOR
            
            if order.isRoundTrip{
                selectBtnV.layer.borderColor = Colors.ROUND_TRIP_COLOR.cgColor
                selectBtnV.backgroundColor = Colors.ROUND_TRIP_COLOR
                roundTripIconContainerV.backgroundColor = Colors.ROUND_TRIP_COLOR
            }
            
            if order.signRoundTrip != ""{
                selectBtnV.layer.borderColor = Colors.COMPLETED_COLOR.cgColor
                selectBtnV.backgroundColor = Colors.COMPLETED_COLOR
                roundTripIconContainerV.backgroundColor = Colors.COMPLETED_COLOR
            }
        default:
            break
        }
    }
    
    @IBAction func openMapsAction(_ sender: Any) {
        guard let order = order else { return }
        
        var longitude = order.deliveryLong
        var latitude = order.deliveryLat
        
        if let recipient = order.recipient {
            if latitude == ""{
                latitude = recipient.latitude
            }
            
            if longitude == ""{
                longitude = recipient.longitude
            }
        }
        
        let url = "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving"
        
        if let url = URL(string: url){
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func selectAction(_ sender: Any) {
        if let order = self.order {
            self.delegate?.didSelectItem(order: order)
        }
    }
}
