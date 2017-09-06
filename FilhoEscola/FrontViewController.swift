//
//  FrontViewController.swift
//  NavigationDrawer
//
//  Created by Everton Luiz Pascke on 18/10/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class FrontViewController: DrawerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        if PushNotification.exists() {
            PushNotification.navigate(from: self)
        } else {
            let identifier = "Scene.Web"
            let navigation: UIViewController
            if let _ = UserDefaults.standard.value(forKey: identifier) {
                navigation = (storyboard?.instantiateViewController(withIdentifier: "Navigation.AlunoList"))!
            } else {
                UserDefaults.standard.set(true, forKey: identifier)
                navigation = (storyboard?.instantiateViewController(withIdentifier: identifier))!
                let controller = navigation.childViewControllers.first as! WebViewController
                controller.link = "aluno/configuracao.xhtml"
            }
            revealViewController().pushFrontViewController(navigation, animated: true)
        }
    }
}
