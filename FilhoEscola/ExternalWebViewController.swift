//
//  ExternalWebViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 18/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class ExternalWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    private var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = self.url {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    static func create(_ url: URL) -> ExternalWebViewController {
        let controller = ExternalWebViewController(nibName: "ExternalWebViewController", bundle: nil)
        controller.url = url
        return controller
    }
}
