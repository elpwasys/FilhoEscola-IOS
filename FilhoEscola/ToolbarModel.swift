//
//  ToolbarModel.swift
//  GetDocAg
//
//  Created by Everton Luiz Pascke on 02/03/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation
import ObjectMapper

class ToolbarModel: Mappable {
    
    var buttons: [ButtonModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        buttons <- map["buttons"]
    }
}
