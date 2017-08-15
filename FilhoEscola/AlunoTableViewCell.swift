//
//  AlunoTableViewCell.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 08/08/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

class AlunoTableViewCell: UITableViewCell {

    @IBOutlet weak var fotoImageView: CircleImage!
    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var quantidadeLabel: CircleLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: Statics
extension AlunoTableViewCell {
    
    static var height: CGFloat {
        return 72
    }
    
    static var nibName: String {
        return "\(AlunoTableViewCell.self)"
    }
    
    static var reusableCellIdentifier: String {
        return "\(AlunoTableViewCell.self)"
    }
    
    static var separatorInset: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)
    }
}

extension AlunoTableViewCell {
    
    func prepare(_ model: AlunoModel) {
        ViewUtils.text(model.nome, for: nomeLabel)
        ViewUtils.text(model.mensagens?.count ?? 0, for: quantidadeLabel)
    }
}
