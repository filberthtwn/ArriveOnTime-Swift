//
//  UIView+Ext.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 07/06/21.
//

import Foundation
import UIKit

extension UIView{
    func roundCorners(corners: UIRectCorner, radius: CGFloat){
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
