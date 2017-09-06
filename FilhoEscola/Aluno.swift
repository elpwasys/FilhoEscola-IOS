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
    
    dynamic var key = 0
    dynamic var nome = ""
    dynamic var nomeMae = ""
    dynamic var foto: Data? = nil
    dynamic var dataNascimento = NSDate()
    
    dynamic var escola: Escola?
    
    let mensagens = List<Mensagem>()
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    static func from(_ model: AlunoModel) -> Aluno {
        let aluno = Aluno()
        aluno.key = model.key.hashValue
        aluno.foto = model.foto
        aluno.nome = model.nome
        aluno.nomeMae = model.nomeMae
        aluno.dataNascimento = model.dataNascimento as NSDate
        return aluno
    }
}
