//
//  MoreViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 25/05/21.
//

import UIKit

class MoreViewController: UIViewController {
    
    var delegate: MainTabBarDelegate?

    @IBOutlet var driverNameL: UILabel!
    @IBOutlet var driverLocL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.navigationItem.leftBarButtonItem = nil
    }
    
    private func setupViews(){
        title = "More"
        guard let user = UserDefaultHelper.shared.getUser() else {return}
        self.driverNameL.text = user.name
        self.driverLocL.text = user.location
    }

    @IBAction func futureBtn(_ sender: Any) {
        navigationController?.pushViewController(FutureViewController(), animated: true)
    }
    
    @IBAction func commentsAction(_ sender: Any) {
        navigationController?.pushViewController(NotificationViewController(), animated: true)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        UserDefaultHelper.shared.deleteUser()
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)
    }
}
