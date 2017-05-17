//
//  MensagemDiariaViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 02/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import LSDialogViewController

class MensagemDiariaModel {
    
    var aluno: AlunoModel
    var mensagens: [MensagemModel]?
    
    init(aluno: AlunoModel, mensagens: [MensagemModel]?) {
        self.aluno = aluno
        self.mensagens = mensagens
    }
}

class MensagemDiariaViewController: DrawerViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var rows = [MensagemDiariaModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.title = TextUtils.localized(forKey: "Label.Diaria")
        carregar()
        popular()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.register(UINib(nibName: SeparatorTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: SeparatorTableViewCell.reusableCellIdentifier)
        tableView.register(UINib(nibName: MensagemDiariaTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: MensagemDiariaTableViewCell.reusableCellIdentifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func carregar() {
        showActivityIndicator()
        let observable = MensagemService.Async.buscar()
        prepare(for: observable)
            .subscribe(
                onNext: { values in
                    
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
    
    private func popular() {
        for i in 1...5 {
            let aluno = AlunoModel()
            if i % 2 == 0 {
                aluno.foto = UIImageJPEGRepresentation(UIImage(named: "aluno1.jpg")!, 1)
            } else {
                aluno.foto = UIImageJPEGRepresentation(UIImage(named: "aluno2.jpg")!, 1)
            }
            aluno.nome = "Nome do aluno \(i)"
            aluno.nomeMae = "Mãe do aluno \(i)"
            aluno.dataNascimento = Date()
            var mensagens = [MensagemModel]()
            for j in i...5 {
                let mensagem = MensagemModel()
                mensagem.data = Date()
                mensagem.escola = EscolaModel()
                mensagem.escola.nome = "Escola \(j)"
                if j % 2 == 0 {
                    mensagem.assunto = .prova
                    mensagem.conteudo = TextUtils.localized(forKey: "Fake.Conteudo.Mensagem.1")
                    mensagem.escola.logo = UIImageJPEGRepresentation(UIImage(named: "escola1.jpg")!, 1)
                } else {
                    mensagem.assunto = .informacao
                    mensagem.conteudo = TextUtils.localized(forKey: "Fake.Conteudo.Mensagem.2")
                    mensagem.escola.logo = UIImageJPEGRepresentation(UIImage(named: "escola2.jpg")!, 1)
                }
                mensagens.append(mensagem)
            }
            aluno.mensagens = mensagens
            let row = MensagemDiariaModel(aluno: aluno, mensagens: mensagens)
            rows.append(row)
        }
    }
}

extension MensagemDiariaViewController: UISearchDisplayDelegate {
    
}

extension MensagemDiariaViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let aluno = rows[section].aluno
        let header = Header.create(aluno, owner: tableView)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = UITableViewAutomaticDimension
        let mensagens = rows[indexPath.section].mensagens!
        if mensagens.count == indexPath.row {
            if indexPath.section < (rows.count - 1) {
                height = SeparatorTableViewCell.height
            } else {
                height = 0
            }
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
 
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Header.height
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return false
        }
        let should = cell is MensagemDiariaTableViewCell
        return should
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = ModalViewController(nibName: "ModalViewController", bundle: nil)
        self.presentDialogViewController(controller, animationPattern: .zoomInOut, backgroundViewType: .gradient, dismissButtonEnabled: true)
    }
}

extension MensagemDiariaViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if let mensagens = rows[section].mensagens {
            numberOfRows = mensagens.count + 1
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        var cell: UITableViewCell
        if row == rows[indexPath.section].mensagens!.count {
            cell = tableView.dequeueReusableCell(withIdentifier: SeparatorTableViewCell.reusableCellIdentifier, for: indexPath) as! SeparatorTableViewCell
        } else {
            let mensagemCell = tableView.dequeueReusableCell(withIdentifier: MensagemDiariaTableViewCell.reusableCellIdentifier, for: indexPath) as! MensagemDiariaTableViewCell
            let mensagem = rows[indexPath.section].mensagens![row]
            mensagemCell.popular(mensagem, cellForRowAt: indexPath)
            cell = mensagemCell
        }
        return cell
    }
}
