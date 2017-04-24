//
//  DrawerViewController.swift
//  NavigationDrawer
//
//  Created by Everton Luiz Pascke on 18/10/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class DrawerViewController: AppViewController, SWRevealViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let controller = revealViewController() {
            controller.delegate = self
            view.addGestureRecognizer(controller.panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        let userInteractionEnabled: Bool
        if position == .left {
            userInteractionEnabled = true
        } else {
            userInteractionEnabled = false
        }
        if position == .right {
            view.endEditing(true)
        }
        view.isUserInteractionEnabled = userInteractionEnabled
    }
}
