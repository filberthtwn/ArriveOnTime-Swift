//
//  FutureViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 25/05/21.
//

import UIKit
import RxSwift
import RxCocoa

class FutureViewController: UIViewController {
    
    private let orderVM = OrderViewModel()

    @IBOutlet var futureTV: UITableView!
    @IBOutlet var emptyStateL: UILabel!
    
    private let refreshControl = UIRefreshControl()

    private var disposeBag = DisposeBag()
    private var isLoaded = false

    var orders:[Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disposeBag = DisposeBag()
    }
    
    private func setupViews(){
        self.title = "Future Dispatches"
        self.futureTV.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        self.futureTV.register(UINib(nibName: "ShimmerOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        self.futureTV.register(UINib(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderCell")
        
        self.refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged )
        self.futureTV.addSubview(self.refreshControl)
    }
    
    private func setupData(){
        self.orderVM.getAllOrder(orderType: "future", device: "iphone")
    }
    
    @objc
    private func refreshData(){
        self.isLoaded = false
        self.emptyStateL.isHidden = true
        self.orders.removeAll()
        self.futureTV.reloadData()
        
        self.setupData()
    }
    
    private func observeViewModel(){
        self.orderVM.orders.bind { (orders)  in
            self.isLoaded = true
            self.orders = orders
            self.futureTV.reloadData()
            
            if (orders.count == 0){
                self.emptyStateL.isHidden = false
            }else{
                self.emptyStateL.isHidden = false
            }
            
            self.refreshControl.endRefreshing()
        }.disposed(by: self.disposeBag)
    }
}

extension FutureViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.isLoaded) ? self.orders.count : 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (!self.isLoaded){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath) as! ShimmerOrderTableViewCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderTableViewCell
        
        let order = self.orders[indexPath.row]
        cell.orderIdL.text = String(format: "#%@", order.id)
        cell.orderDateL.text = order.orderDate
        cell.statusL.text = order.status

        cell.senderNameL.text = order.senderName
        cell.senderAddressL.text = order.senderAddress

        cell.recepientNameL.text = order.recipientName
        cell.recepientAddressL.text = order.recipientAddress
        
        return cell
    }
}
