//
//  App.swift
//
//  Created by Everton Luiz Pascke on 06/11/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import Foundation

import SwiftMessages
import SystemConfiguration

class App {
    static let locale = Locale(identifier: "pt_BR")
    class Message {
        var theme = Theme.info
        var layout: MessageView.Layout?
        var title: String?
        var content: String!
        var dimMode: SwiftMessages.DimMode?
        var duration: SwiftMessages.Duration?
        var presentationStyle: SwiftMessages.PresentationStyle?
        var presentationContext: SwiftMessages.PresentationContext?
        func show(_ sender: Any) {
            let view: MessageView
            if let layout = self.layout {
                switch layout {
                case .TabView:
                    view = MessageView.viewFromNib(layout: .TabView)
                case .CardView:
                    view = MessageView.viewFromNib(layout: .CardView)
                case .StatusLine:
                    view = MessageView.viewFromNib(layout: .StatusLine)
                default:
                    view = try! SwiftMessages.viewFromNib()
                }
            } else {
                view = try! SwiftMessages.viewFromNib()
            }
            view.configureContent(
                title: title,
                body: content,
                iconImage: nil,
                iconText: nil,
                buttonImage: nil,
                buttonTitle: nil,
                buttonTapHandler: { _ in
                    SwiftMessages.hide()
            }
            )
            switch theme {
            case .info:
                view.configureTheme(.info)
            case .error:
                view.configureTheme(.error)
            case .success:
                view.configureTheme(.success)
            case .warning:
                view.configureTheme(.warning)
                /*default:
                 view.configureTheme(backgroundColor: UIColor.black, foregroundColor: UIColor.white)
                 */
            }
            view.configureDropShadow()
            view.button?.isHidden = true
            view.iconLabel?.isHidden = true
            view.iconImageView?.isHidden = true
            view.bodyLabel?.textAlignment = .center
            if self.title == nil {
                view.titleLabel?.isHidden = true
            }
            var config = SwiftMessages.defaultConfig
            if let dimMode = self.dimMode {
                config.dimMode = dimMode
            }
            if let duration = self.duration {
                config.duration = duration
            }
            if let presentationStyle = self.presentationStyle {
                config.presentationStyle = presentationStyle
            }
            if let presentationContext = self.presentationContext {
                config.presentationContext = presentationContext
            }
            if case .top = config.presentationStyle {
                switch theme {
                case .error, .success, .warning:
                    config.preferredStatusBarStyle = .lightContent
                default:
                    break
                }
            }
            SwiftMessages.show(config: config, view: view)
        }
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

class Device {
    
    static var so: String {
        return "IOS"
    }
    
    static var uuid: String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    static var model: String {
        return UIDevice.current.model
    }
    
    static var width: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static var height: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    static var appVersion: String? {
        guard let dictionary = Bundle.main.infoDictionary, let version = dictionary["CFBundleVersion"] as? String else {
            return nil
        }
        return version
    }
    
    static var isNetworkAvailable: Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
