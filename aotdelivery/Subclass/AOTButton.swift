//
//  AOTButton.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import Foundation
import UIKit

class AOTButton: UIButton{
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
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel?.textColor = .white
    }
    
    func disable(){
        isEnabled = false
        layer.backgroundColor = Colors.PLACEHOLDER_COLOR.cgColor
    }
    
    func enable(){
        isEnabled = true
        layer.backgroundColor = Colors.PRIMARY_COLOR.cgColor
    }
}
