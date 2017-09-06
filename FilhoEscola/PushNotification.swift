//
//  PushNotification.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 20/08/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

class PushNotification {
    
    private static let dataKey = "\(PushNotification.self).data"
    
    static func set(data: [String: Any]) {
        UserDefaults.standard.set(data, forKey: dataKey)
    }
    
    static func exists() -> Bool {
        return UserDefaults.standard.value(forKey: dataKey) != nil
    }
    
    static func data(remove: Bool = true) -> [String: Any]? {
        let data = UserDefaults.standard.value(forKey: dataKey) as? [String: Any]
        if remove {
            UserDefaults.standard.removeObject(forKey: dataKey)
        }
        return data
    }
    
    static func navigate(from controller: AppViewController, with data: [String: Any]? = nil) {
        var info = data
        if info == nil {
            info = PushNotification.data()
        }
        if let dictionary = info {
            if let type = dictionary["type"] as? String, let id = dictionary["id"] as? Int  {
                if type == "MENSAGEM" {
                    if controller is MensagemViewController {
                        let mensagemViewController = controller as! MensagemViewController
                        mensagemViewController.carregar(id)
                    } else if let revealViewController = controller.revealViewController() {
                        let navigation = controller.storyboard?.instantiateViewController(withIdentifier: "Navigation.Mensagem")
                        if let mensagemViewController = navigation?.childViewControllers.first as? MensagemViewController {
                            mensagemViewController.id = id
                            revealViewController.pushFrontViewController(navigation, animated: true)
                        }
                    }
                }
            }
        }
    }
}
