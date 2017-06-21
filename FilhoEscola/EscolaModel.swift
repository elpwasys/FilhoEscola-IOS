//
//  EscolaModel.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 03/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class EscolaModel: Model {
    
    var logo: Data?
    var nome: String!
    
    var imagem: ImagemModel?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        nome <- map["nome"]
        imagem <- map["logo"]
    }
    
    static func from(_ escola: Escola) -> EscolaModel {
        let model = EscolaModel()
        model.id = escola.id
        model.nome = escola.nome
        if let imagem = escola.imagem {
            model.imagem = ImagemModel.from(imagem)
        }
        return model
    }
}
