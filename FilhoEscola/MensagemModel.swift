//
//  MensagemModel.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 03/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

import RealmSwift
import ObjectMapper

class MensagemModel: Model {
    
    var data: Date!
    var dataLeitura: Date?
    var dataEnviada: Date?
    var dataAtualizacao: Date?
    
    var conteudo: String!
    var botaoLink: String?
    var botaoTexto: String?
    
    var status: Status!
    var assunto: Assunto!
    var sincronizacao: Sincronizacao!
    
    var aluno: AlunoModel!
    var escola: EscolaModel!
    var funcionario: FuncionarioModel!
    
    var alunos: [AlunoModel]?
    
    enum Status: String {
        case lida = "LIDA"
        case criada = "CRIADA"
        case atualizada = "ATUALIZADA"
    }
    
    enum Assunto: String {
        case prova = "PROVA"
        case mensagem = "MENSAGEM"
        case atividade = "ATIVIDADE"
        case informacao = "INFORMACAO"
        var key: String {
            return "Mensagem.Assunto.\(self)"
        }
        var label: String {
            return TextUtils.localized(forKey: key)
        }
        var image: UIImage? {
            return UIImage(named: key)
        }
    }
    
    enum Sincronizacao: String {
        case enviada = "ENVIADA"
        case enviando = "ENVIANDO"
        case aguardando = "AGUARDANDO"
    }
    
    override func mapping(map: Map) {
        
        super.mapping(map: map)
        
        let dateTransform = DateTransformType()
        
        data <- (map["data"], dateTransform)
        dataLeitura <- (map["dataLeitura"], dateTransform)
        dataEnviada <- (map["dataEnviada"], dateTransform)
        
        conteudo <- map["conteudo"]
        botaoLink <- map["botaoLink"]
        botaoTexto <- map["botaoTexto"]
        
        status <- map["status"]
        assunto <- map["assunto"]
        sincronizacao <- map["sincronizacao"]
        
        aluno <- map["aluno"]
        escola <- map["escola"]
        funcionario <- map["funcionario"]
    }
    
    static func from(_ mensagem: Mensagem) -> MensagemModel {
        
        let model = MensagemModel()
        
        model.id = mensagem.id
        
        model.data = mensagem.data
        model.dataLeitura = mensagem.dataLeitura
        model.dataEnviada = mensagem.dataEnviada
        model.dataAtualizacao = mensagem.dataAtualizacao
        
        model.conteudo = mensagem.conteudo
        model.botaoLink = mensagem.botaoLink
        model.botaoTexto = mensagem.botaoTexto
        
        model.status = Status.init(rawValue: mensagem.status)
        model.assunto = Assunto.init(rawValue: mensagem.assunto)
        model.sincronizacao = Sincronizacao.init(rawValue: mensagem.sincronizacao)
        
        if let escola = mensagem.escola {
            model.escola = EscolaModel.from(escola)
        }
        
        return model
    }
    
    static func from(_ mensagens: List<Mensagem>) -> [MensagemModel] {
        var models = [MensagemModel]()
        for mensagem in mensagens {
            models.append(from(mensagem))
        }
        return models
    }
}
