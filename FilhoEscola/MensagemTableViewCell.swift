//
//  MensagemTableViewCell.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 06/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import Kingfisher

class MensagemTableViewCell: UITableViewCell {

    @IBOutlet weak var assuntoLabel: UILabel!
    @IBOutlet weak var conteudoLabel: UILabel!
    @IBOutlet weak var escolaImageView: UIImageView!
    @IBOutlet weak var assuntoImageView: UIImageView!
}

// MARK: Statics
extension MensagemTableViewCell {
    
    static var height: CGFloat {
        return 140
    }
    
    static var nibName: String {
        return "\(MensagemTableViewCell.self)"
    }
    
    static var reusableCellIdentifier: String {
        return "\(MensagemTableViewCell.self)"
    }
    
    static var separatorInset: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

// MARK: Custom
extension MensagemTableViewCell {
    func prepare(_ mensagem: MensagemModel) {
        ViewUtils.text(mensagem.conteudo, for: conteudoLabel)
        ViewUtils.text(mensagem.assunto.label, for: assuntoLabel)
        conteudoLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
        if mensagem.status != .lida {
            conteudoLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightBold)
        }
        assuntoImageView.image = mensagem.assunto.image
        if let imagem = mensagem.escola.imagem {
            if let url = URL(string: "\(Config.fileURL)/\(imagem.caminho!)") {
                escolaImageView.kf.setImage(with: url)
            }
        }
    }
}
