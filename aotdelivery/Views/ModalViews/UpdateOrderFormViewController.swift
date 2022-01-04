//
//  UpdateDeliverModalViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 13/11/21.
//

import UIKit
import PanModal
import SVProgressHUD
import RxSwift

protocol UpdateOrderFormDelegate{
    func didDoPartialDeliver()
    func didUdpdateOrderSuccess()
}

class UpdateOrderFormViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    @IBOutlet var panHandleV: UIView!
    
    @IBOutlet var orderIdL: UILabel!
    
    @IBOutlet var reasonTypeSV: UIStackView!
    
    @IBOutlet var waitTimeTF: AOTTextField!
    @IBOutlet var boxesTF: AOTTextField!
    @IBOutlet var transportationTF: AOTTextField!
    @IBOutlet var isRoundTripTF: AOTTextField!
    @IBOutlet var reasonTypeTF: AOTTextField!
    
    @IBOutlet var isRoundTripSV: UIStackView!
    
    @IBOutlet var finishBtn: AOTButton!
    
    private let orderVM: OrderViewModel = OrderViewModel()
    private var disposeBag: DisposeBag = DisposeBag()
    private var transportations: [String] = ["Car", "Truck"]
    private var isRoundTrip: [String] = ["No", "Yes"]
    private var reasonTypes: [ReasonType] = []
    
    private let transportationPV = UIPickerView()
    private let isRoundTripPV = UIPickerView()
    private let reasonTypePV = UIPickerView()
    
    var delegate: UpdateOrderFormDelegate?
    var updatedOrder: UpdatedOrder?
    var order: Order?
    var signature: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupData()
        observeViewModel()
    }
    
    private func setupViews(){
        panHandleV.layer.cornerRadius = panHandleV.frame.height/2
        
        transportationPV.delegate = self
        transportationTF.text = transportations.first
        transportationTF.inputView = transportationPV
        transportationTF.setAsDropdown()
        
        isRoundTripPV.delegate = self
        isRoundTripTF.text = isRoundTrip.first
        isRoundTripTF.inputView = isRoundTripPV
        isRoundTripTF.setAsDropdown()
        
        reasonTypePV.delegate = self
        reasonTypeTF.inputView = reasonTypePV
        reasonTypeTF.tintColor = .clear
        reasonTypeTF.setAsDropdown()
        
        finishBtn.disable()
        
        waitTimeTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        boxesTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        /// Handle  from Pick Up to Deliver
        if let updatedOrder = updatedOrder{
            orderIdL.text = updatedOrder.id
        }
        
        /// Handle  from Deliver  to Round Trip
        if let order = self.order {
            orderIdL.text = order.id
            
            if order.status == Status.DELIVERED,
               order.partialDeliver == Int(order.piece)!{
                isRoundTripSV.isHidden = true
                panModalSetNeedsLayoutUpdate()
                return
            }
            
            /// When status is PICK UP, hide Reason Type Section as Default,
            if order.partialDeliver < Int(order.piece)!{
                reasonTypeSV.isHidden = true
                panModalSetNeedsLayoutUpdate()
            }
        }
    }
    
    private func setupData(){
        orderVM.getReasonType()
    }
    
    private func observeViewModel(){
        self.orderVM.reasonTypes.bind { (reasonTypes)  in
            self.reasonTypes = reasonTypes
            self.reasonTypePV.reloadAllComponents()
            
            self.reasonTypeTF.text = reasonTypes.first?.reason
        }.disposed(by: self.disposeBag)
        
        AWSHelper.shared.fileName.bind{ (fileName) in
            guard let updatedOrder = self.updatedOrder else { return }
            updatedOrder.fileName = String(fileName.split(separator: "/").last!)
            
            /// Handle Order from Round Trip to Delivered
            if let order = self.order, order.isRoundTrip{
                updatedOrder.isRoundTrip = order.isRoundTrip ? "yes" : "no"
                self.orderVM.updateOrderToComplete(order: updatedOrder)
                return
            }
            
            self.orderVM.updateOrderToDeliver(order: self.order!, updatedOrder: updatedOrder)
        }.disposed(by: self.disposeBag)
        
        self.orderVM.isSuccess.bind { (isSuccess)  in
            SVProgressHUD.showSuccess(withStatus: "Order updated successfully")
            SVProgressHUD.dismiss(withDelay: 1)
            
            self.dismiss(animated: true) {
                self.delegate?.didUdpdateOrderSuccess()
            }
        }.disposed(by: self.disposeBag)
        
        self.orderVM.errMsg.bind { (errMsg)  in
            SVProgressHUD.showError(withStatus: errMsg)
            SVProgressHUD.dismiss(withDelay: 1)
            
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: self.disposeBag)
    }
    
    private func isValid() -> Bool{
        if waitTimeTF.text!.isEmpty{
            return false
        }
        if boxesTF.text!.isEmpty{
            return false
        }
        return true
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField){
        finishBtn.disable()
        if !waitTimeTF.text!.isEmpty
            && !boxesTF.text!.isEmpty
            && reasonTypes.count > 0{
            finishBtn.enable()
        }
    }
    
    @IBAction func finishedAction(_ sender: Any) {
        
        if order!.status != Status.ROUND_TRIP{
            if order!.partialDeliver != Int(order!.piece)!,
               Int(boxesTF.text!)! > 0,
               Int(boxesTF.text!)! < Int(order!.piece)!{
                let confirmationVC = ConfirmationViewController()
                confirmationVC.delegate = self
                confirmationVC.subtitle = "You are delivering \(boxesTF.text!) out of 3 packages, Are you sure?"
                confirmationVC.modalTransitionStyle = .crossDissolve
                confirmationVC.modalPresentationStyle = .overFullScreen
                present(confirmationVC, animated: true, completion: nil)
                return
            }
        }
        
        if Int(boxesTF.text!)! != Int(order!.piece)!{
            SVProgressHUD.showError(withStatus: "Order Package Mismatch")
            SVProgressHUD.dismiss(withDelay: 1)
            return
        }
        
        /// Handle Order from Pickup to Deliver
        if let updatedOrder = updatedOrder {
            updatedOrder.waitTime = Int(waitTimeTF.text!)!
            updatedOrder.numOfBoxes = Int(boxesTF.text!)!
            updatedOrder.transportation = transportationTF.text!
            updatedOrder.isRoundTrip = isRoundTripTF.text!
            updatedOrder.reasonType = (isRoundTripTF.text!.lowercased() == "yes") ? reasonTypeTF.text! : ""

            guard let order = self.updatedOrder, let signature = self.signature else { return }
            SVProgressHUD.show()
            AWSHelper.shared.uploadImage(order: order, folder: "sign", image: signature)
            return
        }

        /// Handle Order from Delivered to Round Trip
        if let order = order {
            let updatedOrder = UpdatedOrder()
            updatedOrder.id = order.id
            updatedOrder.waitTime = Int(waitTimeTF.text!)!
            updatedOrder.numOfBoxes = Int(boxesTF.text!)!
            updatedOrder.transportation = transportationTF.text!
            updatedOrder.reasonType = reasonTypeTF.text!

            SVProgressHUD.show()
            orderVM.updateOrderToRoundTrip(order: updatedOrder)
        }
    }
}

extension UpdateOrderFormViewController: PanModalPresentable{
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var showDragIndicator: Bool{
        return false
    }
    
    var shortFormHeight: PanModalHeight{
        /// Handle Order from Delivered to Round Trip
        if reasonTypeSV.isHidden || isRoundTripSV.isHidden{
            return .contentHeight(508)
        }
        return .contentHeight(608)
    }
    
    var longFormHeight: PanModalHeight{
        /// Handle Order from Delivered to Round Trip
        if reasonTypeSV.isHidden || isRoundTripSV.isHidden{
            return .contentHeight(508)
        }
        return .contentHeight(608)
    }
}

extension UpdateOrderFormViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case transportationPV:
            return transportationTF.text = transportations[row]
        case isRoundTripPV:
            let isRoundTrip = isRoundTrip[row]
            reasonTypeSV.isHidden = (isRoundTrip.lowercased() == "no") ? true : false
            panModalSetNeedsLayoutUpdate()
            panModalTransition(to: .shortForm)
            return isRoundTripTF.text = isRoundTrip
        case reasonTypePV:
            return reasonTypeTF.text = reasonTypes[row].reason
        default:
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case transportationPV:
            return transportations.count
        case isRoundTripPV:
            return isRoundTrip.count
        case reasonTypePV:
            return reasonTypes.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case transportationPV:
            return transportations[row]
        case isRoundTripPV:
            return isRoundTrip[row]
        case reasonTypePV:
            return reasonTypes[row].reason
        default:
            return nil
        }
    }
}

extension UpdateOrderFormViewController: ConfirmationDelegate{
    func didYesAction() {
        SVProgressHUD.show()
        
        updatedOrder!.waitTime = Int(waitTimeTF.text!)!
        updatedOrder!.numOfBoxes = Int(boxesTF.text!)!
        updatedOrder!.transportation = transportationTF.text!
        updatedOrder!.isRoundTrip = isRoundTripTF.text!
        updatedOrder!.reasonType = (isRoundTripTF.text!.lowercased() == "yes") ? reasonTypeTF.text! : ""

        if isRoundTripSV.isHidden {
            updatedOrder!.reasonType = reasonTypeTF.text!
        }

        AWSHelper.shared.uploadImage(order: updatedOrder!, folder: "sign", image: signature!)
        return
    }
}
