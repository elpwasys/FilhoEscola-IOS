//
//  Aluno.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 17/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import RealmSwift

class Aluno: Object {
    
    dynamic var id = 0
    dynamic var nome = ""
    dynamic var nomeMae = ""
    dynamic var dataNascimento = NSDate()
    
    dynamic var escola: Escola?
    
    let mensagens = List<Mensagem>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func from(_ model: AlunoModel) -> Aluno {
        guard let id = model.id else {
            fatalError("AlunoModel.id is nil.")
        }
        let aluno = Aluno()
        aluno.id = id
        aluno.nome = model.nome
        aluno.nomeMae = model.nomeMae
        aluno.dataNascimento = model.dataNascimento as NSDate
        return aluno
    }
}
