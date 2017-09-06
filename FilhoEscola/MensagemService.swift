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
    
    static func exists(id: Int) throws -> Bool {
        let realm = try Realm()
        let results = realm.objects(Mensagem.self).filter("id = %ld", id)
        return !results.isEmpty
    }
    
    static func obter(id: Int, sync: Bool = false) throws -> MensagemModel? {
        if sync {
            try buscar() // FIXME: MUDAR ISSO BUSCAR POR ID NO SERVIDOR
        }
        let realm = try Realm()
        let results = realm.objects(Mensagem.self).filter("id = %ld", id)
        if let mensagem = results.first {
            let mensagemModel = MensagemModel.from(mensagem)
            mensagemModel.alunos = [AlunoModel]()
            for aluno in mensagem.alunos {
                let alunoModel = AlunoModel.from(aluno, withMessages: false)
                mensagemModel.alunos?.append(alunoModel)
            }
            return mensagemModel
        }
        return nil
    }
    
    static func filter(id: Int) throws -> MensagemModel? {
        let realm = try Realm()
        let results = realm.objects(Mensagem.self).filter("id = %ld", id)
        if let mensagem = results.first {
            let model = MensagemModel.from(mensagem)
            return model
        }
        return nil
    }
    
    static func atualizar(id: Int, status: MensagemModel.Status) throws {
        let realm = try Realm()
        let mensagem = realm.objects(Mensagem.self).filter("id = %ld", id).first!
        try realm.write {
            mensagem.status = status.rawValue
        }
    }
    
    static func sincronizar() throws {
        let realm = try Realm()
        var results = realm.objects(Mensagem.self).filter("status = %@ and sincronizacao = %@", MensagemModel.Status.lida.rawValue, MensagemModel.Sincronizacao.aguardando.rawValue);
        if !results.isEmpty {
            var ids = [Int]()
            for mensagem in results {
                ids.append(mensagem.id)
            }
            if !ids.isEmpty {
                try realm.write {
                    for mensagem in results {
                        mensagem.sincronizacao = MensagemModel.Sincronizacao.enviando.rawValue
                    }
                }
                // Enviar para o servidor
                var sincronizacao = MensagemModel.Sincronizacao.enviada
                let url = "\(Config.restURL)/mensagem/sincronizar/ios"
                let dictionary = ["id": ids]
                let response: DataResponse<ResultModel> = try Network.request(url, method: .post, parameters: dictionary, headers: Device.headers).parse()
                let result = response.result
                if result.isFailure {
                    // caso der erro no servidor
                    sincronizacao = .aguardando
                }
                results = realm.objects(Mensagem.self).filter("id in %ld", ids)
                try realm.write {
                    for mensagem in results {
                        mensagem.sincronizacao = sincronizacao.rawValue
                        if sincronizacao == .enviada {
                            mensagem.dataEnviada = Date()
                        }
                    }
                }
            }
        }
    }
    
    static func buscar() throws {
        let url = "\(Config.restURL)/mensagem/buscar"
        let response: DataResponse<[MensagemModel]> = try Network.request(url, method: .post, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let values = result.value!
        var alunos = [AlunoKey: Aluno]()
        var escolas = [Int: Escola]()
        var funcionarios = [Int: Funcionario]()
        // ESTRUTURACAO DOS DADOS
        for value in values {
            var aluno = alunos[value.aluno.key]
            if aluno == nil {
                let alunoModel: AlunoModel
                if let model = try AlunoService.get(value.aluno.key) {
                    model.atualizar(value.aluno)
                    alunoModel = model
                } else {
                    alunoModel = value.aluno
                }
                aluno = Aluno.from(alunoModel)
                alunos[value.aluno.key] = aluno
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
            // OBTEM O ANTERIOR
            if let model: MensagemModel = try filter(id: value.id!) {
                let dirty = (value.data != model.data)
                    || (value.assunto != model.assunto)
                        || (value.conteudo != model.conteudo)
                            || (value.botaoLink != model.botaoLink)
                                || (value.botaoTexto != model.botaoTexto)
                if dirty {
                    mensagem.status = MensagemModel.Status.atualizada.rawValue
                    mensagem.sincronizacao = MensagemModel.Sincronizacao.aguardando.rawValue
                    mensagem.dataEnviada = nil // LIMPA
                    mensagem.dataLeitura = nil // LIMPA
                    mensagem.dataAtualizacao = Date()
                } else {
                    mensagem.status = model.status.rawValue
                    mensagem.sincronizacao = model.sincronizacao.rawValue
                    mensagem.dataEnviada = model.dataEnviada
                    mensagem.dataLeitura = model.dataLeitura
                    mensagem.dataAtualizacao = model.dataAtualizacao
                }
            } else {
                var status = MensagemModel.Status.criada
                if value.status != nil { // SERVIDOR ENVIOU STATUS?
                    status = value.status
                }
                mensagem.status = status.rawValue
                var sincronizacao = MensagemModel.Sincronizacao.aguardando
                if value.sincronizacao != nil { // SERVIDOR ENVIOU SINCRONIZACAO?
                    sincronizacao = value.sincronizacao
                    if sincronizacao == .enviada {
                        mensagem.dataLeitura = value.dataLeitura
                        mensagem.dataEnviada = value.dataEnviada
                    }
                }
                mensagem.sincronizacao = sincronizacao.rawValue
            }
            // ALUNO
            aluno!.escola = escola
            aluno!.mensagens.append(mensagem)
            // FUNCIONARIO
            funcionario!.escola = escola
            funcionario!.mensagens.append(mensagem)
            // ESCOLA
            escola!.mensagens.append(mensagem)
            if !(escola!.alunos.contains { return $0.key == aluno!.key }) {
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
    
    class Async {
        static func obter(id: Int) -> Observable<MensagemModel?> {
            return Observable.create { observer in
                do {
                    let result = try MensagemService.obter(id: id)
                    observer.onNext(result)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
    }
}
