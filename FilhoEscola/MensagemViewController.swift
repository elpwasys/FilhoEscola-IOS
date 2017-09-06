//
//  MensagemViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 05/09/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class MensagemViewController: DrawerViewController {

    @IBOutlet weak var button: Button!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var assuntoLabel: UILabel!
    @IBOutlet weak var escolaNomeLabel: UILabel!
    @IBOutlet weak var conteudoTextView: UITextView!
    @IBOutlet weak var assuntoImageView: UIImageView!
    
    var id: Int?
    
    fileprivate var model: MensagemModel?
    fileprivate var models = [AlunoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        carregar()
    }
    
    @IBAction func onButtonTapped() {
        if let link = model?.botaoLink, let url = URL(string: link) {
            let controller = ExternalWebViewController.create(url)
            controller.hidesBottomBarWhenPushed = true
            if let botaoLink = model?.botaoLink {
                controller.title = botaoLink
            }
            if let botaoTexto = model?.botaoTexto {
                controller.title = botaoTexto
            }
            if let navigation = self.navigationController {
                navigation.pushViewController(controller, animated: true)
            }
        }
    }
}

// MARK: Custom
extension MensagemViewController {

    fileprivate func carregar() {
        if let id = self.id {
            carregar(id)
        }
    }
    
    fileprivate func prepare() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = AlunoTableViewCell.separatorInset
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: AlunoTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: AlunoTableViewCell.reusableCellIdentifier)
    }
    
    fileprivate func popular(_ model: MensagemModel) {
        self.model = model
        ViewUtils.text(model.conteudo, for: conteudoTextView)
        ViewUtils.text(model.assunto.label, for: assuntoLabel)
        assuntoImageView.image = model.assunto.image
        ViewUtils.text(model.escola.nome, for: escolaNomeLabel)
        button.isHidden = true
        if let botaoLink = model.botaoLink {
            button.isHidden = false
            button.setTitle(botaoLink, for: .normal)
        }
        if let botaoTexto = model.botaoTexto {
            button.isHidden = false
            button.setTitle(botaoTexto, for: .normal)
        }
        if model.status != .lida {
            do {
                try MensagemService.atualizar(id: model.id, status: .lida)
                
            } catch {
                print(error.localizedDescription)
            }
        }
        if let alunos = model.alunos {
            self.models = alunos
            self.tableView.reloadData()
        }
    }
    
    func carregar(_ id: Int) {
        self.id = id
        showActivityIndicator()
        let observable = MensagemService.Async.obter(id: id)
        prepare(for: observable)
            .subscribe(
                onNext: { model in
                    if model != nil {
                        self.popular(model!)
                    }
                },
                onError: { error in
                    self.hideActivityIndicator()
                    self.handle(error)
                },
                onCompleted: {
                    self.hideActivityIndicator()
                }
            ).addDisposableTo(disposableBag)
    }
}

// MARK: UITableViewDelegate
extension MensagemViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AlunoTableViewCell.height
    }
}

// MARK: UITableViewDataSource
extension MensagemViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlunoTableViewCell.reusableCellIdentifier, for: indexPath) as! AlunoTableViewCell
        let model = models[indexPath.row]
        cell.prepare(model)
        return cell
    }
}
