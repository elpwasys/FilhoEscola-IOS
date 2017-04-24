//
//  FrontViewController.swift
//  NavigationDrawer
//
//  Created by Everton Luiz Pascke on 18/10/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class FrontViewController: DrawerViewController {

    @IBOutlet weak var drawerButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        drawerButton.target = revealViewController()
        drawerButton.action = #selector(SWRevealViewController.revealToggle(_:))        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        let navigation = storyboard?.instantiateViewController(withIdentifier: "Scene.Web")
        let controller = navigation?.childViewControllers.first as! WebViewController
        controller.link = "club/consulta.xhtml"
        revealViewController().pushFrontViewController(navigation, animated: true)
    }
}
