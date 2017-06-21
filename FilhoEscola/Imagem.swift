//
//  Imagem.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 18/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import RealmSwift

class Imagem: Object {
    
    dynamic var id = 0
    dynamic var caminho = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func from(_ model: ImagemModel) -> Imagem {
        guard let id = model.id else {
            fatalError("ImagemModell.id is nil.")
        }
        let imagem = Imagem()
        imagem.id = id
        imagem.caminho = model.caminho
        return imagem
    }
}
