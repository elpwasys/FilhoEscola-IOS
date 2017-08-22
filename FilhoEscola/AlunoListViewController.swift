//
//  AlunoListViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 07/08/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import RxSwift

class AlunoListViewController: DrawerViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var models = [AlunoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if models.isEmpty {
            self.carregar()
        } else {
            self.tableView.reloadData()
        }
    }
}

extension AlunoListViewController {
    
    func carregar() {
        self.iniciarAsyncTask()
    }
    
    fileprivate func prepare() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = AlunoTableViewCell.separatorInset
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: AlunoTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: AlunoTableViewCell.reusableCellIdentifier)
    }
}

// MARK: Async Task methods
extension AlunoListViewController {
    
    fileprivate func iniciarAsyncTask() {
        self.showActivityIndicator()
        let observable = AlunoService.Async.listar(sync: true)
        prepare(for: observable).subscribe(
            onNext: { models in
                self.iniciarDidLoadAsyncTask(models)
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

// MARK: Did load async task methods
extension AlunoListViewController {
    
    fileprivate func iniciarDidLoadAsyncTask(_ models: [AlunoModel]) {
        self.models = models
        self.tableView.reloadData()
    }
}

// MARK: UITableViewDelegate
extension AlunoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "Scene.MensagemCalendar") as! MensagemCalendarViewController
        controller.aluno = model
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AlunoTableViewCell.height
    }
}

// MARK: UITableViewDataSource
extension AlunoListViewController: UITableViewDataSource {
    
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
