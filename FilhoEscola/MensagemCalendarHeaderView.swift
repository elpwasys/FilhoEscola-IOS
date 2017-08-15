//
//  MensagemCalendarHeaderView.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 08/08/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class MensagemCalendarHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var dataLabel: CircleLabel!
    
    func prepare(_ data: Date) {
        ViewUtils.text(data, for: dataLabel)
    }
}

// MARK: Statics
extension MensagemCalendarHeaderView {
    
    static var height: CGFloat {
        return 38
    }
    
    static var nibName: String {
        return "\(MensagemCalendarHeaderView.self)"
    }
    
    static var reusableCellIdentifier: String {
        return "\(MensagemCalendarHeaderView.self)"
    }
}
