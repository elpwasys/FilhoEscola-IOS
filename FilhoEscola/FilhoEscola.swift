//
//  Getdoc.swift
//  GetDocAg
//
//  Created by Everton Luiz Pascke on 08/02/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation

class AppAcesso {
    private static let validKey = "\(AppAcesso.self).validKey"
    static var isValid: Bool {
        get {
            guard let valid = UserDefaults.standard.value(forKey: validKey) as? Bool else {
                return false
            }
            return valid
        }
        set {
            UserDefaults.standard.set(newValue, forKey: validKey)
        }
    }
}

class AppUser {
    let id: Int
    let name: String
    var pushToken: String? {
        didSet {
            if self.pushToken == nil {
                UserDefaults.standard.removeObject(forKey: AppUser.userPushTokenKey)
            } else {
                UserDefaults.standard.set(self.pushToken, forKey: AppUser.userPushTokenKey)
            }
        }
    }
    private static let userIdKey = "\(AppUser.self).id"
    private static let userNameKey = "\(AppUser.self).name"
    private static let userPushTokenKey = "\(AppUser.self).pushToken"
    static var current: AppUser? {
        guard let id = UserDefaults.standard.value(forKey: userIdKey) as? Int, let name = UserDefaults.standard.value(forKey: userNameKey) as? String else {
            return nil
        }
        let user = AppUser(id: id, name: name)
        user.pushToken = UserDefaults.standard.value(forKey: userPushTokenKey) as? String
        return user
    }
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        UserDefaults.standard.set(id, forKey: AppUser.userIdKey)
        UserDefaults.standard.set(name, forKey: AppUser.userNameKey)
    }
    static func clear() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: userNameKey)
        UserDefaults.standard.removeObject(forKey: userPushTokenKey)
    }
}

class Config {
    // homologacao: http://186.231.6.42:8586/getdoc_ag
    static var plist: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "config", ofType: "plist") else {
            fatalError("File config.plist does not exist.")
        }
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String : Any] else {
            fatalError("Failed to create Dictionary for config.plist.")
        }
        return dictionary
    }()
    static var host: String {
        return value(forKey: "Host")
    }
    static var port: String {
        return value(forKey: "Port")
    }
    static var context: String {
        return value(forKey: "ContextApp")
    }
    static var `protocol`: String {
        return value(forKey: "Protocol")
    }
    static var restURL: String {
        let contextRest = value(forKey: "ContextRest")
        return "\(Config.baseURL)/\(contextRest)"
    }
    static var baseURL: String {
        return "\(Config.protocol)://\(Config.host):\(Config.port)/\(Config.context)"
    }
    static var mobileURL: String {
        let contextMobile = value(forKey: "ContextMobile")
        return "\(Config.baseURL)/\(contextMobile)"
    }
    static func value(forKey: String) -> String {
        guard let value = plist[forKey] as? String else {
            fatalError("Could not find property '\(forKey)' in config.plist.")
        }
        return value
    }
}

extension Device {
    enum Header: String {
        case userId = "User-ID"
        case deviceSO = "Device-SO"
        case deviceID = "Device-ID"
    }
    static var headers: [String: String] {
        var headers = [
            Device.Header.deviceSO.rawValue: Device.so,
            Device.Header.deviceID.rawValue: Device.uuid
        ]
        if let user = AppUser.current {
            headers[Device.Header.userId.rawValue] = "\(user.id)"
        }
        return headers
    }
}
