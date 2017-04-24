//
//  Cache.swift
//  GetDocAg
//
//  Created by Everton Luiz Pascke on 03/03/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation
import RealmSwift

class Cache: Object {
    
    dynamic var data: NSData? = nil
    dynamic var resource: String? = nil
    dynamic var mimeType: String? = nil
    dynamic var encoding: String? = nil
    
    override static func primaryKey() -> String? {
        return "resource"
    }
    
    static func from(_ model: CacheModel) -> Cache {
        let cache = Cache()
        cache.data = model.data
        cache.resource = model.resource
        cache.mimeType = model.mimeType
        cache.encoding = model.encoding
        return cache
    }
}
