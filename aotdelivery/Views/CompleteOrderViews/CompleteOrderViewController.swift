//
//  CompleteOrderViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 20/11/21.
//

import UIKit
import SVProgressHUD

class CompleteOrderViewController: UIViewController {
    
    @IBOutlet var orderIdL: UILabel!
    
    @IBOutlet var lastNameTF: AOTTextField!
    @IBOutlet var isLiveHereTF: AOTTextField!
    @IBOutlet var relationshipTF: AOTTextField!
    
    @IBOutlet var nextBtn: AOTButton!
    
    let isLiveHere = ["Yes", "No"]
    let relationships = ["Self", "Nurse", "Receptionist", "RN", "Husband", "Wife", "Care Driver", "Other"]
    
    let isLiveHerePV = UIPickerView()
    let relationshipPV = UIPickerView()
    
    var order: Order?
    var updatedOrder: UpdatedOrder?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews(){
        title = "Complete Order"
        
        orderIdL.text = order?.id
        
        isLiveHerePV.delegate = self
        isLiveHereTF.inputView = isLiveHerePV
        isLiveHereTF.tintColor = .clear
        isLiveHereTF.text = isLiveHere.first
        
        relationshipPV.delegate = self
        relationshipTF.inputView = relationshipPV
        relationshipTF.tintColor = .clear
        relationshipTF.text = relationships.first
        
        lastNameTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        nextBtn.disable()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField){
        nextBtn.disable()
        if !textField.text!.isEmpty{
            nextBtn.enable()
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        guard let updatedOrder = updatedOrder else {
            return
        }

        let signatureVC = SignatureViewController()
        updatedOrder.lastName = lastNameTF.text!
        updatedOrder.isLiveHere = isLiveHereTF.text!
        updatedOrder.recepientRelationship = relationshipTF.text!
        signatureVC.updatedOrder = updatedOrder
        signatureVC.order = order
        navigationController?.pushViewController(signatureVC, animated: true)
    }
}

extension CompleteOrderViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case isLiveHerePV:
            return isLiveHere.count
        case relationshipPV:
            return relationships.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case isLiveHerePV:
            return isLiveHere[row]
        case relationshipPV:
            return relationships[row]
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case isLiveHerePV:
            isLiveHereTF.text = isLiveHere[row]
        case relationshipPV:
            relationshipTF.text = relationships[row]
        default:
            break
        }
    }
}
