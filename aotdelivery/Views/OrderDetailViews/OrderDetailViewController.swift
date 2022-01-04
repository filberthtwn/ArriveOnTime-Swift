//
//  OrderDetailViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 06/06/21.
//

import UIKit
import RxSwift
import Photos
import SVProgressHUD

class OrderDetailViewController: UIViewController {
    
    @IBOutlet var shimmerSectionV: UIView!
    @IBOutlet var contentSectionV: UIView!
    @IBOutlet var bottomMenuV: UIView!
    
    @IBOutlet var firstShimmerV: AOTShimmerView!
    @IBOutlet var firstShimmerContentV: UIView!
    
    @IBOutlet var secondShimmerV: AOTShimmerView!
    @IBOutlet var secondShimmerContentV: UIView!
    
    @IBOutlet var thirdShimmerV: AOTShimmerView!
    @IBOutlet var thirdShimmerContentV: UIView!
    
    @IBOutlet var shimmerVs: [UIView]!
    
    @IBOutlet var orderIdL: UILabel!
    @IBOutlet var orderStatusL: UILabel!
    @IBOutlet var accountNameL: UILabel!
    @IBOutlet var accountNotesL: UILabel!
    
    @IBOutlet var senderNameL: UILabel!
    @IBOutlet var senderCellPhoneL: UILabel!
    @IBOutlet var senderHomePhoneL: UILabel!
    @IBOutlet var senderAddressL: UILabel!
    @IBOutlet var senderInstructionL: UILabel!
    
    @IBOutlet var recipientNameL: UILabel!
    @IBOutlet var recipientCellPhoneL: UILabel!
    @IBOutlet var recipientHomePhoneL: UILabel!
    @IBOutlet var recipientAddressL: UILabel!
    @IBOutlet var recipientInstructionL: UILabel!
    
    @IBOutlet var serviceTypeL: UILabel!
    @IBOutlet var pickupDateL: UILabel!
    
    @IBOutlet var isShipperReleaseIV: UIImageView!
    @IBOutlet var isSignatureRequiredIV: UIImageView!
    @IBOutlet var isRoundTripIV: UIImageView!
    
    @IBOutlet var requestorName: UILabel!
    @IBOutlet var quantityL: UILabel!
    @IBOutlet var adminNotesL: UILabel!
    
    @IBOutlet var buttonTypeOneSV: UIStackView!
    @IBOutlet var buttonTypeTwoSV: UIStackView!
    
    @IBOutlet var roundTripBtn: AOTButton!
    @IBOutlet var cameraBtn: AOTButton!
    
    @IBOutlet var uploadImageBtn: AOTButton!
    @IBOutlet var confirmBtn: AOTButton!
    
    var order: Order?
//    var orderStatus:String? = ""
    var orderType: OrderType?
    
    private let imagePickerC = UIImagePickerController()
    private let orderVM = OrderViewModel()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "Order Detail"
        
        //* Hide content section && bottom menu on start
        self.contentSectionV.isHidden = true
        self.bottomMenuV.isHidden = true
        
        self.firstShimmerV.contentView = self.firstShimmerContentV
        self.secondShimmerV.contentView = self.secondShimmerContentV
        self.thirdShimmerV.contentView = self.thirdShimmerContentV
        for view in self.shimmerVs {
            view.layer.cornerRadius = view.frame.height/2
        }
        
//        if self.order!.status == nil{
//            self.uploadImageBtn.isHidden = true
//        }
        
        switch self.order!.status {
        case Status.PICKED_UP:
            roundTripBtn.setTitle("Deliver", for: .normal)
        case Status.OPEN_ORDER:
            roundTripBtn.setTitle("Pick Up", for: .normal)
        default:
            break
        }
        
        /// Setup Image Picker Controller
        imagePickerC.delegate = self
    }
    
    private func setupData(){
        guard let order = self.order else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        self.orderVM.getOrderDetail(orderId: order.id)
    }
    
    private func observeViewModel(){
        AWSHelper.shared.fileName.bind { (fileName)  in
            SVProgressHUD.showSuccess(withStatus: "Image uploaded successfully")
            SVProgressHUD.dismiss(withDelay: 1)
        }.disposed(by: self.disposeBag)
        
        self.orderVM.order.bind { (order)  in
            SVProgressHUD.dismiss()
            self.setupDefaultValue(order: order)
        }.disposed(by: self.disposeBag)
        
        self.orderVM.isSuccess.bind { (isSuccess)  in
            SVProgressHUD.showSuccess(withStatus: "Order dispatch successful")
            SVProgressHUD.dismiss(withDelay: 1)
            
            /// Set Selected Tab into Current Tab
            Global.SELECTED_PAGE_INDEX = 1
                
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: self.disposeBag)
        
        AWSHelper.shared.errorMsg.bind { (errorMsg)  in
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: 1)
        }.disposed(by: self.disposeBag)
        
        self.orderVM.errMsg.bind { (errMsg)  in
            SVProgressHUD.showError(withStatus: errMsg)
            SVProgressHUD.dismiss(withDelay: 1)
            
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: self.disposeBag)
    }
    
    private func setupDefaultValue(order: Order){
        self.order = order
        
        //* Show content section && bottom menu on start
        self.shimmerSectionV.isHidden = true
        self.contentSectionV.isHidden = false
        self.bottomMenuV.isHidden = false
        
        self.orderIdL.text = order.id
        
        self.accountNameL.text = order.accountName
        self.accountNotesL.text = order.accountNotes
        
        //* Setup sender section
        guard let sender = order.sender else {
            SVProgressHUD.showError(withStatus: "Sender not found")
            SVProgressHUD.dismiss(withDelay: 1)
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.senderNameL.text = sender.name
        self.senderCellPhoneL.text = (sender.cellPhone != "") ? sender.cellPhone : "-"
        self.senderHomePhoneL.text = (sender.homePhone != "") ? sender.homePhone : "-"
        let senderFullAddress = String(format: "%@ %@, %@, %@, %@", sender.address, sender.suite, sender.city, sender.country, sender.postalCode)
        self.senderAddressL.text = senderFullAddress
        self.senderInstructionL.text = order.senderInstruction
        
        //* Setup recipient section
        guard let recipient = order.recipient else {
            SVProgressHUD.showError(withStatus: "Recipient not found")
            SVProgressHUD.dismiss(withDelay: 1)
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.recipientNameL.text = recipient.name
        self.recipientCellPhoneL.text = (recipient.cellPhone != "") ? recipient.cellPhone : "-"
        self.recipientHomePhoneL.text = (recipient.homePhone != "") ? recipient.homePhone : "-"
        let recipientFullAddress = String(format: "%@ %@, %@, %@, %@", recipient.address, recipient.suite, recipient.city, recipient.country, recipient.postalCode)
        self.recipientAddressL.text = recipientFullAddress
        self.recipientInstructionL.text = (order.recipientInstruction != "") ? order.recipientInstruction : "-"
        
        //* Setup additional description section
        self.serviceTypeL.text = order.serviceName
        self.pickupDateL.text = DateFormatterHelper.shared.formatString(oldDateFormat: "hh:mm a, MMMM MM/dd/yyyy", newDateFormat: "yyyy-MM-dd, hh:mm a", dateString: order.pickupDate, timezone: TimeZone(abbreviation: "UTC"))
        if (!order.isShipperRelease){
            self.isShipperReleaseIV.image = UIImage(named: "UnverifiedIcon")
        }
        
        if (!order.isSignatureRequired){
            self.isSignatureRequiredIV.image = UIImage(named: "UnverifiedIcon")
        }
        
        if (!order.isRoundTrip){
            self.isRoundTripIV.image = UIImage(named: "UnverifiedIcon")
        }
        
        /// Requested by section
        requestorName.text = order.requestor
        quantityL.text = String(format: "%@ (%@g)", order.piece, order.weight)
        adminNotesL.text = order.adminNotes
        
        /// Setup Button Section
        buttonTypeOneSV.isHidden = true
        buttonTypeTwoSV.isHidden = true
        
        /// Setup Order Status Label
        orderStatusL.text = order.status
        if order.status == Status.DELIVERED, order.isRoundTrip{
            orderStatusL.text = Status.ROUND_TRIP
        }
        
        switch order.status {
        case Status.DELIVERED:
            /// Show Button when Status is not Complete
            if let order = self.order, order.signRoundTrip == ""{
                buttonTypeOneSV.isHidden = false
            }
            
            if order.partialDeliver < Int(order.piece)! {
                UIView.performWithoutAnimation {
                    roundTripBtn.setTitle("Deliver", for: .normal)
                    view.layoutIfNeeded()
                }
            }
            
            /// Handle Order from Round Trip to Complete
            if order.isRoundTrip {
                cameraBtn.isHidden = true
                UIView.performWithoutAnimation {
                    roundTripBtn.setTitle("Complete", for: .normal)
                    view.layoutIfNeeded()
                }
            }
        case Status.PICKED_UP:
            buttonTypeOneSV.isHidden = false
            UIView.performWithoutAnimation {
                self.roundTripBtn.setTitle("Deliver", for: .normal)
                if order.partialPiece > 0, order.partialPiece < Int(order.piece)!{
                    self.roundTripBtn.setTitle("Pick up", for: .normal)
                }
                self.view.layoutIfNeeded()
            }
        case Status.DISPATCHED, Status.DISPATCH:
            uploadImageBtn.isHidden = true
            buttonTypeTwoSV.isHidden = false
        case Status.OPEN_ORDER:
            buttonTypeOneSV.isHidden = false
            UIView.performWithoutAnimation {
                self.roundTripBtn.setTitle("Pick Up", for: .normal)
                self.view.layoutIfNeeded()
            }
        default:
            break
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {        
        guard let order = self.order else { return }
        switch order.status {
        case Status.DELIVERED:
            /// Handle Order from Round Trip to Complete
            if order.isRoundTrip || (order.partialDeliver < Int(order.piece)!) {
                let inputItemPieceVC = InputItemPieceViewController()
                inputItemPieceVC.delegate = self
                inputItemPieceVC.order = order
                inputItemPieceVC.piece = order.piece
                inputItemPieceVC.modalTransitionStyle = .crossDissolve
                inputItemPieceVC.modalPresentationStyle = .overCurrentContext
                present(inputItemPieceVC, animated: true, completion: nil)
                
                return
            }
            
            /// Handle Order from Delivered to Round Trip
            let updateOrderModal = UpdateOrderFormViewController()
            updateOrderModal.delegate = self
            updateOrderModal.order = order
            presentPanModal(updateOrderModal)
        case Status.PICKED_UP, Status.OPEN_ORDER:
            let inputItemPieceVC = InputItemPieceViewController()
            inputItemPieceVC.delegate = self
            inputItemPieceVC.order = order
            inputItemPieceVC.piece = order.piece
            inputItemPieceVC.modalTransitionStyle = .crossDissolve
            inputItemPieceVC.modalPresentationStyle = .overCurrentContext
            present(inputItemPieceVC, animated: true, completion: nil)
        default:
            break
        }
    }
    
    @IBAction func uploadImageAction(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default , handler:{ (UIAlertAction)in
            
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
                case .denied, .notDetermined, .restricted, .limited:
                    PHPhotoLibrary.requestAuthorization({status in
                        if(status == .authorized){
                            DispatchQueue.main.async {
                                self.imagePickerC.sourceType = UIImagePickerController.SourceType.photoLibrary
                                self.present(self.imagePickerC, animated: true, completion: nil)
                            }
                            return
                        }
                        
                        SVProgressHUD.showError(withStatus: "Please allow access to gallery from setting")
                        SVProgressHUD.dismiss(withDelay: 1)
                    })
                    break
                case .authorized:
                    self.imagePickerC.sourceType = UIImagePickerController.SourceType.photoLibrary
                    self.present(self.imagePickerC, animated: true, completion: nil)
                @unknown default:
                    fatalError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction) in
            self.imagePickerC.sourceType = UIImagePickerController.SourceType.camera
            self.present(self.imagePickerC, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func confirmAction(_ sender: Any) {
        SVProgressHUD.show()
        self.orderVM.cofirmDispatchOrder(orderIds: [self.order!.id])
    }
}

extension OrderDetailViewController: InputItemPieceDelegate{
    func doneAction() {
        guard let order = order else { return }
        switch order.status {
        case Status.DELIVERED:
            /// Handle Order from Delivered to Round Trip
            let completeOrderVC = CompleteOrderViewController()
            let updatedOrder = UpdatedOrder()
            updatedOrder.id = order.id
            completeOrderVC.updatedOrder = updatedOrder
            completeOrderVC.order = order
            navigationController?.pushViewController(completeOrderVC, animated: true)
        case Status.OPEN_ORDER:
            /// Handle Order from Open to Pick Up
            SVProgressHUD.show()
            orderVM.updateOrderPickup(orderIds: [order.id])
        case Status.PICKED_UP:
            /// Do when Partial PICKED UP
            if order.partialPiece > 0, order.partialPiece != Int(order.piece)! {
                SVProgressHUD.show()
                orderVM.updateOrderPickup(orderIds: [order.id])
                return
            }
            
            /// Handle Order from Pick Up to Deliver
            let completeOrderVC = CompleteOrderViewController()
            
            let updatedOrder = UpdatedOrder()
            updatedOrder.id = order.id
            updatedOrder.status = order.status
            
            completeOrderVC.order = order
            completeOrderVC.updatedOrder = updatedOrder
            navigationController?.pushViewController(completeOrderVC, animated: true)
        default:
            break
        }
    }
}

extension OrderDetailViewController: UpdateOrderFormDelegate{
    func didDoPartialDeliver() { return }
    
    func didUdpdateOrderSuccess() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension OrderDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let order = UpdatedOrder()
        order.id = self.order!.id
        order.status = self.order!.status
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        AWSHelper.shared.uploadImage(order: order, folder: "images", image: image)
        dismiss(animated: true) {
            SVProgressHUD.show(withStatus: "Uploading Image...")
        }
    }
}
