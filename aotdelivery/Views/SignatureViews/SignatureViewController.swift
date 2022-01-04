//
//  SignatureViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 20/11/21.
//

import UIKit
import SwiftSignatureView
import AWSS3

class SignatureViewController: UIViewController {

    @IBOutlet var signatureV: SwiftSignatureView!
    
    private var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    
    var updatedOrder: UpdatedOrder?
    var order: Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews(){
        title = "Complete Order"
    }
    
    @IBAction func rewriteAction(_ sender: Any) {
        /// Clear signature view
        signatureV.clear()
    }
    
    @IBAction func finishAction(_ sender: Any) {
        let confirmationVC = ConfirmationViewController()
        confirmationVC.delegate = self
        confirmationVC.modalTransitionStyle = .crossDissolve
        confirmationVC.modalPresentationStyle = .overCurrentContext
        present(confirmationVC, animated: true, completion: nil)
    }
}

extension SignatureViewController: ConfirmationDelegate{
    func didYesAction() {
        guard let signature = signatureV.signature else { return }
        
        let updateOrderFormVC = UpdateOrderFormViewController()
        updateOrderFormVC.delegate = self
        updateOrderFormVC.order = order
        updateOrderFormVC.updatedOrder = updatedOrder
        updateOrderFormVC.signature = signature
        presentPanModal(updateOrderFormVC)
    }
}

extension SignatureViewController: UpdateOrderFormDelegate{
    func didUdpdateOrderSuccess() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func didDoPartialDeliver() {
        let confirmationVC = ConfirmationViewController()
        confirmationVC.delegate = self
        confirmationVC.modalTransitionStyle = .crossDissolve
        confirmationVC.modalPresentationStyle = .overFullScreen
        present(confirmationVC, animated: true, completion: nil)
    }
}
