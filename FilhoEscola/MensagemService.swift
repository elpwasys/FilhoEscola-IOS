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
    
    static func sincronizar() throws {
        let url = "\(Config.restURL)/mensagem/buscar"
        let response: DataResponse<[MensagemModel]> = try Network.request(url, method: .post, encoding: JSONEncoding.default, headers: Device.headers).parse()
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
    }
    
    static func buscar() throws -> [MensagemCellModel] {
        return try buscar(nil)
    }
    
    static func buscar(_ predicate: NSPredicate?) throws -> [MensagemCellModel] {
        let realm = try Realm()
        let mensagens: Results<Mensagem>
        if predicate == nil {
            mensagens = realm.objects(Mensagem.self);
        } else {
            mensagens = realm.objects(Mensagem.self).filter(predicate!)
        }
        var keys = [AlunoKey: [Date: [MensagemModel]]]()
        for mensagem in mensagens {
            let model = MensagemModel.from(mensagem)
            for aluno in mensagem.alunos {
                let key = AlunoKey(nome: aluno.nome, nomeMae: aluno.nomeMae, dataNascimento: aluno.dataNascimento as Date)
                var dates = keys[key]
                if dates == nil {
                    dates = [Date: [MensagemModel]]()
                }
                var models = dates![model.data]
                if models == nil {
                    models = [MensagemModel]()
                }
                model.escola = EscolaModel.from(mensagem.escola!)
                model.funcionario = FuncionarioModel.from(mensagem.funcionario!)
                models!.append(model)
                dates![model.data] = models!
                keys[key] = dates!
            }
        }
        var models = [MensagemCellModel]()
        for (key, value) in keys {
            models.append(MensagemCellModel(key: key, dates: value))
        }
        return models
    }
    
    static func buscar(date: Date, sync: Bool = false) throws -> [MensagemDiariaModel] {
        if sync {
            try sincronizar()
        }
        let realm = try Realm()
        var keys = [AlunoKey: [MensagemModel]]()
        //let startday = DateUtils.truncat(date: date)
        let mensagens = realm.objects(Mensagem.self)//.filter(NSPredicate(format: "data == %@", date as NSDate))
        for mensagem in mensagens {
            let model = MensagemModel.from(mensagem)
            for aluno in mensagem.alunos {
                let key = AlunoKey(nome: aluno.nome, nomeMae: aluno.nomeMae, dataNascimento: aluno.dataNascimento as Date)
                var models = keys[key]
                if models == nil {
                    models = [MensagemModel]()
                }
                model.escola = EscolaModel.from(mensagem.escola!)
                model.funcionario = FuncionarioModel.from(mensagem.funcionario!)
                models!.append(model)
                keys[key] = models!
            }
        }
        var models = [MensagemDiariaModel]()
        for (key, value) in keys {
            models.append(MensagemDiariaModel(key: key, mensagens: value))
        }
        return models
    }
    
    class Async {
        static func buscar() -> Observable<[MensagemCellModel]> {
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
        static func buscar(date: Date, sync: Bool = false) -> Observable<[MensagemDiariaModel]> {
            return Observable.create { observer in
                do {
                    let values = try MensagemService.buscar(date: date, sync: sync)
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
