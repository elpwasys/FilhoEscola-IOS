//
//  ButtonModel.swift
//  GetDocAg
//
//  Created by Everton Luiz Pascke on 02/03/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation
import ObjectMapper

class ButtonModel: Mappable {
    
    var id: Int?
    var src: String?
    var position: Position?
    
    enum Position: String {
        case left = "LEFT"
        case right = "RIGHT"
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        src <- map["src"]
        position <- map["position"]
    }
}
