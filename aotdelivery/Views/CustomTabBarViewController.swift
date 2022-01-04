//
//  CustomTabBarViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 07/06/21.
//

import UIKit
import SVProgressHUD
import RxSwift
import CoreLocation
import Firebase

struct VCItem{
    let title: String?
    let vc: UIViewController?
}

protocol MainTabBarDelegate {
    func didFutureMenuTapped()
    func didCommentsMenuTapped()
    func didDispatchAccepted()
    func showConfirmButton()
    func didDataLoaded(orderType: OrderType, count: Int)
}

extension MainTabBarDelegate{
    func didDispatchAccepted(){}
}

class CustomTabBarViewController: UIViewController {

    @IBOutlet var floatingV: UIView!
    @IBOutlet var floatingVWidth: NSLayoutConstraint!

    @IBOutlet var contentColV: UICollectionView!
    
    @IBOutlet var icons: [UIImageView]!
    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet var qrScannerV: UIView!
    @IBOutlet var confirmV: UIView!
    @IBOutlet var badgeContainerVs: [RoundedView]!
    
    @IBOutlet var countLs: [UILabel]!
    
    @IBOutlet var acceptBtn: AOTButton!
    
    private var orderVM = OrderViewModel()
    private var disposeBag = DisposeBag()
    private var rightBarBtn:UIBarButtonItem?
    private var badgeCounter = 0
    private var scannedOrder: Order?
    
    /// Location Manager
    private let locationManager = CLLocationManager()
    
    /// Firebase Database
    private let reference = Database.database().reference(withPath: "coordinates")
    
    let vcItems = [
        VCItem(title: "Delivered (0)", vc: DeliverViewController()),
        VCItem(title: "Present (0)", vc: PresentViewController()),
        VCItem(title: "Dispatch (0)", vc: DispatchViewController()),
        VCItem(title: "Open (0)", vc: OpenViewController()),
        VCItem(title: "Partial (0)", vc: PartialVC()),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dispatch (0)"
        self.setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.post(name: NotifName.UPDATE_VIEW, object: nil, userInfo: [:])
        registerObserver()
        
        /// Reload View Controller
        contentColV.scrollToItem(at: IndexPath.init(item: Global.SELECTED_PAGE_INDEX, section: 0), at: .left, animated: false)
        moveView(currentIndex: Global.SELECTED_PAGE_INDEX)
        contentColV.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavBar(selectedPage: Global.SELECTED_PAGE_INDEX)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObserver()
        self.navigationItem.rightBarButtonItem = nil
    }
    
    private func setupViews(){
        self.contentColV.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.floatingV.layer.cornerRadius = self.floatingV.frame.height/2
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        setupMoreIcon()
    }
    
    private func setupMoreIcon(){
        let moreBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        moreBtn.addTarget(self, action: #selector(moveToMoreVC), for: .touchUpInside)
        moreBtn.setImage(UIImage(named: "MoreIcon"), for: .normal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: moreBtn)
    }
    
    private func setupData(){
        badgeCounter = 0
        disposeBag = DisposeBag()
        orderVM = OrderViewModel()
        orderVM.getAllOrder(orderType: "past", device: "iphone")
        observeViewModel()
    }
    
    private func observeViewModel(){
        var openOrderCount = 0
        var openOrderCounter = 0
        
        orderVM.orders.bind { (orders)  in
            switch self.badgeCounter {
            case 0:
                let filteredOrders = orders.filter({ $0.status == Status.DELIVERED || $0.status == Status.PICKED_UP })
                var cleanOrders: [Order] = []
                for order in filteredOrders {
                    if !cleanOrders.contains(where: { $0.id == order.id }){
                        cleanOrders.append(order)
                    }
                }
                self.countLs[self.badgeCounter].text = String(cleanOrders.count)
                self.orderVM.getAllOrder(orderType: "current", device: "iphone")
            case 1:
                self.countLs[self.badgeCounter].text = String(orders.count)
                self.orderVM.getAllOrderDispatch()
            case 2:
                self.countLs[self.badgeCounter].text = String(orders.count)
                self.orderVM.getAllOrder(orderType: "past", device: "iphone")
            case 3:
                let filteredOrders = orders.filter({ $0.status != Status.DELIVERED })
                openOrderCount = openOrderCount + filteredOrders.count
                switch openOrderCounter {
                case 0:
                    self.orderVM.getAllOrder(orderType: "current", device: "iphone")
                    
                case 1:
                    self.orderVM.getAllOrder(orderType: "future", device: "iphone")
                default:
                    self.countLs[self.badgeCounter].text = String(openOrderCount)
                }
                openOrderCounter+=1
            case 4:
                let filteredOrders = orders.filter({
                    ($0.partialPiece > 0 && $0.partialPiece < Int($0.piece)!) ||
                    ($0.partialDeliver > 0 && $0.partialDeliver < Int($0.piece)!)
                })
                self.countLs[self.badgeCounter].text = String(filteredOrders.count)
                return
            default:
                break
            }
            self.badgeCounter+=1
        }.disposed(by: disposeBag)
        
        orderVM.order.bind{(order) in
            self.scannedOrder = order
            switch order.status {
            case Status.DISPATCH, Status.DISPATCHED:
                self.orderVM.cofirmDispatchOrder(orderIds: [order.id])
                break
            case Status.OPEN_ORDER:
                self.orderVM.updateOrderPartialPickup(orderId: order.id, partialPiece: order.partialPiece + 1)
                break
            case Status.PICKED_UP:
                if order.partialPiece > 0, order.partialPiece < Int(order.piece)!{
                    self.orderVM.updateOrderPartialPickup(orderId: order.id, partialPiece: order.partialPiece + 1)
                    break
                }
                SVProgressHUD.dismiss()
                let completeOrderVC = CompleteOrderViewController()
                completeOrderVC.order = order
                let updatedOrder = UpdatedOrder()
                updatedOrder.id = order.id
                completeOrderVC.updatedOrder = updatedOrder
                self.navigationController?.pushViewController(completeOrderVC, animated: true)
                break
            default:
                SVProgressHUD.dismiss()
                let orderDetailVC = OrderDetailViewController()
                orderDetailVC.order = order
                self.navigationController?.pushViewController(orderDetailVC, animated: true)
            }
        }.disposed(by: disposeBag)
        
        orderVM.isSuccess.bind { (isSuccess)  in
            var message = ""
            switch self.scannedOrder!.status {
            case Status.DISPATCH, Status.DISPATCHED:
                message = "Order Confirmed Successfully"
                self.setupSelectedTap(selectedIndex: 1)
            case Status.OPEN_ORDER:
                message = "Order Picked Up Successfully"
                self.setupSelectedTap(selectedIndex: 1)
            case Status.PICKED_UP:
                if self.scannedOrder!.partialPiece > 0,
                   self.scannedOrder!.partialPiece < Int(self.scannedOrder!.piece)!{
                    message = "Order Picked Up Successfully"
                    self.setupSelectedTap(selectedIndex: 1)
                }else{
                    message = "Order Delivered Successfully"
                    self.setupSelectedTap(selectedIndex: 0)
                }
            case Status.DELIVERED:
                message = "Order Round Trip Successfully"
                self.setupSelectedTap(selectedIndex: 0)
            default:
                break
            }
            SVProgressHUD.showSuccess(withStatus: message)
            SVProgressHUD.dismiss(withDelay: 1)
        }.disposed(by: disposeBag)
        
        orderVM.errMsg.bind { (errMsg)  in
            SVProgressHUD.showError(withStatus: errMsg)
            SVProgressHUD.dismiss(withDelay: 1)
        }.disposed(by: disposeBag)
    }
    
    private func registerObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didOrderTapped), name: NotifName.ORDER_TAPPED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dispatchSelected), name: NotifName.DISPATCH_SELECTED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setToSelectAll(_:)), name: NotifName.SET_TO_SELECT_ALL, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupConfirmButton), name: NotifName.ORDER_SELECTED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTitle(_:)), name: NotifName.UPDATE_TITLE, object: nil)
    }
    
    private func removeObserver(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func moveToMoreVC(){
        navigationController?.pushViewController(MoreViewController(), animated: true)
    }
    
    @objc private func dispatchSelected(notif: NSNotification){
        guard let rightBarBtn = rightBarBtn else {
            return
        }
        rightBarBtn.title = "Unselect All"
    }
    
    @objc private func setToSelectAll(_ notification: NSNotification? = nil){
        guard let rightBarBtn = rightBarBtn else {
            return
        }
        rightBarBtn.title = "Select All"
    }
    
    private func moveView(currentIndex:Int){
        
        for label in labels {
            label.textColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.5)
        }
        
        for icon in icons {
            icon.tintColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.5)
        }
        
        for badgeContainerV in badgeContainerVs {
            badgeContainerV.backgroundColor = UIColor(named: "MutedTextColor")!
        }
        
        Global.SELECTED_PAGE_INDEX = currentIndex
        labels[Global.SELECTED_PAGE_INDEX].textColor = Colors.PRIMARY_COLOR
        icons[Global.SELECTED_PAGE_INDEX].tintColor = Colors.PRIMARY_COLOR
        
        badgeContainerVs[Global.SELECTED_PAGE_INDEX].backgroundColor = Colors.PRIMARY_COLOR
        
        self.title = self.vcItems[Global.SELECTED_PAGE_INDEX].title
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let selectedPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        self.moveView(currentIndex: selectedPage)
        
        self.setupNavBar(selectedPage: selectedPage)
    }
    
    private func setupNavBar(selectedPage: Int){
        NotificationCenter.default.post(name: NotifName.CLEAR_SELECTED_ORDER, object: nil)
        
        /// Hide confirm button & show QR scanner button
        confirmV.isHidden = true
        qrScannerV.isHidden = false
        
        if let presentVC = self.vcItems[selectedPage].vc as? PresentViewController{
            rightBarBtn = UIBarButtonItem(title: "Select All", style: .plain,  target: self.vcItems[selectedPage].vc!, action: #selector(presentVC.selectAllAction))
            self.navigationItem.rightBarButtonItem = rightBarBtn
        }else if let dispatchVC = self.vcItems[selectedPage].vc as? DispatchViewController{
            rightBarBtn = UIBarButtonItem(title: "Select All", style: .plain,  target: self.vcItems[selectedPage].vc!,  action: #selector(dispatchVC.selectAllAction))
            acceptBtn.isHidden = false
            dispatchVC.selectAllBtn = rightBarBtn
            self.navigationItem.rightBarButtonItem = rightBarBtn
        }else if let openNextDay = self.vcItems[selectedPage].vc as? OpenViewController{
            rightBarBtn = UIBarButtonItem(title: "Select All", style: .plain,  target: self.vcItems[selectedPage].vc!,  action: #selector(openNextDay.selectAllAction))
            self.navigationItem.rightBarButtonItem = rightBarBtn
        }else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func updateView(index: Int){
        floatingV.isHidden = false
        acceptBtn.isHidden = true
        
        if let deliveryVC = self.vcItems[index].vc as? DeliverViewController{
            title = "Delivered (0)"
            deliveryVC.refreshData()
        }else if let presentVC = self.vcItems[index].vc as? PresentViewController{
            title = "Present (0)"
            presentVC.refreshData()
        }else if let dispatchVC = self.vcItems[index].vc as? DispatchViewController{
            title = "Dispatch (0)"
            acceptBtn.isHidden = false
            dispatchVC.refreshData()
        }else if let openVC = self.vcItems[index].vc as? OpenViewController{
            title = "Open (0)"
            openVC.refreshData()
        }else if let partialVC = self.vcItems[index].vc as? PartialVC{
            title = "Partial (0)"
            partialVC.refreshData()
        }
        setupData()
    }
    
    private func setupSelectedTap(selectedIndex: Int){
        contentColV.selectItem(at: IndexPath(row: selectedIndex, section: 0), animated: true, scrollPosition: .left)
        moveView(currentIndex: selectedIndex)
        setupNavBar(selectedPage: selectedIndex)
        contentColV.reloadData()
    }
    
    @objc private func updateTitle(_ notification: NSNotification){
        guard let orderCount = notification.userInfo?["orderCount"] as? Int, let orderType = notification.userInfo?["orderType"] as? OrderType else { return }
        switch vcItems[Global.SELECTED_PAGE_INDEX].vc {
        case is DeliverViewController:
            if orderType != .DELIVER{
                return
            }
            self.title = "Delivered (\(orderCount))"
        case is PresentViewController:
            if orderType != .PRESENT{
                return
            }
            self.title = "Present (\(orderCount))"
        case is DispatchViewController:
            if orderType != .DISPATCH{
                return
            }
            self.title = "Dispatch (\(orderCount))"
        case is OpenViewController:
            if orderType != .OPEN{
                return
            }
            self.title = "Open (\(orderCount))"
        default:
            break
        }
    }
    
    @objc func hideQrButton(notification: NSNotification){
        floatingV.isHidden = true
    }
    
    @objc func didOrderTapped(notification: NSNotification) {
        if let order = notification.userInfo?["order"] as? Order, let orderType = notification.userInfo?["order_type"] as? OrderType{
            let orderDetailVC = OrderDetailViewController()
            orderDetailVC.order = order
            orderDetailVC.orderType = orderType
            self.navigationController?.pushViewController(orderDetailVC, animated: true)
            return
        }
        
        SVProgressHUD.showError(withStatus: "Order not found")
        SVProgressHUD.dismiss(withDelay: 1)
    }
    
    @objc func setupConfirmButton(notification: NSNotification){        
        guard let isShow = notification.userInfo?["isShow"] as? Bool else { return }
        confirmV.isHidden = !isShow
        qrScannerV.isHidden = isShow
    }
    
    @IBAction func acceptAllDispatchAction(_ sender: Any) {
        let dispatchVC = self.vcItems[Global.SELECTED_PAGE_INDEX].vc as! DispatchViewController
        dispatchVC.confirmAction()
    }
    
    @IBAction func qrScannerAction(_ sender: Any) {
        let qrScannerVC = QrScannerViewController()
        qrScannerVC.delegate = self
        qrScannerVC.modalTransitionStyle = .crossDissolve
        qrScannerVC.modalPresentationStyle = .overCurrentContext
        self.present(qrScannerVC, animated: true, completion: nil)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        confirmV.isHidden = true
        qrScannerV.isHidden = false
        
        if let openVC = self.vcItems[Global.SELECTED_PAGE_INDEX].vc as? OpenViewController{
            openVC.confirmAction()
            return
        } else if let presentVC = self.vcItems[Global.SELECTED_PAGE_INDEX].vc as? PresentViewController{
            presentVC.confirmAction()
            return
        }
        NotificationCenter.default.post(name: NotifName.CONFIRM_ORDER, object: nil)
    }
    
    @IBAction func didTapMenu(_ sender: UIButton) {
        setupSelectedTap(selectedIndex: sender.tag)
    }
}

extension CustomTabBarViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row != Global.SELECTED_PAGE_INDEX{
            return
        }
        updateView(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.contentColV.frame.width, height: self.contentColV.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let viewController = self.vcItems[indexPath.row].vc!
        
        if viewController.isKind(of: DispatchViewController.self){
            (viewController as! DispatchViewController).delegate = self
        }
        
        if viewController.isKind(of: PartialVC.self){
            (viewController as! PartialVC).delegate = self
        }
        
        viewController.view.frame = self.contentColV.frame
        self.addChild(viewController)
        cell.addSubview(viewController.view)
        return cell
    }
}

extension CustomTabBarViewController: QrScannerDelegate{
    func didQrCodeScanned(order: Order) {
        SVProgressHUD.show()
        orderVM.getOrderDetail(orderId: order.id)
    }
}

extension CustomTabBarViewController: MainTabBarDelegate{
    func didFutureMenuTapped() {}
    
    func didCommentsMenuTapped() {}
    
    func didDispatchAccepted() {
        Global.SELECTED_PAGE_INDEX = 1
        contentColV.scrollToItem(at: IndexPath.init(item: Global.SELECTED_PAGE_INDEX, section: 0), at: .left, animated: false)
        moveView(currentIndex: Global.SELECTED_PAGE_INDEX)
    }
    
    func showConfirmButton() {
        confirmV.isHidden = true
        qrScannerV.isHidden = false
    }
    
    func didDataLoaded(orderType: OrderType, count: Int) {
        if orderType == .PARTIAL{
            self.title = "Partial (\(count))"
            return
        }
    }
}

extension CustomTabBarViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate  = manager.location!.coordinate
        let longitude = coordinate.longitude
        let langitude = coordinate.latitude
        
        guard let currentUser = UserDefaultHelper.shared.getUser() else { return }
        let currentDate = DateFormatterHelper.shared.formatDate(dateFormat: "YYYY-MM-dd HH:mm:ss", date: Date(), timezone: TimeZone(identifier: "America/Chicago"))
        
        reference.child(currentUser.id).child("longitude").setValue(longitude)
        reference.child(currentUser.id).child("latitude").setValue(langitude)
        reference.child(currentUser.id).child("timestamp").setValue(currentDate)
    }
}
