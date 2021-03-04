//
//  SceneDelegate.swift
//  LLaunchScreen
//
//  Created by LL on 2021/1/31.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let windowScene = scene as! UIWindowScene
        window = UIWindow.init(windowScene: windowScene)
        let nav = UINavigationController.init(rootViewController: ViewController())
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
                
        guard let _ = (scene as? UIWindowScene) else { return }
    }

}

