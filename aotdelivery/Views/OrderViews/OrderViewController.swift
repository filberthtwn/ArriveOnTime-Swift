//
//  OrderViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import UIKit
import RxSwift

class OrderViewController: UIViewController {

    var orderType: OrderType = .DELIVER
    private let orderVM = OrderViewModel()
    
    @IBOutlet var orderTV: UITableView!
//    @IBOutlet var orderTypeTF: AOTTextField!
    
//    private let orderTypePV = UIPickerView()
    
    private var orders:[Order] = []
//    private let orderTypes:[String] = [OrderType.PRESENT, OrderType.DELIVERED, OrderType.DISPATCH, OrderType.OPEN]
    
    private var disposeBag = DisposeBag()
    
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
        self.hideKeyboardWhenTappedAround()
            
        //* Setup orderTV
        self.orderTV.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        self.orderTV.register(UINib(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderCell")
    }
    
    private func setupData(){
        var orderType = ""
        var device:String?
        switch self.orderType {
        case .DELIVER:
            orderType = "past"
        case .PRESENT:
            orderType = "current"
        case .OPEN:
            orderType = "current"
            device = "iphone"
        default:
            break
        }
        
        self.orderVM.getAllOrder(orderType: orderType, device: device)
    }
    
    private func observeViewModel(){
        self.orderVM.orders.bind { (orders)  in
            self.orders = orders
            self.orderTV.reloadData()
//            let orderVC = OrderViewController()
//            let navVC = CustomNavigationController(rootViewController: orderVC)
//            navVC.modalPresentationStyle = .fullScreen
//            self.present(navVC, animated: true, completion: nil)
        }.disposed(by: self.disposeBag)
    }
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderDetailVC = OrderDetailViewController()
        orderDetailVC.order = self.orders[indexPath.item]
        self.navigationController?.pushViewController(orderDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderTableViewCell
        
        let order = self.orders[indexPath.row]
        cell.orderIdL.text = String(format: "#%@", order.id)
        cell.statusL.text = order.status
        
        cell.senderNameL.text = order.senderName
        cell.senderAddressL.text = order.senderAddress
        
        cell.recepientNameL.text = order.recipientName
        cell.recepientAddressL.text = order.recipientAddress
        
        return cell
    }
}
