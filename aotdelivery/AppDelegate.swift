//
//  AppDelegate.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 16/05/21.
//

import UIKit
import IQKeyboardManagerSwift
import SVProgressHUD
import AWSS3
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window:UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// Configure Firebase
        FirebaseApp.configure()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        var rootViewContoller: UIViewController = LoginViewController()
        if (UserDefaultHelper.shared.getUser() != nil){
            rootViewContoller = CustomNavigationController(rootViewController: CustomTabBarViewController())
        }
        self.window!.rootViewController = rootViewContoller
        self.window!.makeKeyAndVisible()
        
        SVProgressHUD.setDefaultMaskType(.black)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        //* Setup Navigation Controller
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "PrimaryColor")
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        /// Remove Back Button Title
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = backButtonAppearance
        
        initializeS3()
        
        return true
    }
    
    func initializeS3() {
        let poolId = "us-east-1:54e10c90-6466-4c48-9822-c9b43dbd23fe"
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .USEast1,
            identityPoolId: poolId
        )
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
}

