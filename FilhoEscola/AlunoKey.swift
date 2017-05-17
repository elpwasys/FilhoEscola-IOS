//
//  AlunoKey.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 17/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class AlunoKey: Mappable {
    
    var key: Key!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        key <- map["key"]
    }

    class Key: Mappable {
        
        var nome: String!
        var nomeMae: String!
        var dataNascimento: Date!
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            let dateTransform = DateTransformType()
            nome <- map["nome"]
            nomeMae <- map["nomeMae"]
            dataNascimento <- (map["dataNascimento"], dateTransform)
        }
    }
}
