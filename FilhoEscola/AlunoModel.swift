//
//  AlunoModel.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 03/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

import RealmSwift
import ObjectMapper

class AlunoKey: Hashable {
    
    let nome: String
    let nomeMae: String
    let dataNascimento: Date
    
    var hashValue: Int {
        let text = AlunoKey.join(nome: nome, nomeMae: nomeMae, dataNascimento: dataNascimento)
        return text.hashValue
    }
    
    static func ==(lhs: AlunoKey, rhs: AlunoKey) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    static func join(nome: String, nomeMae: String, dataNascimento: Date) -> String {
        return "\(TextUtils.folding(nome)),\(TextUtils.folding(nomeMae)),\(DateUtils.format(dataNascimento, type: .dateBr))"
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
    
    lazy var key: AlunoKey = {
       return AlunoKey(nome: self.nome, nomeMae: self.nomeMae, dataNascimento: self.dataNascimento)
    }()
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        let dateTransform = DateTransformType()
        nome <- map["nome"]
        nomeMae <- map["nomeMae"]
        dataNascimento <- (map["dataNascimento"], dateTransform)
        mensagens <- map["mensagens"]
    }
    
    func atualizar(_ model: AlunoModel) {
        nome = model.nome
        nomeMae = model.nomeMae
        dataNascimento = model.dataNascimento
    }
    
    static func from(_ aluno: Aluno, withMessages: Bool = true) -> AlunoModel {
        let model = AlunoModel()
        model.nome = aluno.nome
        model.foto = aluno.foto
        model.nomeMae = aluno.nomeMae
        model.dataNascimento = aluno.dataNascimento as Date
        if (withMessages) {
            model.mensagens = MensagemModel.from(aluno.mensagens)
        }
        return model
    }
    
    static func from(_ results: Results<Aluno>) -> [AlunoModel] {
        var models = [AlunoModel]()
        for result in results {
            models.append(from(result))
        }
        return models
    }
}
