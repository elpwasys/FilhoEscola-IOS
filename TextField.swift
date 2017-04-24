//
//  TextField.swift
//
//  Created by Everton Luiz Pascke on 11/01/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit
import AKMaskField

@IBDesignable
class TextField: AKMaskField {
    
    @IBInspectable var borderColor: UIColor!
    @IBInspectable var borderWidth: CGFloat = 2.0
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            drawLeftImage()
        }
    }
    
    @IBInspectable var rightImage: UIImage? {
        didSet {
            drawRightImage()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        borderStyle = .none
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(borderWidth)
            context.setStrokeColor(borderColor.cgColor)
            context.move(to: CGPoint(x: 0, y: frame.height - borderWidth))
            context.addLine(to: CGPoint(x: frame.width, y: frame.height - borderWidth))
            context.strokePath()
        }
    }
    
    func drawLeftImage() {
        if let image = self.leftImage {
            let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
            imageView.tintColor = textColor
            leftView = imageView
            leftView?.contentMode = .scaleAspectFit
            leftView?.clipsToBounds = true
            leftViewMode = .always
        }
    }
    
    func drawRightImage() {
        if let image = self.rightImage {
            let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
            imageView.tintColor = textColor
            rightView = imageView
            rightView?.contentMode = .scaleAspectFit
            rightView?.clipsToBounds = true
            rightViewMode = .always
        }
    }
}
