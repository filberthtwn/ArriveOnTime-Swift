//
//  RoundedView.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 19/11/21.
//

import Foundation
import UIKit

class RoundedView: UIView{
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup(){
        layoutIfNeeded()
        print(self.frame.height)
        self.layer.cornerRadius = self.frame.height/2
    }
}
