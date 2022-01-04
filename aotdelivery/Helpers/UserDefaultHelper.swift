//
//  UserDefaultHelper.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import Foundation

class UserDefaultHelper{
    static let shared = UserDefaultHelper()
    
    func setupUser(data:Data){
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "current_user")
        userDefaults.synchronize()
    }
    
    func getUser()->User?{
        if let data = UserDefaults.standard.data(forKey: "current_user"){
            do {
                return try JSONDecoder().decode(User.self, from: data)
            }catch(let error){
                print(error)
                return nil
            }
        }
        return nil
    }
    
    func deleteUser(){
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "current_user")
        userDefaults.synchronize()
    }
}
