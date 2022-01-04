//
//  ConfirmationViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 20/11/21.
//

import UIKit

protocol ConfirmationDelegate{
    func didYesAction()
}

class ConfirmationViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBOutlet var overlayV: UIView!
    @IBOutlet var containerV: UIView!
    
    @IBOutlet var descriptionL: UILabel!
    
    var delegate: ConfirmationDelegate?
    var subtitle: String = "Are you sure to confirm the order?"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAction))
        overlayV.addGestureRecognizer(tapGesture)
        
        containerV.layer.cornerRadius = 10
        
        descriptionL.text = subtitle
    }
    
    @objc private func dismissAction(){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func noAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.didYesAction()
    }
}
