//
//  MensagemDiariaTableViewCell.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 06/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import Kingfisher

class MensagemDiariaTableViewCell: UITableViewCell {

    @IBOutlet weak var assuntoLabel: UILabel!
    @IBOutlet weak var conteudoLabel: UILabel!
    @IBOutlet weak var escolaImageView: UIImageView!
    @IBOutlet weak var assuntoImageView: UIImageView!
    
    static var nibName: String {
        return "MensagemDiariaTableViewCell"
    }
    
    static var reusableCellIdentifier: String {
        return "MensagemDiariaTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func popular(_ mensagem: MensagemModel, cellForRowAt indexPath: IndexPath) {
        ViewUtils.text(mensagem.conteudo, for: conteudoLabel)
        ViewUtils.text(mensagem.assunto.label, for: assuntoLabel)
        assuntoImageView.image = mensagem.assunto.image
        if let imagem = mensagem.escola.imagem {
            if let url = URL(string: "\(Config.fileURL)/\(imagem.caminho!)") {
                escolaImageView.kf.setImage(with: url)
            }
        }
    }
}
