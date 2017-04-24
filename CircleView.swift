//
//  CircleView.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 15/04/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit

@IBDesignable
class CircleView: View {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        updateLayerSettings()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateLayerSettings()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerSettings()
    }
    
    private func updateLayerSettings() {
        layer.cornerRadius = frame.size.height*0.5
        layer.masksToBounds = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
    }

}
