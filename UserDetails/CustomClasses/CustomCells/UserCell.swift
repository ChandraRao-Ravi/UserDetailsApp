//
//  UserCell.swift
//  UserDetails
//
//  Created by Chandra Rao on 06/12/17.
//  Copyright © 2017 Chandra Rao. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var imgViewUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
