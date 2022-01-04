//
//  OrderViewModel.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import Foundation
import RxSwift
import RxCocoa

class OrderViewModel {
    
    let isSuccess = PublishSubject<Bool>()
    let errMsg = PublishSubject<String>()
    
    let orders = PublishSubject<[Order]>()
    let order = PublishSubject<Order>()
    
    let reasonTypes = PublishSubject<[ReasonType]>()
    
    func updateOrderPickup(orderIds: [String]){
        guard let user = UserDefaultHelper.shared.getUser() else {
            self.errMsg.onNext("User missing")
            return
        }
        
        let url = "/updateOrderPickup.php";
        let params = [
            "driver_Id": user.id,
            "roleName": user.role,
            "order_ids": orderIds.joined(separator: ","),
            "datetime": DateFormatterHelper.shared.formatDate(dateFormat: "yyyy-MM-dd HH:mm:ss", date: Date(), timezone: TimeZone(identifier: "America/Chicago"))
        ]
        
        print(params)
        
        APIService.shared.post(url: url, params: params) { (json, errMsg) in
            if let errMsg = errMsg {
                self.errMsg.onNext(errMsg)
                return
            }

            if (json!["error"].exists()){
                self.errMsg.onNext(json!["error"]["text"].stringValue)
                return
            }
            self.isSuccess.onNext(true)
        }
    }
    
    func updateOrderPartialPickup(orderId: String, partialPiece: Int){
        guard let user = UserDefaultHelper.shared.getUser() else {
            self.errMsg.onNext("User missing")
            return
        }
        
        let url = "/updateOrderPickup.php";
        let params:[String: Any] = [
            "driver_Id": user.id,
            "roleName": user.role,
            "partial_piece": partialPiece,
            "order_ids": orderId,
            "datetime": DateFormatterHelper.shared.formatDate(dateFormat: "yyyy-MM-dd HH:mm:ss", date: Date(), timezone: TimeZone(identifier: "America/Chicago"))
        ]
        
        print(params)
        
        APIService.shared.post(url: url, params: params) { (json, errMsg) in
            if let errMsg = errMsg {
                self.errMsg.onNext(errMsg)
                return
            }

            if (json!["error"].exists()){
                self.errMsg.onNext(json!["error"]["text"].stringValue)
                return
            }
            self.isSuccess.onNext(true)
        }
    }
    
    func updateOrderToDeliver(order: Order, updatedOrder: UpdatedOrder){
        guard let user = UserDefaultHelper.shared.getUser() else {
            self.errMsg.onNext("User missing")
            return
        }
        
        let url = "/updateOrderDeliveryMobile.php";
        let params = [
            "driver_Id": user.id,
            "roleName": "driver",
            "order_id": updatedOrder.id,
            "waittime": updatedOrder.waitTime,
            "transportation": updatedOrder.transportation.lowercased(),
            "boxes": order.piece,
            "lastname": updatedOrder.lastName,
            "isRoundTrip": updatedOrder.isRoundTrip.lowercased(),
            "roundTrip": updatedOrder.isRoundTrip.lowercased(),
            "notes": createSummaryNotes(lastName: updatedOrder.lastName, isLiveHere: updatedOrder.isLiveHere, relationship: updatedOrder.recepientRelationship),
            "filename": updatedOrder.fileName,
            "datetime": DateFormatterHelper.shared.formatDate(dateFormat: "yyyy-MM-dd HH:mm:ss", date: Date(), timezone: TimeZone(identifier: "America/Chicago")),
            "reason_type": updatedOrder.reasonType,
            "partial_deliver": updatedOrder.numOfBoxes
        ] as [String : Any]
        
        print(params)
        
        APIService.shared.post(url: url, params: params) { (json, errMsg) in
            if let errMsg = errMsg {
                self.errMsg.onNext(errMsg)
                return
            }

            self.isSuccess.onNext(true)
        }
    }
    
    func updateOrderToRoundTrip(order: UpdatedOrder){
        guard let user = UserDefaultHelper.shared.getUser() else {
            self.errMsg.onNext("User missing")
            return
        }
        
        let url = "/updateRoundTripOrderPickup.php";
        let params = [
            "driver_Id": user.id,
            "roleName": "driver",
            "order_id": order.id,
            "waittime": order.waitTime,
            "transportation": order.transportation.lowercased(),
            "boxes": order.numOfBoxes,
            "isRoundTrip": "yes",
            "roundTrip": "yes",
            "datetime": DateFormatterHelper.shared.formatDate(dateFormat: "yyyy-MM-dd HH:mm:ss", date: Date(), timezone: TimeZone(identifier: "America/Chicago")),
            "reason_type": order.reasonType
        ] as [String : Any]
        
        print(params)
        
        APIService.shared.post(url: url, params: params) { (json, errMsg) in
            if let errMsg = errMsg {
                self.errMsg.onNext(errMsg)
                return
            }
            
            self.isSuccess.onNext(true)
        }
    }
    
    func updateOrderToComplete(order: UpdatedOrder){
        guard let user = UserDefaultHelper.shared.getUser() else {
            self.errMsg.onNext("User missing")
            return
        }
        
        let url = "/updateRoundTripOrderDeliveryNew.php";
        let params = [
            "driver_Id": user.id,
            "lastname": order.lastName,
            "roleName": "driver",
            "order_id": order.id,
            "notes": createSummaryNotes(lastName: order.lastName, isLiveHere: order.isLiveHere, relationship: order.recepientRelationship),
            "fileName": order.fileName,
            "datetime": DateFormatterHelper.shared.formatDate(dateFormat: "yyyy-MM-dd HH:mm:ss", date: Date(), timezone: TimeZone(identifier: "America/Chicago")),
            "reason_type": order.reasonType
        ] as [String : Any]
        
        print(params)
        
        APIService.shared.post(url: url, params: params) { (json, errMsg) in
            if let errMsg = errMsg {
                self.errMsg.onNext(errMsg)
                return
            }
            self.isSuccess.onNext(true)
        }
    }
    
    func cofirmDispatchOrder(orderIds: [String]){
        guard let user = UserDefaultHelper.shared.getUser() else {
            self.errMsg.onNext("User missing")
            return
        }
        
        let url = "/updateNewDispatches.php";
        let params = [
            "driver_id": user.id,
            "roleName": user.role,
            "order_ids": orderIds.joined(separator: ","),
        ]
        
        print(params)
        
        APIService.shared.post(url: url, params: params) { (json, errMsg) in
            if let errMsg = errMsg {
                self.errMsg.onNext(errMsg)
                return
            }

            if (json!["error"].exists()){
                self.errMsg.onNext(json!["error"]["text"].stringValue)
                return
            }
            self.isSuccess.onNext(true)
        }
    }
    
    func getAllOrder(orderType: String, device:String?){
        guard let user = UserDefaultHelper.shared.getUser() else {
            self.errMsg.onNext("User missing")
            return
        }
        
        let url = "/getOrders.php";
        var params = [
            "user_id": user.id,
            "roleName": user.role,
            "forDate": orderType,
        ]
        
        if let device = device {
            params["device"] = device
        }
        
        APIService.shared.get(url: url, params: params) { (json, errMsg) in
            if let errMsg = errMsg {
                self.errMsg.onNext(errMsg)
                return
            }
                        
            do{
                let response = json!["dispatches-info"]
                var orders:[Order] = []
                
                if (!response["order"].exists())  {
                    self.orders.onNext([])
                    return
                }
                
                if response["order"].array != nil {
                    orders = try JSONDecoder().decode([Order].self, from: response["order"].rawData())
                    self.orders.onNext(orders)
                    return
                }
                
                let order = try JSONDecoder().decode(Order.self, from: response["order"].rawData())
                self.orders.onNext([order])
            }catch (let err){
                print(err)
                self.errMsg.onNext(err.localizedDescription)
                return
            }
            
        }
    }
    
    func getOrderDetail(orderId:String){
        guard let user = UserDefaultHelper.shared.getUser() else {
            self.errMsg.onNext("User missing")
            return
        }
        
        let url = "/getOrderDetails.php";
        let params = [
            "order_id": orderId,
            "roleName": user.role,
        ]
        
        APIService.shared.get(url: url, params: params) { (json, errMsg) in
            if let errMsg = errMsg {
                self.errMsg.onNext(errMsg)
                return
            }
                        
            do{
                if !json!["order-details"].exists() {
                    self.errMsg.onNext("Order not found")
                    return
                }

                let order = try JSONDecoder().decode(Order.self, from: json!["order-details"].rawData())
                self.order.onNext(order)
            }catch (let err){
                print(err)
                self.errMsg.onNext(err.localizedDescription)
                return
            }
            
        }
    }
    
    func getAllOrderDispatch(){
        guard let user = UserDefaultHelper.shared.getUser() else {
            self.errMsg.onNext("User missing")
            return
        }
        
        let url = "/getNewOfflineDispatches.php?";
        let params = [
            "user_id": user.id,
            "roleName": user.role
        ]
        
        APIService.shared.get(url: url, params: params) { (json, errMsg) in
            if let errMsg = errMsg {
                self.errMsg.onNext(errMsg)
                return
            }
                        
            do{
                let response = json!["dispatches-info"]
                var orders:[Order] = []

                if (!response["order"].exists())  {
                    self.orders.onNext([])
                    return
                }

                if response["order"].array != nil {
                    orders = try JSONDecoder().decode([Order].self, from: response["order"].rawData())
                    self.orders.onNext(orders)
                    return
                }

                let order = try JSONDecoder().decode(Order.self, from: response["order"].rawData())
                self.orders.onNext([order])
            }catch (let err){
                print(err)
                self.errMsg.onNext(err.localizedDescription)
                return
            }
            
        }
    }
    
    func getReasonType(){
        let url = "/getReasonType.php";
        
        APIService.shared.getJSON(url: url, params: [:]) { (json, errMsg) in
            if let errMsg = errMsg {
                self.errMsg.onNext(errMsg)
                return
            }
                        
            do{
                let response = json!["data"]
                let reasonType = try JSONDecoder().decode([ReasonType].self, from: response.rawData())
                self.reasonTypes.onNext(reasonType)
            }catch (let err){
                print(err)
                self.errMsg.onNext(err.localizedDescription)
                return
            }
            
        }
    }
    
    private func createSummaryNotes(lastName: String, isLiveHere: String, relationship: String) -> String {
        return String(format: "Does %@ live here: %@ What is your relationship to the patient: %@", lastName, isLiveHere, relationship)
    }
}
