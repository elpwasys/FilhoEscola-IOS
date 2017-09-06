//
//  AppDelegate.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 14/04/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var timer: Timer?
    private let pushTokenKey = "\(AppDelegate.self).pushToken"
    
    var pushToken: String? {
        didSet {
            if self.pushToken == nil {
                UserDefaults.standard.removeObject(forKey: pushTokenKey)
            } else {
                UserDefaults.standard.set(self.pushToken, forKey: pushTokenKey)
            }
        }
    }
    
    lazy var pushTokenNotificationName: Notification.Name = {
        return Notification.Name(rawValue: "\(AppDelegate.self).pushTokenNotificationName")
    }()
    
    lazy var didBecomeActiveNotificationName: Notification.Name = {
        return Notification.Name(rawValue: "\(AppDelegate.self).didBecomeActiveNotificationName")
    }()
    
    func clear() {
        self.pushToken = nil
        UIApplication.shared.unregisterForRemoteNotifications()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.sharedManager().enable = true
        URLProtocol.registerClass(AppURLProtocol.self)
        
        let color = Color.primary
        //UITextField.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = color
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(60), repeats: true) { timer in
            try? MensagemService.sincronizar()
        }
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: didBecomeActiveNotificationName, object: application)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var pushToken = String()
        for i in 0..<deviceToken.count {
            pushToken.append(String(format: "%02.2hhx", arguments: [deviceToken[i]]))
        }
        if TextUtils.isNotBlank(pushToken) {
            self.pushToken = pushToken
            NotificationCenter.default.post(name: pushTokenNotificationName, object: pushToken)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let data = userInfo["data"] as? [String: Any] {
            PushNotification.set(data: data)
        }
    }
}
