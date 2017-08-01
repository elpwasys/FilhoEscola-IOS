//
//  MessageModel.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 30/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class MessageModel: Mappable {
    
    var type: Type?
    var title: String?
    var content: String!
    
    enum `Type`: String {
        case info = "INFO"
        case error = "ERROR"
        case success = "SUCCESS"
        case warning = "WARNING"
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        type <- map["type"]
        title <- map["title"]
        content <- map["content"]
    }
}
