//
//  CacheModel.swift
//  GetDocAg
//
//  Created by Everton Luiz Pascke on 03/03/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation

class CacheModel {
    
    let data: NSData
    let resource: String
    var mimeType: String?
    var encoding: String?
    
    static let headerKey = "CacheVersion"
    
    init(data: NSData, resource: String) {
        self.data = data
        self.resource = resource
    }
    
    static func from(_ cache: Cache) -> CacheModel {
        let model = CacheModel(data: cache.data!, resource: cache.resource!)
        model.mimeType = cache.mimeType
        model.encoding = cache.encoding
        return model
    }
}
