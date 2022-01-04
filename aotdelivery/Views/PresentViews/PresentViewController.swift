//
//  PresentViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 25/05/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class PresentViewController: UIViewController {

    @IBOutlet var presentTV: UITableView!
    @IBOutlet var emptyStateL: UILabel!
    
    let refreshControl = UIRefreshControl()
    
    private let orderVM = OrderViewModel()
    private var disposeBag = DisposeBag()
    private var selectedOpenOrders:[Order] = []

    var orders:[Order] = []
    
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
        self.presentTV.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 65 + 32, right: 0)
        self.presentTV.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        self.presentTV.register(UINib(nibName: "ShimmerOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        self.presentTV.register(UINib(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderCell")
        
        self.refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged )
        self.presentTV.addSubview(self.refreshControl)
    }
    
    private func setupData(){
        self.orderVM.getAllOrder(orderType: "current", device: "iphone")
    }
    
    private func clearData(){
        self.isLoaded = false
        self.emptyStateL.isHidden = true
        self.orders.removeAll()
        self.presentTV.reloadData()
    }
    
    @objc func refreshData(){
        self.disposeBag = DisposeBag()
        self.clearData()
        self.setupData()
        self.observeViewModel()
    }
    
    private func observeViewModel(){
        self.orderVM.orders.bind { (orders)  in
            self.isLoaded = true
            self.orders = orders
            self.presentTV.reloadData()
            self.orders = self.orders.sorted(by: {$0.pickupDate > $1.pickupDate})
            
            if (self.orders.count == 0){
                self.emptyStateL.isHidden = false
            }else{
                self.emptyStateL.isHidden = true
            }
            
            NotificationCenter.default.post(name: NotifName.UPDATE_TITLE, object: nil, userInfo: [
                "orderCount": orders.count,
                "orderType": OrderType.PRESENT
            ])
            
            self.refreshControl.endRefreshing()
        }.disposed(by: self.disposeBag)
        
        self.orderVM.isSuccess.bind { (isSuccess)  in
            SVProgressHUD.showSuccess(withStatus: "Pickup order successful")
            SVProgressHUD.dismiss(withDelay: 1)
            
            self.refreshData()
        }.disposed(by: self.disposeBag)
        
        self.orderVM.errMsg.bind { (errMsg)  in
            SVProgressHUD.showError(withStatus: errMsg)
            SVProgressHUD.dismiss(withDelay: 1)
        }.disposed(by: self.disposeBag)
    }
    
    private func moveToDetail(order: Order){
        let userInfo: [String: Any] = [
            "order": order,
            "order_type": OrderType.PRESENT
        ]
        NotificationCenter.default.post(name: NotifName.ORDER_TAPPED, object: nil, userInfo: userInfo)
    }
    
    func confirmAction(){
        selectedOpenOrders.removeAll()
        self.isLoaded = false
        presentTV.reloadData()
        
        let openOrderIds = selectedOpenOrders.compactMap({$0.id})
        orderVM.updateOrderPickup(orderIds: openOrderIds)
    }
    
    
    @objc func selectAllAction(){
        let openOrders = orders.filter({$0.status == Status.OPEN_ORDER})
        
        if selectedOpenOrders.count == openOrders.count{
            NotificationCenter.default.post(name: NotifName.SET_TO_SELECT_ALL, object: nil, userInfo: [:])
            selectedOpenOrders.removeAll()
            presentTV.reloadData()
            
            /// Show/ hide order selected
            NotificationCenter.default.post(name: NotifName.ORDER_SELECTED, object: nil, userInfo: [
                "isShow": false
            ])
            
            return
        }
        
        selectedOpenOrders = openOrders
        presentTV.reloadData()
        NotificationCenter.default.post(name: NotifName.DISPATCH_SELECTED, object: nil, userInfo: [:])
        
        /// Show/ hide order selected
        NotificationCenter.default.post(name: NotifName.ORDER_SELECTED, object: nil, userInfo: [
            "isShow": true
        ])
    }
}

extension PresentViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if orders.count == 0 { return }
        moveToDetail(order: orders[indexPath.row])
    }
    
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
        cell.isSelect = selectedOpenOrders.contains(where: {$0.id == order.id})

        return cell
    }
}

extension PresentViewController: OrderCellDelegate{
    func didSelectItem(order: Order) {
//        if order.status == Status.PICKED_UP {
//            moveToDetail(order: order)
//            return
//        }

        /// Update selected order list
        selectedOpenOrders.contains(where: {$0.id == order.id}) ? selectedOpenOrders.removeAll(where: {$0.id == order.id}) : selectedOpenOrders.append(order)
        
        let openOrders = orders.filter({$0.status == Status.OPEN_ORDER})
        
        NotificationCenter.default.post(name: NotifName.DISPATCH_SELECTED, object: nil, userInfo: [:])
        if selectedOpenOrders.count != openOrders.count{
            NotificationCenter.default.post(name: NotifName.SET_TO_SELECT_ALL, object: nil, userInfo: [:])
        }
        
        /// Show/ hide order selected
        NotificationCenter.default.post(name: NotifName.ORDER_SELECTED, object: nil, userInfo: [
            "isShow": selectedOpenOrders.count > 0
        ])
        
        presentTV.reloadData()
    }
}
