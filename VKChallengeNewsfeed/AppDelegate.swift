//
//  AppDelegate.swift
//  VKChallengeNewsfeed
//
//  Created by Denis Olshin on 09/11/2018.
//  Copyright © 2018 Denis Olshin. All rights reserved.
//

import UIKit
import VK_ios_sdk

extension UIDevice {
  var modelName: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier
  }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var statusBackdropView: UIView! = nil

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let window = self.window!
    
    let olderDevices = ["iPhone4,1", "iPhone5,1", "iPhone5,2", "iPhone5,3", "iPhone5,4", "iPhone6,1", "iPhone6,1"]
    if olderDevices.contains(UIDevice.current.modelName) {
      // Background gradient is barely noticeable, so for performance reason we'll disable it on weaker devices
      window.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1.0)
    } else {
      let backgroundView = GradientView(frame:
          CGRect(x: 0, y: 0,
                 width: max(window.frame.width, window.frame.height),
                 height: max(window.frame.width, window.frame.height)))
      window.addSubview(backgroundView)
    }
    
    statusBackdropView = UIView(frame: application.statusBarFrame)
    statusBackdropView.layer.shadowColor = UIColor.black.cgColor
    statusBackdropView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    statusBackdropView.layer.masksToBounds = false
    statusBackdropView.layer.shadowRadius = 9.0
    statusBackdropView.layer.shadowOpacity = 0.1
    statusBackdropView.backgroundColor = .white
    statusBackdropView.alpha = 0.0
    window.addSubview(statusBackdropView)
    return true
  }
  
  func application(_ application: UIApplication, didChangeStatusBarOrientation oldStatusBarOrientation: UIInterfaceOrientation) {
    
  }
  
  func application(_ application: UIApplication, didChangeStatusBarFrame oldStatusBarFrame: CGRect) {
    if statusBackdropView != nil {
      statusBackdropView.isHidden = !application.isStatusBarHidden
      statusBackdropView.frame = application.statusBarFrame
    }
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    VKSdk.processOpen(url, fromApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
    return true
  }
}

