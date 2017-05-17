//
//  SeparatorTableViewCell.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 06/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class SeparatorTableViewCell: UITableViewCell {

    static var height: CGFloat {
        return 8
    }
    
    static var nibName: String {
        return "SeparatorTableViewCell"
    }
    
    static var backgroundColor: UIColor {
        return #colorLiteral(red: 0.7842705846, green: 0.7800551057, blue: 0.8006526828, alpha: 1)
    }
    
    static var reusableCellIdentifier: String {
        return "SeparatorTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
