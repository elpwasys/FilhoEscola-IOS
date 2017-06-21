//
//  Mensagem.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 17/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import RealmSwift

class Mensagem: Object {
    
    dynamic var id = 0
    dynamic var data = NSDate()
    dynamic var assunto = ""
    dynamic var conteudo = ""
    dynamic var botaoLink: String? = nil
    dynamic var botaoTexto: String? = nil
    
    dynamic var escola: Escola?
    dynamic var funcionario: Funcionario?
    
    let alunos = LinkingObjects(fromType: Aluno.self, property: "mensagens")

    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func from(_ model: MensagemModel) -> Mensagem {
        guard let id = model.id else {
            fatalError("MensagemModel.id is nil.")
        }
        let mensagem = Mensagem()
        mensagem.id = id
        mensagem.data = model.data as NSDate
        mensagem.assunto = model.assunto.rawValue
        mensagem.conteudo = model.conteudo
        mensagem.botaoLink = model.botaoLink
        mensagem.botaoTexto = model.botaoTexto
        return mensagem
    }
}
