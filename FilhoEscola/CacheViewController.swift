//
//  CacheViewController.swift
//  GetDocAg
//
//  Created by Everton Luiz Pascke on 04/03/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class CacheViewController: DrawerViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var drawerButton: UIBarButtonItem!
    
    @IBOutlet weak var limparButton: Button!
    
    var version: String {
        if let version = UserDefaults.standard.value(forKey: CacheModel.headerKey) as? String {
            return "\(TextUtils.localized(forKey: "Label.Versao")) \(version)"
        } else {
            return "\(TextUtils.localized(forKey: "Label.Versao")) 0"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawerButton.target = revealViewController()
        drawerButton.action = #selector(SWRevealViewController.revealToggle(_:))
        messageLabel.text = TextUtils.localized(forKey: "Message.Cache")
        versionLabel.text = version
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onLimparTapped() {
        do {
            try CacheService.clear()
        } catch {
            print(error.localizedDescription)
        }
        versionLabel.text = version
    }
}
