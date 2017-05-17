//
//  Escola.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 17/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import RealmSwift

class Escola: Object {
    
    dynamic var id = 0
    dynamic var nome = ""
    
    let alunos = List<Aluno>()
    let mensagens = List<Mensagem>()
    let funcionarios = List<Funcionario>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func from(_ model: EscolaModel) -> Escola {
        guard let id = model.id else {
            fatalError("EscolaModel.id is nil.")
        }
        let escola = Escola()
        escola.id = id
        escola.nome = model.nome
        return escola
    }
}
