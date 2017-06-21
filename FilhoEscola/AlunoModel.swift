//
//  AlunoModel.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 03/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class AlunoKey: Hashable {
    
    let nome: String
    let nomeMae: String
    let dataNascimento: Date
    
    var hashValue: Int {
        let text = AlunoKey.join(nome: nome, nomeMae: nomeMae, dataNascimento: dataNascimento)
        return text.hashValue
    }
    
    static func join(nome: String, nomeMae: String, dataNascimento: Date) -> String {
        return "\(TextUtils.folding(nome)),\(TextUtils.folding(nomeMae)),\(DateUtils.format(dataNascimento, type: .dateBr))"
    }
    
    static func ==(lhs: AlunoKey, rhs: AlunoKey) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    init(nome: String, nomeMae: String, dataNascimento: Date) {
        self.nome = nome
        self.nomeMae = nomeMae
        self.dataNascimento = dataNascimento
    }
}

class AlunoModel: Model {
    
    var nome: String!
    var nomeMae: String!
    var dataNascimento: Date!
    
    var foto: Data?
    var mensagens: [MensagemModel]?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        let dateTransform = DateTransformType()
        nome <- map["nome"]
        nomeMae <- map["nomeMae"]
        dataNascimento <- (map["dataNascimento"], dateTransform)
        mensagens <- map["mensagens"]
    }
    
    class Key: Hashable {
        
        let nome: String
        let nomeMae: String
        let dataNascimento: Date
        
        var hashValue: Int {
            return "\(nome),\(nomeMae),\(DateUtils.format(dataNascimento, type: .dateBr))".hashValue
        }
        
        static func ==(lhs: Key, rhs: Key) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
        
        init(nome: String, nomeMae: String, dataNascimento: Date) {
            self.nome = nome
            self.nomeMae = nomeMae
            self.dataNascimento = dataNascimento
        }
    }
}
