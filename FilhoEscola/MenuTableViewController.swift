//
//  MenuTableViewController.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 15/04/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit
import Kingfisher

class MenuTableViewController: UITableViewController {

    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    fileprivate var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if let dispositivo = Dispositivo.current {
            self.update(dispositivo)
        }
        let center = NotificationCenter.default
        center.addObserver(forName: Dispositivo.updateNotificationName, object: nil, queue: nil) { notification in
            if let dispositivo = notification.object as? Dispositivo {
                self.update(dispositivo)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var link: String!
        if indexPath.row == 0 {
            link = "aluno/configuracao.xhtml"
        } else if indexPath.row == 1 {
            link = "meu-cadastro.xhtml"
        } else if indexPath.row == 2 {
            link = "aluno/configuracao.xhtml"
        } else if indexPath.row == 3 {
            let navigation = storyboard?.instantiateViewController(withIdentifier: "Navigation.AlunoList")
            revealViewController().pushFrontViewController(navigation, animated: true)
        } else if indexPath.row == 4 {
            link = "ajuda.xhtml"
        } else if indexPath.row == 5 {
            let navigation = storyboard?.instantiateViewController(withIdentifier: "Navigation.AlunoCadastro")
            revealViewController().pushFrontViewController(navigation, animated: true)
        } else if indexPath.row == 6 {
            let navigation = storyboard?.instantiateViewController(withIdentifier: "Scene.Cache")
            revealViewController().pushFrontViewController(navigation, animated: true)
        }
        
        if link != nil {
            let navigation = storyboard?.instantiateViewController(withIdentifier: "Scene.Web")
            let controller = navigation?.childViewControllers.first as! WebViewController
            controller.link = link
            revealViewController().pushFrontViewController(navigation, animated: true)
        }
    }
    
    @IBAction func onCircleViewTapped(_ sender: Any) {
       
    }
    
    private func sair() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "Scene.Inicial") {
            Dispositivo.current = nil
            try? CacheService.clear()
            present(controller, animated: true, completion: nil)
        }
    }
    
    private func update(_ dispositivo: Dispositivo) {
        ViewUtils.text(dispositivo.nome, for: nomeLabel)
        if dispositivo.imagemURI != nil {
            if let url = URL(string: "\(Config.fileURL)/\(dispositivo.imagemURI!)") {
                imageView.kf.setImage(with: url)
            }
        }
    }
}
