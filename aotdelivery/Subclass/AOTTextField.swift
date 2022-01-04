//
//  AOTTextField.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import Foundation
import UIKit

class AOTTextField: UITextField{
    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    private func setupViews(){
        self.layer.cornerRadius = 10
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: Colors.PLACEHOLDER_COLOR, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)])
    }
    
    func setAsDropdown(){
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 26, height: 12))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.image = UIImage(named: "ChevronDownIcon")
        self.rightView = view
        self.tintColor = .clear
        self.rightViewMode = .always
    }
}


class AOTTextFieldGroup: UIView{
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    private func setupViews(){
        self.layer.cornerRadius = 10
    }
}
