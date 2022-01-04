//
//  NotifViewModel.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 26/05/21.
//

import Foundation
import RxSwift
import RxCocoa

class NotifViewModel {
    let errMsg = PublishSubject<String>()

    func getAllNotification(){
        guard let user = UserDefaultHelper.shared.getUser() else {
            self.errMsg.onNext("User missing")
            return
        }
        
        let url = "/notification.php?";
        let params = [
            "driver": user.id,
        ]
        
        APIService.shared.get(url: url, params: params) { (json, errMsg) in
            if let errMsg = errMsg {
                self.errMsg.onNext(errMsg)
                return
            }
                        
//            do{
//                let response = json!["dispatches-info"]
//                var orders:[Order] = []
//
//                if (!response["order"].exists())  {
//                    self.orders.onNext([])
//                    return
//                }
//
//                if response["order"].array != nil {
//                    orders = try JSONDecoder().decode([Order].self, from: response["order"].rawData())
//                    self.orders.onNext(orders)
//                    return
//                }
//
//                let order = try JSONDecoder().decode(Order.self, from: response["order"].rawData())
//                self.orders.onNext([order])
//            }catch (let err){
//                print(err)
//                self.errMsg.onNext(err.localizedDescription)
//                return
//            }
            
        }
    }
}
