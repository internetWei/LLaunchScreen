//
//  AppDelegate.swift
//  LLaunchScreen
//
//  Created by LL on 2021/1/31.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("沙盒路径:\(NSHomeDirectory())")
        
        sleep(1)
        
        if #available(iOS 13.0, *) {
        } else {
            window = UIWindow.init(frame: UIScreen.main.bounds)
            let nav = UINavigationController.init(rootViewController: ViewController())
            window?.rootViewController = nav
            window?.makeKeyAndVisible()
        }
        
        LLaunchScreen.finishLaunching()
        
        return true
    }

}

