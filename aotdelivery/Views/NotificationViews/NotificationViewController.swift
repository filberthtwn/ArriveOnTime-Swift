//
//  NotificationViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 26/05/21.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet var notificationTV: UITableView!
     
    private let notifVM = NotifViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
    }
    
    private func setupViews(){
        self.title = "Notification"
//        let refreshBtn = UIBarButtonItem(image: UIImage(named: "RefreshIcon"), style: .plain, target: self, action:  #selector(self.refreshData))
//        self.navigationItem.rightBarButtonItem = refreshBtn
    }
    
    private func setupData(){
        self.notifVM.getAllNotification()
    }
    
    private func observeViewModel(){
        
    }
    
    @objc
    private func refreshData(){
//        self.isLoaded = false
//        self.emptyStateL.isHidden = true
//        self.orders.removeAll()
//        self.futureTV.reloadData()
//
//        self.setupData()
    }
}
