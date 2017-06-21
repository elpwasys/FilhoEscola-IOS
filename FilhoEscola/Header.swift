//
//  Header.swift
//  TableViewExpandable
//
//  Created by Everton Luiz Pascke on 04/05/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class Header: UIView {

    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var fotoImageView: CircleImage!
    @IBOutlet weak var quantidadeLabel: CircleLabel!
    
    static var height: CGFloat {
        return 65
    }
    
    static func create(_ key: AlunoKey, count: Int, owner: Any?) -> Header {
        let header = Bundle.main.loadNibNamed("Header", owner: owner, options: nil)?.first as! Header
        ViewUtils.text(key.nome, for: header.nomeLabel)
        ViewUtils.text(count, for: header.quantidadeLabel)
        /*
        if let data = key.foto {
            header.fotoImageView.image = UIImage(data: data)
        }
         */
        return header
    }
}
