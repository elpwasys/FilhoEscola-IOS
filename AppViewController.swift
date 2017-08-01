//
//  AppViewController.swift
//
//  Created by Everton Luiz Pascke on 28/10/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import UIKit
import RxSwift

class AppViewController: UIViewController {

    private var overlay: UIView!
    private var indicator: UIActivityIndicatorView!
    
    let disposableBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func prepare<T>(for observable: Observable<T>) -> Observable<T> {
        return observable
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
        
    func showMessage(_ message: String) {
        var view: UIView
        /*
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            view = (delegate.window?.subviews.first)!
        } else {
            view = super.view
        }
         */
        view = super.view
        view.makeToast(message: message)
    }
    
    func handle(_ error: Error) {
        let message = App.Message()
        message.theme = .error
        if error is Trouble {
            let trouble = error as! Trouble
            message.content = trouble.description
            switch trouble {
            case .any(_ ):
                message.dimMode = .gray(interactive: true)
                message.duration = .forever
                message.presentationStyle = .bottom
                message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            case .server(_ , _):
                message.dimMode = .gray(interactive: true)
                message.duration = .forever
                message.presentationStyle = .bottom
                message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            case .internetNotAvailable(_):
                message.layout = .StatusLine
                message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            }
        } else {
            message.dimMode = .gray(interactive: true)
            message.duration = .forever
            message.presentationStyle = .bottom
            message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            if let error = error as? URLError {
                switch error.code {
                case .cancelled:
                    return
                case .cannotConnectToHost:
                    message.content = TextUtils.localized(forKey: "Message.ServidorIndisponivel")
                case .notConnectedToInternet:
                    let message = TextUtils.localized(forKey: "Message.InternetIndisponivel")
                    handle(Trouble.internetNotAvailable(message))
                    return
                default:
                    message.content = error.localizedDescription
                }
            } else {
                message.content = error.localizedDescription
            }
        }
        message.show(self)
    }
    
    func showActivityIndicator() {
        if overlay == nil {
            // Overlay
            overlay = UIView(frame: view.frame)
            overlay.center = view.center
            overlay.alpha = 0.5
            overlay.backgroundColor = UIColor.black
            // Indicator
            indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            indicator.hidesWhenStopped = true
            indicator.center = overlay.center
            indicator.startAnimating()
            // Add subview
            var overlayView: UIView
            /*
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                overlayView = (delegate.window?.subviews.first)!
            } else {
                overlayView = view
            }
            */
            overlayView = super.view
            overlayView.addSubview(overlay)
            overlay.addSubview(indicator)
        }
    }
    
    func hideActivityIndicator() {
        if overlay != nil {
            indicator.stopAnimating()
            overlay.removeFromSuperview()
            overlay = nil
            indicator = nil
        }
    }
}
