//
//  AlunoSolicitacaoModel.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 05/09/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class AlunoSolicitacaoModel: Model {
    
    var alunoNome: String!
    var escolaNome: String!
    var alunoDataNascimento: Date!
    
    var dictionary: [String: Any] {
        return [
            "alunoNome": alunoNome,
            "escolaNome": escolaNome,
            "alunoDataNascimento": DateUtils.format(alunoDataNascimento, type: .dateBr)
        ]
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        alunoNome <- map["alunoNome"]
        escolaNome <- map["escolaNome"]
        alunoDataNascimento <- map["alunoDataNascimento"]
    }
}
