//
//  AppDelegate.swift
//  SpeechRecognizer
//
//  Created by bighiung on 2024/1/30.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private lazy var keyWindow = {
        return UIWindow(frame: UIScreen.main.bounds)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let rootNavController = UINavigationController(rootViewController: MainViewController())
        keyWindow.rootViewController = rootNavController
        keyWindow.makeKeyAndVisible()
        return true
    }

}
