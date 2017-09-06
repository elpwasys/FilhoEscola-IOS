//
//  AlunoTableViewCell.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 08/08/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit

protocol AlunoTableViewCellDelegate {
    
    func onThumbnailTapped(_ cell: AlunoTableViewCell)
}

class AlunoTableViewCell: UITableViewCell {

    @IBOutlet weak var fotoImageView: CircleImage!
    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var quantidadeLabel: CircleLabel!
    
    var delegate: AlunoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onPhotoTapped))
        fotoImageView.addGestureRecognizer(gestureRecognizer)
        fotoImageView.isUserInteractionEnabled = true
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
        var count = 0
        if let mensagens = model.mensagens {
            for mensagem in mensagens {
                if mensagem.status != .lida {
                    count += 1
                }
            }
        }
        if count == 0 {
            quantidadeLabel.text = nil
            quantidadeLabel.isHidden = true
        } else {
            quantidadeLabel.isHidden = false
            ViewUtils.text(count, for: quantidadeLabel)
        }
        if let data = model.foto {
            fotoImageView.image = UIImage(data: data)
        } else {
            fotoImageView.image = UIImage(named: "Userpic");
        }
    }
    
    @objc fileprivate func onPhotoTapped() {
        if let delegate = self.delegate {
            delegate.onThumbnailTapped(self)
        }
    }
}
