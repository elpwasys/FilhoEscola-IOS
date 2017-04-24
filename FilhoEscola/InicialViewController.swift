//
//  InicialViewController.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 15/04/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class InicialViewController: AppViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func navigate() {
        var identifier = "Scene.Acesso"
        if let dispositivo = DispositivoModel.current {
            identifier = "Scene.Codigo"
            if dispositivo.status == .verificado {
                identifier = "Scene.Reveal"
            }
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: identifier) {
            self.present(controller, animated: false, completion: nil)
        }
    }
}
