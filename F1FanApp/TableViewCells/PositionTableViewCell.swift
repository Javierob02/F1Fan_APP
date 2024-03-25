//
//  PositionTableViewCell.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 22/3/24.
//

import UIKit

class PositionTableViewCell: UITableViewCell {

    @IBOutlet weak var cardContainer: UIView!
    
    @IBOutlet weak var positionLBL: UILabel!
    @IBOutlet weak var driverLBL: UILabel!
    @IBOutlet weak var driverIMG: UIImageView!
    @IBOutlet weak var tyreIMG: UIImageView!
    @IBOutlet weak var tyreLBL: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cardContainer.layer.cornerRadius = 10
        //cardContainer.layer.shadowColor = UIColor.black.cgColor
        //cardContainer.layer.shadowOpacity = 0.5
        //cardContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
        //cardContainer.layer.shadowRadius = 3 // Adjust the shadow spread as needed

        // Optionally, you can add a border to the view
        //cardContainer.layer.borderWidth = 0.7
        //cardContainer.layer.borderColor = UIColor.darkGray.cgColor
        
        //Set up GIF Loader
        let loadingGIF = UIImage.gifImageWithName("LoadingTransparent")
        driverIMG.image = loadingGIF
        tyreIMG.image = loadingGIF
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
