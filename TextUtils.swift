//
//  TextUtils.swift
//  AppKit
//
//  Created by Everton Luiz Pascke on 18/11/16.
//  Copyright © 2016 Everton Luiz Pascke. All rights reserved.
//

import Foundation

public class TextUtils {
    
    static func isNotBlank(_ value: String?) -> Bool {
        return !isBlank(value)
    }
    
    static func isBlank(_ value: String?) -> Bool {
        guard let text = value else {
            return true
        }
        return text.isEmpty
    }
    
    public static func text(_ value: Any?) -> String? {
        guard let value = value else {
            return nil
        }
        var text: String?
        if let value = value as? Date {
            text = DateUtils.format(value, type: .dateBr)
        } else if let value = value as? Int {
            text = "\(value)"
        } else if let value = value as? Double {
            text = NumberUtils.format(value)
        } else {
            text = "\(value)"
        }
        return text
    }
    
    static func localized(forKey: String) -> String {
        return Bundle.main.localizedString(forKey: forKey, value: nil, table: nil)
    }
}
