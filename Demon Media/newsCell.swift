//
//  newsCell.swift
//  Demon Media
//
//  Created by Daniel Wildman on 27/04/2017.
//  Copyright © 2017 Daniel Wildman. All rights reserved.
//

import UIKit

class newsCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func draw(_ rect: CGRect) {
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail  // or .byWordWrapping
        titleLabel.minimumScaleFactor = 0.5
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
