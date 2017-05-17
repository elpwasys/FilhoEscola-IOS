//
//  MensagemModel.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 03/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
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
}
