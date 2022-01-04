//
//  APIService.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import Foundation
import Alamofire
import SwiftyJSON
import SWXMLHash
import XMLReader

class APIService{
    static let shared = APIService()
    
    func get(url:String, params:[String:Any], completion:@escaping(_ response:JSON?,_ error:String?)->Void){
//        print(NetworkReachabilityManager())
        
        let url = String(format: "%@%@", arguments: [Network.BASE_URL, url])
        
        self.doPrettyPrint(url: url, params: params)
        
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding(destination: .queryString, arrayEncoding: .noBrackets, boolEncoding: .literal), headers: nil).responseData { (response) in
            do{
                let xmlStr = try XMLReader.dictionary(forXMLData: response.data)
                let jsonData = try JSONSerialization.data(withJSONObject: xmlStr, options: .prettyPrinted)
                let response = JSON(jsonData)
                print(response)
                
                if let error = response["error"]["text"].string{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UNAUTHORIZED"), object: nil)
                    completion(nil, error)
                    return
                }
                
                completion(response, nil)
            }catch (let err){
                print(err)
                completion(nil, err.localizedDescription)
            }
        }
    }
    
    func getJSON(url:String, params:[String:Any], completion:@escaping(_ response:JSON?,_ error:String?)->Void){
//        print(NetworkReachabilityManager())
        
        let url = String(format: "%@%@", arguments: [Network.BASE_URL, url])
        
        self.doPrettyPrint(url: url, params: params)
        
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding(destination: .queryString, arrayEncoding: .noBrackets, boolEncoding: .literal), headers: nil).responseData { (response) in
            do{
                let response = JSON(response.data!)
                print(response)
                
                if let error = response["error"]["text"].string{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UNAUTHORIZED"), object: nil)
                    completion(nil, error)
                    return
                }
                
                completion(response, nil)
            }catch (let err){
                print(err)
                completion(nil, err.localizedDescription)
            }
        }
    }
    
    func post(url:String, params:[String:Any], completion:@escaping(_ response:JSON?,_ error:String?)->Void){
        let url = String(format: "%@%@", arguments: [Network.BASE_URL, url])
        
        self.doPrettyPrint(url: url, params: params)
        
        AF.request(url, method: .post, parameters: params, encoding: URLEncoding(destination: .queryString, arrayEncoding: .noBrackets, boolEncoding: .literal), headers: nil).responseData { (response) in
            do{
                let xmlStr = try XMLReader.dictionary(forXMLData: response.data)
                let jsonData = try JSONSerialization.data(withJSONObject: xmlStr, options: .prettyPrinted)
                let response = JSON(jsonData)
                print(response)
                
                if let error = response["error"]["text"].string{
                    completion(nil, error)
                    return
                }
                
                completion(response, nil)
            }catch (let err){
                print(err)
                completion(nil, err.localizedDescription)
            }
        }
    }
    
    func doPrettyPrint(url:String, params:[String:Any]){
        print(url)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: JSON(params).rawValue, options: .prettyPrinted)
            let params = String(decoding: jsonData, as: UTF8.self)
            print(params)
        } catch let(err){
            print(err)
        }
    }
}
