//
//  MensagemMensalViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 02/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class MensagemMensalViewController: DrawerViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var rows = [MensagemCellModel]()
    
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
        showActivityIndicator()
        let observable = MensagemService.Async.buscar()
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
    
    private func carregar(_ rows: [MensagemCellModel]) {
        self.rows = rows
        self.tableView.reloadData()
    }
}

extension MensagemMensalViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let key = rows[section].key
        let count = rows[section].count
        let header = Header.create(key, count: count, owner: tableView)
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
            let mensagem = rows[indexPath.section]
            mensagemCell.popular(mensagem, owner: self)
            cell = mensagemCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: SeparatorTableViewCell.reusableCellIdentifier, for: indexPath) as! SeparatorTableViewCell
        }
        return cell
    }
}

extension MensagemMensalViewController: MensagemMensalTableViewCellDelegate {
    
    func onOpenCalendarTapped(_ model: MensagemCellModel) {
        let controller = MensagemCalendarViewController.create(model)
        controller.hidesBottomBarWhenPushed = true
        if let navigation = self.navigationController {
            navigation.pushViewController(controller, animated: true)
        }
    }
}

