//
//  AcessoViewController.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 15/04/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class AcessoViewController: AppViewController {

    @IBOutlet weak var nomeTextField: TextField!
    @IBOutlet weak var celularTextField: TextField!
    @IBOutlet weak var nascimentoDateField: DateField!
    
    @IBOutlet weak var confirmarButton: Button!
    
    private var isValid: Bool {
        return TextUtils.isNotBlank(nomeTextField.text)
            && celularTextField.maskStatus == .complete
            && nascimentoDateField.maskStatus == .complete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmarButton.isEnabled = isValid
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onEditingDidEnd() {
        confirmarButton.isEnabled = isValid
    }
    
    @IBAction func onEditingDidBegin() {
        confirmarButton.isEnabled = false
    }
    
    @IBAction func onConfirmarTapped() {
        confirmar()
    }
    
    private func confirmar() {
        if let nome = nomeTextField.text, let celular = celularTextField.text, let dataNascimento = nascimentoDateField.date {
            let prefixo = celular.substring(with: 1..<3)
            let numero = celular.substring(from: 5).replacingOccurrences(of: "-", with: "")
            let dispositivo = DispositivoModel(uuid: Device.uuid, nome: nome, numero: numero, prefixo: prefixo, dataNascimento: dataNascimento)
            showActivityIndicator()
            let observable = DispositivoService.Async.confirmar(model: dispositivo)
            prepare(for: observable)
                .subscribe(
                    onNext: { model in
                        self.decideScene(model: model)
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
    
    private func decideScene(model: DispositivoModel) {
        var identifier = "Scene.Codigo"
        if model.status == .verificado {
            identifier = "Scene.BemVindo"
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: identifier) {
            self.present(controller, animated: false, completion: nil)
        }
    }
}
