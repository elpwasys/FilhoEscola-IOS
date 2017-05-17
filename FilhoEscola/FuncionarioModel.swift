//
//  FuncionarioModel.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 17/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class FuncionarioModel: Model {
    
    var tipo: Tipo!
    var nome: String!
    var email: String!
    
    enum Tipo: String {
        case principal = "PRINCIPAL"
        case professor = "PROFESSOR"
        case secretaria = "SECRETARIA"
        var key: String {
            return "Funcionario.Tipo.\(self)"
        }
        var label: String {
            return TextUtils.localized(forKey: key)
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        tipo <- map["tipo"]
        nome <- map["nome"]
        email <- map["email"]
    }
}
