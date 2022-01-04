//
//  InputItemPieceViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 20/11/21.
//

import UIKit
import SVProgressHUD
import RxSwift

protocol InputItemPieceDelegate{
    func doneAction()
}

class InputItemPieceViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBOutlet var titleL: UILabel!
    
    @IBOutlet var overlayV: UIView!
    @IBOutlet var containerV: UIView!
    
    @IBOutlet var pieceTF: AOTTextField!
    
    @IBOutlet var doneBtn: AOTButton!
    
    var delegate:InputItemPieceDelegate?
    var order: Order?
    var piece:String = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        overlayV.addGestureRecognizer(tapGesture)
        containerV.layer.cornerRadius = 10
        
        doneBtn.disable()
        pieceTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if order!.status == Status.DELIVERED {
            titleL.text = "No. of pieces delivering"
        }
        
        if order!.status == Status.PICKED_UP {
            titleL.text = "No. of pieces delivering"
            if order!.partialPiece > 0, order!.partialPiece < Int(order!.piece)!{
                titleL.text = "No. of pieces picked up"
            }
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField){
        doneBtn.disable()
        if !textField.text!.isEmpty{
            doneBtn.enable()
        }
    }
    
    @IBAction func doneAction(_ sender: Any) {
        guard let order = self.order else { return }
        let totalPiece = Int(pieceTF.text!)!
        
//        if order.status == Status.PICKED_UP,
//           order.partialPiece > 0,
//           order.partialPiece != Int(order.piece)!{
//            totalPiece = (Int(pieceTF.text!)! + order.partialPiece)
//        }
        
        if totalPiece != Int(order.piece)!{
            SVProgressHUD.showError(withStatus: "Order Package Mismatch")
            SVProgressHUD.dismiss(withDelay: 1)
            return
        }
        dismiss(animated: true, completion: nil)
        delegate?.doneAction()
    }
    
    @objc func dismissVC(){
        dismiss(animated: true, completion: nil)
    }
}
