//
//  CTFBorderedButton.swift
//  ORKCatalog
//
//  Created by James Kizer on 9/16/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import UIKit

class CTFBorderedButton: UIButton {

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
    }
    
    func setBorderAndTitleColor(color: UIColor) {
        self.setTitleColor(color, forState: .Normal)
        self.layer.borderColor = color.CGColor
    }
    var configuredColor: UIColor? {
        didSet {
            if let color = self.configuredColor {
                self.setBorderAndTitleColor(color)
            }
            else {
                self.setBorderAndTitleColor(self.tintColor)
            }
        }
    }
    
    override func tintColorDidChange() {
        //if we have not configured the color, set
        super.tintColorDidChange()
        if let _ = self.configuredColor {
            return
        }
        else {
            self.setBorderAndTitleColor(self.tintColor)
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        let superSize = super.intrinsicContentSize()
        return CGSizeMake(superSize.width + 20.0, superSize.height)
    }

}
