//
//  DeliverViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 25/05/21.
//

import UIKit
import RxSwift
import RxCocoa
import PanModal

class DeliverViewController: UIViewController {

    let orderVM = OrderViewModel()
    
    @IBOutlet var deliverTV: UITableView!
    @IBOutlet var emptyStateL: UILabel!
    
    let refreshControl = UIRefreshControl()
    
    private var disposeBag = DisposeBag()
    private var orders:[Order] = []
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disposeBag = DisposeBag()
    }
    
    private func setupViews(){
        //* Setup orderTV
        self.deliverTV.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 65 + 32, right: 0)
        self.deliverTV.register(UINib(nibName: "ShimmerOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        self.deliverTV.register(UINib(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderCell")
        
        self.refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        self.deliverTV.addSubview(self.refreshControl)
    }
    
    private func setupData(){
        self.orderVM.getAllOrder(orderType: "past", device: "android")
    }
    
    private func observeViewModel(){
        self.orderVM.orders.bind { (orders)  in
            self.isLoaded = true
            
            /// Only Get Delivered Order
            let filteredOrders = orders.filter({ $0.status == Status.DELIVERED || $0.status == Status.PICKED_UP })
            
            /// Remove All Duplicated Order
            var cleanOrders: [Order] = []
            for order in filteredOrders {
                if !cleanOrders.contains(where: { $0.id == order.id }){
                    cleanOrders.append(order)
                }
            }
            self.orders = cleanOrders.sorted(by: {$0.pickupDate > $1.pickupDate})
            self.deliverTV.reloadData()
            
            if self.orders.count == 0{
                self.emptyStateL.isHidden = false
            }else{
                self.emptyStateL.isHidden = true
            }
            
            NotificationCenter.default.post(name: NotifName.UPDATE_TITLE, object: nil, userInfo: [
                "orderCount": cleanOrders.count,
                "orderType": OrderType.DELIVER
            ])
            
            self.refreshControl.endRefreshing()
        }.disposed(by: self.disposeBag)
    }
    
    @objc func refreshData(){
        self.disposeBag = DisposeBag()
        self.clearData()
        self.setupData()
        self.observeViewModel()
    }
    
    private func clearData(){
        self.isLoaded = false
        self.emptyStateL.isHidden = true
        self.orders.removeAll()
        self.deliverTV.reloadData()
    }
}

extension DeliverViewController: UITableViewDelegate, UITableViewDataSource{
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
        cell.order = order
        cell.orderIdL.text = String(format: "#%@", order.id)
        cell.orderDateL.text = order.orderDate
        cell.statusL.text = order.status

        cell.senderNameL.text = order.senderName
        cell.senderAddressL.text = order.senderAddress

        cell.recepientNameL.text = order.recipientName
        cell.recepientAddressL.text = order.recipientAddress
        
        cell.configure(order: order)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if orders.count == 0 { return }
        
        let orderDetailVC = OrderDetailViewController()
        orderDetailVC.orderType = .DELIVER
        orderDetailVC.order = orders[indexPath.item]
        navigationController?.pushViewController(orderDetailVC, animated: true)
    }
}
