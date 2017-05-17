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
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        let navigation = storyboard?.instantiateViewController(withIdentifier: "Scene.Web")
        let controller = navigation?.childViewControllers.first as! WebViewController
        controller.link = "aluno/configuracao.xhtml"
        revealViewController().pushFrontViewController(navigation, animated: true)
    }
}
