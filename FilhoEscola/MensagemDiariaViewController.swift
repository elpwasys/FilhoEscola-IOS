//
//  MensagemDiariaViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 02/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import LSDialogViewController

/*
class MensagemDiariaModel {
    
    var aluno: AlunoModel
    var mensagens: [MensagemModel]?
    
    init(aluno: AlunoModel, mensagens: [MensagemModel]?) {
        self.aluno = aluno
        self.mensagens = mensagens
    }
}
 */

class MensagemDiariaViewController: DrawerViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var rows = [MensagemDiariaModel]()
    
    private var today = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.title = DateUtils.format(today, type: .dateBr)
        carregar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.register(UINib(nibName: SeparatorTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: SeparatorTableViewCell.reusableCellIdentifier)
        tableView.register(UINib(nibName: MensagemDiariaTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: MensagemDiariaTableViewCell.reusableCellIdentifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onRefreshTapped(_ sender: UIBarButtonItem) {
        self.carregar()
    }
    
    private func carregar() {
        showActivityIndicator()
        let observable = MensagemService.Async.buscar(date: today, sync: true)
        prepare(for: observable)
            .subscribe(
                onNext: { values in
                    self.carregar(values)
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
    
    private func carregar(_ rows: [MensagemDiariaModel]) {
        self.rows = rows
        self.tableView.reloadData()
    }
}

extension MensagemDiariaViewController: UISearchDisplayDelegate {
    
}

extension MensagemDiariaViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let key = rows[section].key
        let count = rows[section].count
        let header = Header.create(key, count: count, owner: tableView)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = UITableViewAutomaticDimension
        let mensagens = rows[indexPath.section].mensagens
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
        let model = rows[indexPath.section]
        let key = model.key
        let mensagem = model.mensagens[indexPath.row]
        let controller = ModalViewController.create(key: key, mensagem: mensagem, owner: self)
        self.presentDialogViewController(controller, animationPattern: .zoomInOut, backgroundViewType: .gradient, dismissButtonEnabled: true)
    }
}

extension MensagemDiariaViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].mensagens.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        var cell: UITableViewCell
        if row == rows[indexPath.section].mensagens.count {
            cell = tableView.dequeueReusableCell(withIdentifier: SeparatorTableViewCell.reusableCellIdentifier, for: indexPath) as! SeparatorTableViewCell
        } else {
            let mensagemCell = tableView.dequeueReusableCell(withIdentifier: MensagemDiariaTableViewCell.reusableCellIdentifier, for: indexPath) as! MensagemDiariaTableViewCell
            let mensagem = rows[indexPath.section].mensagens[row]
            mensagemCell.popular(mensagem, cellForRowAt: indexPath)
            cell = mensagemCell
        }
        return cell
    }
}
