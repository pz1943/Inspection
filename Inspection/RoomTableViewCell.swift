//
//  RoomTableViewCell.swift
//  Guard
//
//  Created by apple on 16/1/7.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class RoomTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    @IBOutlet weak var DoneFlagImageView: UIView!
    @IBOutlet weak var roomTitle: UILabel!
    
    var room: Room?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
