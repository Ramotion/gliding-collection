//
//  AppDelegate.swift
//  GlidingCollectionDemo
//
//  Created by Abdurahim Jauzee on 04/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import UIKit
import GlidingCollection

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    setupGlidingCollection()
    return true
  }
  
  private func setupGlidingCollection() {
    var config = GlidingConfig.shared
    config.buttonsFont = UIFont.boldSystemFont(ofSize: 22)
    config.inactiveButtonsColor = config.activeButtonColor
    GlidingConfig.shared = config
  }

}
