//
//  MensagemSemanalViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 02/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class MensagemSemanalViewController: DrawerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = TextUtils.localized(forKey: "Label.Semanal")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
