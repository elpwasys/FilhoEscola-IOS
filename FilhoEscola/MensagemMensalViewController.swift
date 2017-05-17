//
//  MensagemMensalViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 02/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class MensagemMensalModel {
    
    var aluno: AlunoModel
    var mensagens: [Date: [MensagemModel]]?
    
    init(aluno: AlunoModel, mensagens: [Date: [MensagemModel]]?) {
        self.aluno = aluno
        self.mensagens = mensagens
    }
}

class MensagemMensalViewController: DrawerViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var rows = [MensagemMensalModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.title = TextUtils.localized(forKey: "Label.Mensal")
        carregar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.register(UINib(nibName: SeparatorTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: SeparatorTableViewCell.reusableCellIdentifier)
        tableView.register(UINib(nibName: MensagemMensalTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: MensagemMensalTableViewCell.reusableCellIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func carregar() {
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
            let row = MensagemMensalModel(aluno: aluno, mensagens: nil)
            rows.append(row)
        }
    }
}

extension MensagemMensalViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let aluno = rows[section].aluno
        let header = Header.create(aluno, owner: tableView)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = MensagemMensalTableViewCell.height
        if indexPath.row == 1 {
            if indexPath.section < (rows.count - 1) {
                height = SeparatorTableViewCell.height
            } else {
                height = 0
            }
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Header.height
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension MensagemMensalViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        var cell: UITableViewCell
        if row == 0 {
            let mensagemCell = tableView.dequeueReusableCell(withIdentifier: MensagemMensalTableViewCell.reusableCellIdentifier, for: indexPath) as! MensagemMensalTableViewCell
            cell = mensagemCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: SeparatorTableViewCell.reusableCellIdentifier, for: indexPath) as! SeparatorTableViewCell
        }
        return cell
    }
}

