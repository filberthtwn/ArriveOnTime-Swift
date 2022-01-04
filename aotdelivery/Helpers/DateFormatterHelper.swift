//
//  DateFormatterHelper.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 25/05/21.
//

import Foundation
import UIKit

class DateFormatterHelper{
    static let shared = DateFormatterHelper()
    
    func formatDate(dateFormat:String, date:Date, timezone:TimeZone?)->String{
        let df = DateFormatter()
        df.dateFormat = dateFormat
        if let timezone = timezone{
            df.timeZone = timezone
        }
        df.locale = Locale.current
        
        return df.string(from: date)
    }
    
    func formatString(oldDateFormat:String, newDateFormat:String, dateString:String, timezone:TimeZone?)->String{
        let dfGet = DateFormatter()
        dfGet.dateFormat = oldDateFormat
        dfGet.timeZone = TimeZone(identifier: "UTC")
        let dateGet = dfGet.date(from: dateString)
        
        let dfPrint = DateFormatter()
        dfPrint.dateFormat = newDateFormat
        dfPrint.locale = Locale.current
        if let timezone = timezone{
            dfPrint.timeZone = timezone
        }
        
        return dfPrint.string(from: dateGet!)
    }
    
    func stringToDate(dateString:String, dateFormat:String, timezone:TimeZone?)->Date?{
        let df = DateFormatter()
        df.dateFormat = dateFormat
        if let timezone = timezone{
            df.timeZone = timezone
        }
        return df.date(from: dateString)
    }
    
//    func setupUser(data:Data){
//        let userDefaults = UserDefaults.standard
//        userDefaults.set(data, forKey: "current_user")
//        userDefaults.synchronize()
//    }
//
//    func getUser()->User?{
//        if let data = UserDefaults.standard.data(forKey: "current_user"){
//            do {
//                return try JSONDecoder().decode(User.self, from: data)
//            }catch(let error){
//                print(error)
//                return nil
//            }
//        }
//        return nil
//    }
//
//    func deleteUser(){
//        let userDefaults = UserDefaults.standard
//        userDefaults.removeObject(forKey: "current_user")
//        userDefaults.synchronize()
//    }
}
