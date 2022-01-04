//
//  AuthViewModel.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON

class AuthViewModel {
    static let shared = AuthViewModel()
    
    let isSuccess = PublishSubject<Bool>()
    let errMsg = PublishSubject<String>()
    
    func login(userId:String, password:String){
        let url = "/Login.php";
        let params = [
            "user_id": userId,
            "password": password
        ]
        
        APIService.shared.post(url: url, params: params) { (json, errMsg) in
            if let errMsg = errMsg {
                self.errMsg.onNext(errMsg)
                return
            }
                        
            do{
                let response = json!["user-info"]
                let user = User(id: response["user_id"]["text"].stringValue, name: response["Name"]["text"].stringValue, role: response["roleName"]["text"].stringValue, location: response["locationName"]["text"].stringValue)
                try UserDefaultHelper.shared.setupUser(data: JSONEncoder().encode(user))
                self.isSuccess.onNext(true)
            }catch (let err){
                self.errMsg.onNext(err.localizedDescription)
                return
            }
            
        }
    }
}
