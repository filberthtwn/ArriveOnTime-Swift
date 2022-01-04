//
//  DispatchViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 25/05/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class DispatchViewController: UIViewController {
    
    @IBOutlet var dispatchTV: UITableView!
    @IBOutlet var emptyStateL: UILabel!
    
    var delegate: MainTabBarDelegate?
    
    private let orderVM = OrderViewModel()
    
    var selectAllBtn: UIBarButtonItem?
    private let refreshControl = UIRefreshControl()
    
    private var disposeBag = DisposeBag()
    private var orders:[Order] = []
    
    private var selectedOrder:[Order] = []
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObserver()
        self.disposeBag = DisposeBag()
        self.parent?.navigationItem.rightBarButtonItem = nil
    }
    
    private func setupViews(){
        //* Setup orderTV
        self.dispatchTV.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        self.dispatchTV.register(UINib(nibName: "ShimmerOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        self.dispatchTV.register(UINib(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderCell")
        
        self.refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged )
        self.dispatchTV.addSubview(self.refreshControl)
    }
    
    private func removeObserver(){
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupData(){
        self.orderVM.getAllOrderDispatch()
    }
    
    private func clearData(){
        self.isLoaded = false
        self.emptyStateL.isHidden = true
        self.orders.removeAll()
        self.dispatchTV.reloadData()
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
            self.dispatchTV.reloadData()
            
            if (self.orders.count == 0){
                self.emptyStateL.isHidden = false
            }else{
                self.emptyStateL.isHidden = true
            }
            
            NotificationCenter.default.post(name: NotifName.UPDATE_TITLE, object: nil, userInfo: [
                "orderCount": orders.count,
                "orderType": OrderType.DISPATCH
            ])
            
            self.refreshControl.endRefreshing()
        }.disposed(by: self.disposeBag)
        
        self.orderVM.isSuccess.bind { (isSuccess)  in
            self.refreshData()
            
            SVProgressHUD.showSuccess(withStatus: "Order dispatch successful")
            SVProgressHUD.dismiss(withDelay: 1)
            
            self.delegate?.didDispatchAccepted()
        }.disposed(by: self.disposeBag)
        
        self.orderVM.errMsg.bind { (errMsg)  in
            SVProgressHUD.showError(withStatus: errMsg)
            SVProgressHUD.dismiss(withDelay: 1)
        }.disposed(by: self.disposeBag)
    }
    
    @objc func selectAllAction(){
        var isConfirmShow = false
        if (self.selectedOrder.count < self.orders.count){
            self.selectAllBtn!.title = "Deselect All"
            self.selectedOrder = self.orders
            
            isConfirmShow = true
        }else{
            self.selectAllBtn!.title = "Select All"
            self.selectedOrder.removeAll()
            
            isConfirmShow = false
        }
        
        NotificationCenter.default.post(name: NotifName.SET_TO_SELECT_ALL, object: nil, userInfo: [:])
        if selectedOrder.count == orders.count{
            NotificationCenter.default.post(name: NotifName.DISPATCH_SELECTED, object: nil, userInfo: ["isConfirmShow": isConfirmShow])
        }
        
        delegate?.showConfirmButton()
        
        self.dispatchTV.reloadData()
    }
    
    func confirmAction() {
        if self.selectedOrder.isEmpty{
            SVProgressHUD.showError(withStatus: "No order selected")
            SVProgressHUD.dismiss(withDelay: 1)
            return
        }

        SVProgressHUD.show()
        let orderIds = self.selectedOrder.compactMap({$0.id})
        self.orderVM.cofirmDispatchOrder(orderIds: orderIds)
    }
}

extension DispatchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if orders.count == 0 { return }
    
        let order = self.orders[indexPath.row]
        order.status = "Dispatch"

        let userInfo: [String: Any] = [
            "order": order,
            "order_type": OrderType.DISPATCH
        ]
        NotificationCenter.default.post(name: NotifName.ORDER_TAPPED, object: nil, userInfo: userInfo)
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
        order.status = Status.DISPATCHED
        cell.order = order
        
        cell.orderIdL.text = String(format: "#%@", order.id)
        cell.orderDateL.text = order.orderDate
        cell.statusL.text = order.status
        
        cell.senderNameL.text = order.sender?.name ?? "-"
        cell.senderAddressL.text = order.sender?.address ?? "-"
        
        cell.recepientNameL.text = order.recipient?.name ?? "-"
        cell.recepientAddressL.text = order.recipient?.address ?? "-"
        
        cell.configure(order: order)
        cell.isSelect = self.selectedOrder.contains(where: {$0.id == order.id})
        
        return cell
    }
}

extension DispatchViewController: OrderCellDelegate{
    func didSelectItem(order: Order) {
        if let index = self.selectedOrder.firstIndex(where: {$0.id == order.id}){
            self.selectedOrder.remove(at: index)
        }else{
            self.selectedOrder.append(order)
        }
        self.dispatchTV.reloadData()
        
        NotificationCenter.default.post(name: NotifName.SET_TO_SELECT_ALL, object: nil, userInfo: [:])
        if selectedOrder.count == orders.count{
            NotificationCenter.default.post(name: NotifName.DISPATCH_SELECTED, object: nil, userInfo: [:])
        }
    }
}
