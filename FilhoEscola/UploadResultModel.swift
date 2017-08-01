//
//  UploadResultModel.swift
//  GetDocAg
//
//  Created by Everton Luiz Pascke on 03/03/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation
import ObjectMapper

class UploadResultModel: Mappable {
    
    var names: [String]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        names <- map["names"]
    }
}
