//
//  OpenViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 25/05/21.
//

import UIKit
import RxSwift
import SVProgressHUD

class OpenViewController: UIViewController {
    
    private let orderVM = OrderViewModel()

    @IBOutlet var openOrderTV: UITableView!
    @IBOutlet var emptyStateL: UILabel!
    
    private let refreshControl = UIRefreshControl()
        
    private var orders:[Order] = []
    private var selectedOpenOrders:[Order] = []
    private var disposeBag = DisposeBag()
    private var isLoaded = false
    
    let orderTypesQuery = ["current", "past", "future"]
    var totalQuery = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.registerObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        selectedOpenOrders.removeAll()
        openOrderTV.reloadData()
        
        self.parent?.navigationItem.rightBarButtonItem = nil
        self.disposeBag = DisposeBag()
    }
    
    private func setupViews(){
        self.openOrderTV.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 65 + 32, right: 0)
        self.openOrderTV.register(UINib(nibName: "ShimmerOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        self.openOrderTV.register(UINib(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderCell")
        
        self.refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged )
        self.openOrderTV.addSubview(self.refreshControl)
    }
    
    private func setupData(){
        self.orderVM.getAllOrder(orderType: self.orderTypesQuery[self.totalQuery], device: "iphone")
    }
    
    private func registerObserver(){
//        NotificationCenter.default.addObserver(self, selector: #selector(self.updateView), name: NotifName.UPDATE_VIEW, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.clearSelectedOrders), name: NotifName.CLEAR_SELECTED_ORDER, object: nil)
    }
    
    private func observeViewModel(){
        self.orderVM.orders.bind { (orders)  in
            let filteredOrders = orders.filter({ $0.status != "Delivered" })
            self.orders.append(contentsOf: filteredOrders)
            
            if (self.totalQuery == (self.orderTypesQuery.count - 1)){
                self.isLoaded = true
                self.openOrderTV.reloadData()
                                
                if (self.orders.count == 0){
                    self.emptyStateL.isHidden = false
                }else{
                    self.emptyStateL.isHidden = true
                }
                
                self.refreshControl.endRefreshing()
                
                NotificationCenter.default.post(name: NotifName.UPDATE_TITLE, object: nil, userInfo: [
                    "orderCount": self.orders.count,
                    "orderType": OrderType.OPEN
                ])
                return
            }
            self.totalQuery += 1
            self.setupData()
        }.disposed(by: disposeBag)
        
        self.orderVM.isSuccess.bind { (isSuccess)  in
            SVProgressHUD.showSuccess(withStatus: "Pickup order successful")
            SVProgressHUD.dismiss(withDelay: 1)
            
            self.refreshData()
        }.disposed(by: disposeBag)
        
        self.orderVM.errMsg.bind { (errMsg)  in
            SVProgressHUD.showError(withStatus: errMsg)
            SVProgressHUD.dismiss(withDelay: 1)
        }.disposed(by: disposeBag)
    }
    
    private func moveToDetail(order: Order){
        let userInfo: [String: Any] = [
            "order": order,
            "order_type": OrderType.OPEN
        ]
        NotificationCenter.default.post(name: NotifName.ORDER_TAPPED, object: nil, userInfo: userInfo)
    }
    
    func confirmAction(){
        self.isLoaded = false
        openOrderTV.reloadData()
        
        let openOrderIds = selectedOpenOrders.compactMap({$0.id})
        orderVM.updateOrderPickup(orderIds: openOrderIds)
    }
    
    private func clearData(){
        self.isLoaded = false
        self.totalQuery = 0
        self.emptyStateL.isHidden = true
        self.orders.removeAll()
        self.selectedOpenOrders.removeAll()
        self.openOrderTV.reloadData()
    }
    
    @objc func refreshData(){
        disposeBag = DisposeBag()
        clearData()
        NotificationCenter.default.post(name: NotifName.SET_TO_SELECT_ALL, object: nil, userInfo: [:])
        setupData()
        observeViewModel()
    }
    
    @objc private func updateView(){
        refreshData()
    }
    
    @objc func clearSelectedOrders(){
        selectedOpenOrders.removeAll()
        openOrderTV.reloadData()
    }
    
    @objc func selectAllAction(){
        let openOrders = orders.filter({$0.status == Status.OPEN_ORDER})
        
        if selectedOpenOrders.count == openOrders.count{
            NotificationCenter.default.post(name: NotifName.SET_TO_SELECT_ALL, object: nil, userInfo: [:])
            selectedOpenOrders.removeAll()
            openOrderTV.reloadData()
            
            /// Show/ hide order selected
            NotificationCenter.default.post(name: NotifName.ORDER_SELECTED, object: nil, userInfo: [
                "isShow": false
            ])
            
            return
        }
        
        selectedOpenOrders = openOrders
        openOrderTV.reloadData()
        NotificationCenter.default.post(name: NotifName.DISPATCH_SELECTED, object: nil, userInfo: [:])
        
        /// Show/ hide order selected
        NotificationCenter.default.post(name: NotifName.ORDER_SELECTED, object: nil, userInfo: [
            "isShow": true
        ])
    }
}


extension OpenViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoaded { return }
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
        cell.delegate = self
        
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

extension OpenViewController: OrderCellDelegate{
    func didSelectItem(order: Order) {
        if order.status == Status.PICKED_UP {
            moveToDetail(order: order)
            return
        }

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
        
        openOrderTV.reloadData()
    }
}


