//
//  BetterButton.swift
//  BankaMerchant
//
//  Created by Franco Rivera on 3/17/19.
//  Copyright © 2019 Banka. All rights reserved.
//

import UIKit

@IBDesignable class BetterButton : UIButton {
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
}
