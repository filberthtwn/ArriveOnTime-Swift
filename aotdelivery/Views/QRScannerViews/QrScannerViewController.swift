//
//  QrScannerViewController.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 07/06/21.
//

import UIKit
import AVFoundation
import SVProgressHUD
import SwiftyJSON

protocol QrScannerDelegate {
    func didQrCodeScanned(order: Order)
}

class QrScannerViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    @IBOutlet var overlayV: UIView!
    @IBOutlet var panV: UIView!
    @IBOutlet var panVBottom: NSLayoutConstraint!
    @IBOutlet var toggleLineV: UIView!
    @IBOutlet var flashV: UIView!
    
    @IBOutlet var cameraContainerV: UIView!
    @IBOutlet var scannerV: UIView!
    @IBOutlet var flashIV: UIImageView!

    var delegate: QrScannerDelegate?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.panVBottom.constant = -self.panV.frame.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.15) {
            self.panVBottom.constant = 0
            self.view.layoutIfNeeded()
        }
        
        self.setupCamera()
//
//        self.disposeBag = DisposeBag()
//        self.observeViewModel()
    }
    
    private func setupViews(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.overlayAction(_:)))
        self.overlayV.addGestureRecognizer(tapGesture)
        
        self.toggleLineV.layer.cornerRadius = self.toggleLineV.frame.height/2
        
        self.panV.roundCorners(corners: [.topLeft, .topRight], radius: 30)
        self.flashV.layer.cornerRadius = self.flashV.frame.height/2
        self.cameraContainerV.layer.cornerRadius = 10
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        self.panV.addGestureRecognizer(panGesture)
    }
    
    private func setupCamera(){
        // Check camera permission
        self.checkCameraPermission { (isGranted) in
            if isGranted{
                DispatchQueue.main.async {
                    self.setupCaptureSessions()
                }
            }else{
                SVProgressHUD.showError(withStatus: "This app does not have permission to access the camera.")
                SVProgressHUD.dismiss(withDelay: 1) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func checkCameraPermission(completion: @escaping(_ isGranted:Bool) -> Void){
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
            case .denied:
                completion(false)
                break
            case .restricted:
                completion(false)
                break
            case .authorized:
                completion(true)
                break
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            default:
                break
        }
    }
    
    private func setupCaptureSessions(){
        self.captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch(let error) {
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            SVProgressHUD.dismiss(withDelay: 1)
            return
        }
        
        if (self.captureSession.canAddInput(videoInput)) {
            self.captureSession.addInput(videoInput)
        } else {
            SVProgressHUD.showError(withStatus: "Scanner not supported")
            SVProgressHUD.dismiss(withDelay: 1)
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if (self.captureSession.canAddOutput(metadataOutput)) {
            self.captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr,.ean8, .ean13, .pdf417, .upce, .code39, .code39Mod43, .code93, .code128, .aztec]
        } else {
            SVProgressHUD.showError(withStatus: "Scanner not supported")
            SVProgressHUD.dismiss(withDelay: 1)
            return
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        print(self.scannerV.layer.bounds)
        
        self.previewLayer.frame = self.scannerV.layer.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.scannerV.layer.addSublayer(self.previewLayer)
        
        self.captureSession.startRunning()
    }
    
    @objc private func overlayAction(_ gesture: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.15) {
            self.panVBottom.constant = -self.panV.frame.height
            self.view.layoutIfNeeded()
        } completion: { (isDone) in
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer){
        let location = (self.view.frame.height - gesture.location(in: self.view).y) - self.panV.frame.height
        switch gesture.state {
        case .began:
            break
        case .changed:
            if self.panVBottom.constant <= 0{
                self.panVBottom.constant = location
            }
            if self.panVBottom.constant > 0{
                self.panVBottom.constant = 0
            }
        case .ended:
            if self.panVBottom.constant < -(self.panV.frame.height * 0.5){
                self.dismiss(animated: true, completion: nil)
            }else{
                self.panVBottom.constant = 0
            }
        default:
            break
        }
    }
    
    @IBAction func flashAction(_ sender: Any) {
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("Camera not available")
            return
        }
        if device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    if device.torchMode == .off{
                        device.torchMode = .on
                        self.flashIV.tintColor = UIColor(red: 65/255, green: 139/255, blue: 226/255, alpha: 1)
                        self.flashV.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.50)
                    }else{
                        device.torchMode = .off
                        self.flashIV.tintColor = .white
                        self.flashV.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.25)
                    }
                    device.unlockForConfiguration()
                } catch {
                    SVProgressHUD.showError(withStatus: "Torch could not be used")
                    SVProgressHUD.dismiss(withDelay: 1)
                }
        } else {
            SVProgressHUD.showError(withStatus: "Torch is not available")
            SVProgressHUD.dismiss(withDelay: 1)
        }
    }
    
}

extension QrScannerViewController: AVCaptureMetadataOutputObjectsDelegate{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {        
        if let metadataObject = metadataObjects.first {
           guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
           guard let stringValue = readableObject.stringValue else { return }
           AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            if (self.captureSession?.isRunning == true) {
                self.captureSession.stopRunning()
            }
            
            let order = Order()
            order.id = stringValue
            self.dismiss(animated: true, completion: nil)
            self.delegate?.didQrCodeScanned(order: order)
       }
    }
    
}

