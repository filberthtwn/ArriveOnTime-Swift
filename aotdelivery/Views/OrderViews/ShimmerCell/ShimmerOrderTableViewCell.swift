//
//  ShimmerOrderTableViewCell.swift
//  aotdelivery
//
//  Created by Filbert Hartawan on 24/05/21.
//

import UIKit

class ShimmerOrderTableViewCell: UITableViewCell {

    @IBOutlet var shimmerContainerV: AOTShimmerView!
    @IBOutlet var shimmerContentV: UIView!
    
    @IBOutlet var views: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.shimmerContainerV.contentView = shimmerContentV
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in self.views {
            view.layer.cornerRadius = view.frame.height/2
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
