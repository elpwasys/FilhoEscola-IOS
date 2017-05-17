//
//  CodigoViewController.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 16/04/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit

class CodigoViewController: AppViewController {

    @IBOutlet weak var numeroTextField1: UITextField!
    @IBOutlet weak var numeroTextField2: UITextField!
    @IBOutlet weak var numeroTextField3: UITextField!
    @IBOutlet weak var numeroTextField4: UITextField!
    @IBOutlet weak var numeroTextField5: UITextField!
    @IBOutlet weak var numeroTextField6: UITextField!
    
    @IBOutlet weak var validarButton: Button!
    
    var isValid: Bool {
        return TextUtils.isNotBlank(numeroTextField1.text)
            && TextUtils.isNotBlank(numeroTextField2.text)
            && TextUtils.isNotBlank(numeroTextField3.text)
            && TextUtils.isNotBlank(numeroTextField4.text)
            && TextUtils.isNotBlank(numeroTextField5.text)
            && TextUtils.isNotBlank(numeroTextField6.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numeroTextField1.delegate = self
        numeroTextField2.delegate = self
        numeroTextField3.delegate = self
        numeroTextField4.delegate = self
        numeroTextField5.delegate = self
        numeroTextField6.delegate = self
        validarButton.isEnabled = isValid
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onEditingDidEnd() {
        validarButton.isEnabled = isValid
    }
    
    @IBAction func onEditingDidBegin() {
        validarButton.isEnabled = false
    }
    
    @IBAction func onValidarTapped() {
        validar()
    }
    
    @IBAction func onReenviarTapped() {
        reenviar()
    }
    
    private func validar() {
        if isValid, let dispositivo = Dispositivo.current {
            showActivityIndicator()
            let codigo = "\(numeroTextField1.text!)\(numeroTextField2.text!)\(numeroTextField3.text!)\(numeroTextField4.text!)\(numeroTextField5.text!)\(numeroTextField6.text!)"
            let observable = DispositivoService.Async.verificar(prefixo: dispositivo.prefixo, numero: dispositivo.numero, codigo: codigo)
            prepare(for: observable)
                .subscribe(
                    onNext: { model in
                        if model.status == .verificado {
                            self.presentSceneReveal()
                        } else {
                            let message = TextUtils.localized(forKey: "Message.CodigoInvalido")
                            self.showMessage(message)
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

    private func reenviar() {
        if let dispositivo = Dispositivo.current {
            showActivityIndicator()
            let observable = DispositivoService.Async.reenviar(prefixo: dispositivo.prefixo, numero: dispositivo.numero)
            prepare(for: observable)
                .subscribe(
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
    
    private func presentSceneReveal() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Scene.Reveal") {
            self.present(controller, animated: false, completion: nil)
        }
    }
}

extension CodigoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if TextUtils.isNotBlank(string) {
            if range.location > 0 {
                var nextTextField: UITextField
                if textField === numeroTextField1 {
                    nextTextField = numeroTextField2
                } else if textField === numeroTextField2 {
                    nextTextField = numeroTextField3
                } else if textField === numeroTextField3 {
                    nextTextField = numeroTextField4
                } else if textField === numeroTextField4 {
                    nextTextField = numeroTextField5
                } else if textField === numeroTextField5 {
                    nextTextField = numeroTextField6
                } else {
                    nextTextField = numeroTextField1
                }
                nextTextField.text = nil
                nextTextField.becomeFirstResponder()
            }
        } else {
            var nextTextField: UITextField
            if textField === numeroTextField6 {
                nextTextField = numeroTextField5
            } else if textField === numeroTextField5 {
                nextTextField = numeroTextField4
            } else if textField === numeroTextField4 {
                nextTextField = numeroTextField3
            } else if textField === numeroTextField3 {
                nextTextField = numeroTextField2
            } else {
                nextTextField = numeroTextField1
            }
            textField.text = nil
            nextTextField.becomeFirstResponder()
            return false
        }
        return true
    }
}
