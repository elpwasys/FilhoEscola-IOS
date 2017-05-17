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
    
    static func create(_ aluno: AlunoModel, owner: Any?) -> Header {
        let header = Bundle.main.loadNibNamed("Header", owner: owner, options: nil)?.first as! Header
        ViewUtils.text(aluno.nome, for: header.nomeLabel)
        ViewUtils.text(aluno.mensagens?.count ?? 0, for: header.quantidadeLabel)
        if let data = aluno.foto {
            header.fotoImageView.image = UIImage(data: data)
        }
        return header
    }
}
