//
//  Designable.swift
//  BinguUser
//
//  Created by User on 17/08/17.
//  Copyright © 2017 Ajayy. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class RoundViewClass: UIView
{
    override func layoutSubviews()
    {
        layer.cornerRadius = bounds.size.width/2;
    }
    @IBInspectable var clipToBound: Bool = false {
        didSet {
            self.clipsToBounds = clipsToBounds
        }
    }
    
    @IBInspectable var maskToBounds : Bool = false  {
        didSet {
            layer.masksToBounds = maskToBounds
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


@IBDesignable class SpeedShopperTextField : UITextField
{
    @IBInspectable var clipToBound: Bool = false {
        didSet {
            self.clipsToBounds = clipsToBounds
        }
    }
    
    @IBInspectable var maskToBounds : Bool = false  {
        didSet {
            layer.masksToBounds = maskToBounds
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

@IBDesignable class SpeedShopperButton : UIButton
{
    @IBInspectable var clipToBound: Bool = false {
        didSet {
            self.clipsToBounds = clipsToBounds
        }
    }
    
    @IBInspectable var maskToBounds : Bool = false  {
        didSet {
            layer.masksToBounds = maskToBounds
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

@IBDesignable class SetViewClass : UIView
{
    override func layoutSubviews()
    {
        //layer.cornerRadius = bounds.size.width/2;
    }
    
    @IBInspectable var clipToBound: Bool = false {
        didSet {
            self.clipsToBounds = clipsToBounds
        }
    }
    
    @IBInspectable var maskToBounds : Bool = false  {
        didSet {
            layer.masksToBounds = maskToBounds
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var shadowColor:UIColor = .clear
        {
        didSet{
            self.layer.masksToBounds = false
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowOpacity = 0.5
            self.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.layer.shadowRadius = 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

@IBDesignable class SmartFoodImage: UIImageView
{
    override func layoutSubviews()
    {
        layer.cornerRadius = self.frame.size.width / 2 // bounds.size.width/2;
    }
    
    @IBInspectable var clipToBound: Bool = true {
        didSet {
            self.clipsToBounds = clipsToBounds
        }
    }
    
    @IBInspectable var maskToBounds : Bool = true  {
        didSet {
            layer.masksToBounds = maskToBounds
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

@IBDesignable class LableDesign: UILabel {
   
}


