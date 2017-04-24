//
//  ViewModel.swift
//  GetDocAg
//
//  Created by Everton Luiz Pascke on 02/03/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation
import ObjectMapper

class ViewModel: Mappable {
    
    var title: String?
    var toolbar: ToolbarModel?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        toolbar <- map["toolbar"]
    }
}
