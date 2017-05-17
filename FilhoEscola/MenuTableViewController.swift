//
//  MenuTableViewController.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 15/04/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit
import TOCropViewController

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
            ViewUtils.text(dispositivo.nome, for: nomeLabel)
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
            //link = "club/assinatura.xhtml"
        } else if indexPath.row == 2 {
            link = "aluno/configuracao.xhtml"
        } else if indexPath.row == 3 {
            let controller = storyboard?.instantiateViewController(withIdentifier: "Scene.Mensagem")
            revealViewController().pushFrontViewController(controller, animated: true)
        } else if indexPath.row == 5 {
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
}

extension MenuTableViewController: UINavigationControllerDelegate {
    
}

extension MenuTableViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let controller = TOCropViewController(image: image)
            controller.delegate = self
            //controller.aspectRatioPickerButtonHidden = true
            present(controller, animated: true, completion: nil)
        }
    }
}

extension MenuTableViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToCircleImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        
    }
}
