//
//  MessageTableViewCell.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 17/2/24.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageTXT: UILabel!
    @IBOutlet weak var usernameTXT: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
