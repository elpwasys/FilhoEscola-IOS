//
//  MensagemService.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 17/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire
import RealmSwift

class MensagemService: Service {
    
    static func buscar() throws -> [MensagemModel] {
        let url = "\(Config.restURL)/mensagem/buscar"
        let response: DataResponse<[MensagemModel]> = Alamofire.request(url, method: .post, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let values = result.value!
        var alunos = [Int: Aluno]()
        var escolas = [Int: Escola]()
        var funcionarios = [Int: Funcionario]()
        // ESTRUTURACAO DOS DADOS
        for value in values {
            var aluno = alunos[value.aluno.id]
            if aluno == nil {
                aluno = Aluno.from(value.aluno)
                alunos[value.aluno.id] = aluno
            }
            var escola = escolas[value.escola.id]
            if escola == nil {
                escola = Escola.from(value.escola)
                escolas[value.escola.id] = escola
            }
            var funcionario = funcionarios[value.funcionario.id]
            if funcionario == nil {
                funcionario = Funcionario.from(value.funcionario)
                funcionarios[value.funcionario.id] = funcionario
            }
            // MENSAGEM
            let mensagem = Mensagem.from(value)
            mensagem.escola = escola
            mensagem.funcionario = funcionario
            // ALUNO
            aluno!.escola = escola
            aluno!.mensagens.append(mensagem)
            // FUNCIONARIO
            funcionario!.escola = escola
            funcionario!.mensagens.append(mensagem)
            // ESCOLA
            escola!.mensagens.append(mensagem)
            if !(escola!.alunos.contains { return $0.id == aluno!.id }) {
                escola!.alunos.append(aluno!)
            }
            if !(escola!.funcionarios.contains { return $0.id == funcionario!.id }) {
                escola!.funcionarios.append(funcionario!)
            }
        }
        let realm = try Realm()
        try realm.write {
            for (_ , aluno) in alunos {
                realm.add(aluno, update: true)
            }
            for (_ , escola) in escolas {
                realm.add(escola, update: true)
            }
            for (_ , funcionario) in funcionarios {
                realm.add(funcionario, update: true)
            }
        }
        return values
    }
    
    class Async {
        static func buscar() -> Observable<[MensagemModel]> {
            return Observable.create { observer in
                do {
                    let values = try MensagemService.buscar()
                    observer.onNext(values)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
    }
}