//
//  BarTableViewCell.swift
//  Bars
//
//  Created by Mariano Latorre on 14/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import UIKit

/*
 Custom cell for displaying bars with name and distance to my current location
 */
class BarTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
}
