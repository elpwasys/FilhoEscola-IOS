//
//  Funcionario.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 17/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import RealmSwift

class Funcionario: Object {
    
    dynamic var id = 0
    dynamic var tipo = ""
    dynamic var nome = ""
    dynamic var email = ""
    
    dynamic var escola: Escola?
    
    let mensagens = List<Mensagem>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func from(_ model: FuncionarioModel) -> Funcionario {
        guard let id = model.id else {
            fatalError("FuncionarioModel.id is nil.")
        }
        let funcionario = Funcionario()
        funcionario.id = id
        funcionario.tipo = model.tipo.rawValue
        funcionario.nome = model.nome
        funcionario.email = model.email
        return funcionario
    }
}
