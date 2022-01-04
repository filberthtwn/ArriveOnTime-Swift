//
//  AOTShimmerView.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 26/05/21.
//

import Foundation
import UIKit
import Shimmer

class AOTShimmerView: FBShimmeringView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews(){
        self.shimmeringSpeed = 500
        self.isShimmering = true
    }
}
