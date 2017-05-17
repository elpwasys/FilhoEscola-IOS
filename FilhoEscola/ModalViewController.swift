//
//  ModalViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 08/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import LSDialogViewController

class ModalViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.frame.size = CGSize(width: Device.width - 64, height: Device.height - 144)
        //tapLSDialogBackgroundView(closeButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
