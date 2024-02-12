//
//  DriverTableViewCell.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 25/1/24.
//

import UIKit

class DriverTableViewCell: UITableViewCell {
    
    @IBOutlet weak var driverIMG: UIImageView!
    @IBOutlet weak var driverLBL: UILabel!
    @IBOutlet weak var teamLBL: UILabel!
    @IBOutlet weak var flagIMG: UIImageView!
    @IBOutlet weak var numberLBL: UILabel!
    @IBOutlet weak var cardContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardContainer.layer.cornerRadius = 10
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.5
        cardContainer.layer.shadowOffset = CGSize(width: 6, height: 6)
        cardContainer.layer.shadowRadius = 6 // Adjust the shadow spread as needed

        // Optionally, you can add a border to the view
        cardContainer.layer.borderWidth = 0.7
        cardContainer.layer.borderColor = UIColor.darkGray.cgColor
        
        //Set up GIF Loader
        let loadingGIF = UIImage.gifImageWithName("LoadingTransparent")
        driverIMG.image = loadingGIF
        flagIMG.image = loadingGIF
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


