//
//  DrawerViewController.swift
//  NavigationDrawer
//
//  Created by Everton Luiz Pascke on 18/10/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import UIKit
import UserNotifications

class DrawerViewController: AppViewController {
    
    fileprivate var overlay: UIView!
    var drawerButton: UIBarButtonItem!
    
    var isLeftMenu = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareDrawer()
        prepareOverlay()
        UNUserNotificationCenter.current().delegate = self
        self.initObservers()
        self.askPushToken()
    }
    
    override func showActivityIndicator() {
        if let controller = revealViewController() {
            App.Loading.shared.show(view: controller.view)
        } else {
            super.showActivityIndicator()
        }
    }
}

extension DrawerViewController {
    
    fileprivate func prepareOverlay() {
        if overlay == nil {
            overlay = UIView()
            overlay.frame = view.frame
            overlay.center = view.center
            overlay.alpha = 0.5
            overlay.backgroundColor = UIColor.black
            overlay.clipsToBounds = true
        }
    }
    
    fileprivate func prepareDrawer() {
        if isLeftMenu {
            if let controller = revealViewController() {
                controller.delegate = self
                drawerButton = UIBarButtonItem(image: Icon.menu, style: .plain, target: nil, action: nil)
                drawerButton.target = controller
                drawerButton.action = #selector(SWRevealViewController.revealToggle(_:))
                navigationItem.setLeftBarButton(drawerButton, animated: true)
                view.addGestureRecognizer(controller.panGestureRecognizer())
                view.addGestureRecognizer(controller.tapGestureRecognizer())
            }
        }
    }
    
    fileprivate func initObservers() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let center = NotificationCenter.default
            center.addObserver(forName: delegate.pushTokenNotificationName, object: nil, queue: nil) { notification in
                if let pushToken = notification.object as? String {
                    self.answerPushToken(pushToken: pushToken)
                }
            }
            center.addObserver(forName: delegate.didBecomeActiveNotificationName, object: nil, queue: nil) { notification in
                self.askPushToken()
            }
        }
    }
    
    fileprivate func askPushToken() {
        if let dispositivo = Dispositivo.current {
            if dispositivo.pushToken == nil {
                if let delegate = UIApplication.shared.delegate as? AppDelegate, let pushToken = delegate.pushToken {
                    self.answerPushToken(pushToken: pushToken)
                } else {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
                        if granted {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func answerPushToken(pushToken: String) {
        let observable = DispositivoService.Async.atualizar(pushToken: pushToken)
        prepare(for: observable)
            .subscribe(
                onError: { error in
                    self.handle(error)
                }
            ).addDisposableTo(disposableBag)
    }
}

extension DrawerViewController: SWRevealViewControllerDelegate {
    
        func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        if position == .right {
            view.endEditing(true)
            view.addSubview(overlay)
        } else {
            overlay.removeFromSuperview()
        }
    }
}

extension DrawerViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        let request = notification.request
        let content = request.content
        let userInfo = content.userInfo
        if let data = userInfo["data"] as? [String: Any] {
            PushNotification.navigate(from: self, with: data)
        }
        completionHandler()
    }
}
