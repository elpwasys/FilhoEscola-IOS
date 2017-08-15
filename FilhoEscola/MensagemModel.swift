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
    var conteudo: String!
    var botaoLink: String?
    var botaoTexto: String?
    
    var assunto: Assunto!
    var aluno: AlunoModel!
    var escola: EscolaModel!
    var funcionario: FuncionarioModel!
    
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
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        let dateTransform = DateTransformType()
        data <- (map["data"], dateTransform)
        conteudo <- map["conteudo"]
        botaoLink <- map["botaoLink"]
        botaoTexto <- map["botaoTexto"]
        assunto <- map["assunto"]
        aluno <- map["aluno"]
        escola <- map["escola"]
        funcionario <- map["funcionario"]
    }
    
    static func from(_ mensagem: Mensagem) -> MensagemModel {
        let model = MensagemModel()
        model.id = mensagem.id
        model.data = mensagem.data as Date
        model.conteudo = mensagem.conteudo
        model.botaoLink = mensagem.botaoLink
        model.botaoTexto = mensagem.botaoTexto
        model.assunto = Assunto.init(rawValue: mensagem.assunto)
        model.escola = EscolaModel.from(mensagem.escola!)
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
