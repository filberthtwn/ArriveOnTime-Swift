//
//  LoginViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet var userIdTF: AOTTextField!
    @IBOutlet var passwordTF: AOTTextField!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }

    @IBOutlet var logoIV: UIImageView!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.hideKeyboardWhenTappedAround()
        self.logoIV.layer.cornerRadius = self.logoIV.frame.height/2
    }
    
    private func observeViewModel(){
        AuthViewModel.shared.isSuccess.bind { (isSuccess)  in
            let navVC = CustomNavigationController(rootViewController: CustomTabBarViewController())
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true, completion: nil)
        }.disposed(by: self.disposeBag)
        
        AuthViewModel.shared.errMsg.bind { (errMsg)  in
            SVProgressHUD.showError(withStatus: errMsg)
            SVProgressHUD.dismiss(withDelay: 1)
        }.disposed(by: self.disposeBag)        
    }
    
    private func validation() -> Bool{
        if (self.userIdTF.text!.isEmpty){
            return false
        }
        
        if (self.passwordTF.text!.isEmpty){
            return false
        }
        
        return true
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if (!self.validation()){
            SVProgressHUD.showError(withStatus: "Please fill the blanks")
            SVProgressHUD.dismiss(withDelay: 1)
            return
        }
        
        SVProgressHUD.show()
        AuthViewModel.shared.login(userId: self.userIdTF.text!, password: self.passwordTF.text!)
    }
}
