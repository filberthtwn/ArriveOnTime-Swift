//
//  PartialVC.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 02/01/22.
//

import UIKit
import RxSwift
import SVProgressHUD

class PartialVC: UIViewController {

    @IBOutlet var partialTV: UITableView!
    
    var delegate: MainTabBarDelegate?
    
    private let orderVM = OrderViewModel()
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private var orders: [Order] = []
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupData()
        observeViewModel()
    }
    
    private func setupViews(){
        partialTV.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        partialTV.register(UINib(nibName: "ShimmerOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        partialTV.register(UINib(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderCell")
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        partialTV.addSubview(refreshControl)
    }
    
    private func setupData(){
        orderVM.getAllOrder(orderType: "current", device: "ios")
    }
    
    private func observeViewModel(){
        orderVM.orders.bind{ (orders) in
            let filteredOrders = orders.filter({
                ($0.partialPiece > 0 && $0.partialPiece < Int($0.piece)!) ||
                ($0.partialDeliver > 0 && $0.partialDeliver < Int($0.piece)!)
            })
            self.orders = filteredOrders
            self.isLoaded = true
            self.refreshControl.endRefreshing()
            self.partialTV.reloadData()
            self.delegate?.didDataLoaded(orderType: .PARTIAL, count: self.orders.count)
        }.disposed(by: disposeBag)
        
        orderVM.errMsg.bind{ (errorMsg) in
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: 1)
        }.disposed(by: disposeBag)
    }
    
    @objc func refreshData(){
        orders.removeAll()
        isLoaded = false
        partialTV.reloadData()
        setupData()
    }
}

extension PartialVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isLoaded {
            return 10
        }
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isLoaded {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath)
            return cell
        }
        let order = orders[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderTableViewCell
        cell.configure(order: order)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoaded { return }
        
        let orderDetailVC = OrderDetailViewController()
        orderDetailVC.order = orders[indexPath.item]
        navigationController?.pushViewController(orderDetailVC, animated: true)
    }
}
