//
//  AlunoCadastroViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 04/09/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import AKMaskField

class AlunoCadastroViewController: DrawerViewController {

    @IBOutlet weak var nomeTextField: UITextField!
    @IBOutlet weak var escolaTextField: UITextField!
    @IBOutlet weak var dataNascimentoTextField: AKMaskField!
    
    @IBOutlet weak var salvarButton: UIBarButtonItem!
    
    private var isValid: Bool {
        return TextUtils.isNotBlank(nomeTextField.text)
            && TextUtils.isNotBlank(escolaTextField.text)
            && dataNascimentoTextField.maskStatus == .complete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        salvarButton.isEnabled = isValid
    }
    
    fileprivate func clear() {
        self.nomeTextField.text = nil
        self.escolaTextField.text = nil
        self.dataNascimentoTextField.text = nil
    }
    
    @IBAction func onEditingDidEnd() {
        salvarButton.isEnabled = isValid
    }
    
    @IBAction func onEditingDidBegin() {
        salvarButton.isEnabled = false
    }
    
    @IBAction func onSalvarTapped(_ sender: UIBarButtonItem) {
        let model = AlunoSolicitacaoModel()
        model.alunoNome = nomeTextField.text!
        model.escolaNome = escolaTextField.text!
        model.alunoDataNascimento = DateUtils.parse(dataNascimentoTextField.text!, type: .dateBr)!
        //
        showActivityIndicator()
        let observable = AlunoService.Async.solicitar(model)
        prepare(for: observable)
            .subscribe(
                onNext: { model in
                    if (model.isSuccess) {
                        self.clear()
                        if let message = model.messages?[0] {
                            self.showMessage(message)
                        }
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
