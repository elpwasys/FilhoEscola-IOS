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
    
    @IBOutlet weak var button: Button!
    @IBOutlet weak var assuntoLabel: UILabel!
    @IBOutlet weak var alunoNomeLabel: UILabel!
    @IBOutlet weak var escolaNomeLabel: UILabel!
    
    @IBOutlet weak var conteudoTextView: UITextView!
    @IBOutlet weak var assuntoImageView: UIImageView!
    
    private var owner: UIViewController?
    
    private var aluno: AlunoModel?
    private var mensagem: MensagemModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let aluno = self.aluno {
            ViewUtils.text(aluno.nome, for: alunoNomeLabel)
        }
        button.isHidden = true
        if let mensagem = self.mensagem {
            ViewUtils.text(mensagem.conteudo, for: conteudoTextView)
            ViewUtils.text(mensagem.assunto.label, for: assuntoLabel)
            assuntoImageView.image = mensagem.assunto.image
            ViewUtils.text(mensagem.escola.nome, for: escolaNomeLabel)
            if let botaoLink = mensagem.botaoLink {
                button.isHidden = false
                button.setTitle(botaoLink, for: .normal)
            }
            if let botaoTexto = mensagem.botaoTexto {
                button.isHidden = false
                button.setTitle(botaoTexto, for: .normal)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onCloseTapped() {
        self.owner?.dismissDialogViewController()
    }
    
    @IBAction func onButtonTapped() {
        if let owner = self.owner, let link = mensagem?.botaoLink, let url = URL(string: link) {
            let controller = ExternalWebViewController.create(url)
            controller.hidesBottomBarWhenPushed = true
            if let botaoLink = mensagem?.botaoLink {
                controller.title = botaoLink
            }
            if let botaoTexto = mensagem?.botaoTexto {
                controller.title = botaoTexto
            }
            if let navigation = owner.navigationController {
                navigation.pushViewController(controller, animated: true)
            }
            owner.dismissDialogViewController()
        }
    }
    
    static func create(aluno: AlunoModel, mensagem: MensagemModel, owner: UIViewController) -> ModalViewController {
        let controller = ModalViewController(nibName: "ModalViewController", bundle: nil)
        controller.aluno = aluno
        controller.mensagem = mensagem
        controller.owner = owner
        return controller
    }
}
