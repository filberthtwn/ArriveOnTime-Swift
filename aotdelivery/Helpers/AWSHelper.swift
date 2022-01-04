//
//  AWSHelper.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 20/11/21.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import AWSS3

class AWSHelper{
    static let shared = AWSHelper()
    
    let fileName = PublishSubject<String>()
    let errorMsg = PublishSubject<String>()
    private let bucketName = "aot2021"
    
    func uploadImage(order: UpdatedOrder, folder:String, image: UIImage){
        /// Save Image Temporary
        guard let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TempImage.png") else { return }
        
        do {
            try image.jpegData(compressionQuality: 0.25)?.write(to: imageURL)
            
            let year = Calendar.current.component(.year, from: Date())
            let month = Calendar.current.component(.month, from: Date())
                        
            var fileName = order.id
            switch order.status {
                case Status.PICKED_UP:
                    fileName = String(format: "dl%@", order.id)
                case Status.DELIVERED:
                    fileName = String(format: "rt%@", order.id)
                default:
                    break
            }
            
            let key = String(format: "public/aotfiles/%d/%d/%@/%@.jpg", year, month, folder, fileName)
            
            AWSS3TransferUtility.default().uploadFile(imageURL, bucket: bucketName, key: key, contentType: "image/jpeg", expression: nil) { task, error in
                if(error != nil){ return }
                print("(DEBUG) IMAGE UPLOADED")
                self.fileName.onNext(key.replacingOccurrences(of: "public/", with: ""))
            }
        } catch (let error) {
            print(error)
            errorMsg.onNext(error.localizedDescription)
        }
    }
}
