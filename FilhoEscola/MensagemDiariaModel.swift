//
//  MensagemDiariaModel.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 17/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

class MensagemDiariaModel {
    
    let key: AlunoKey
    var mensagens: [MensagemModel]
    
    var count: Int {
        return mensagens.count
    }
    
    init(key: AlunoKey, mensagens: [MensagemModel]) {
        self.key = key
        self.mensagens = mensagens
    }
}
