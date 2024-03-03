//
//  TeamTableViewCell.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 25/1/24.
//

import UIKit

class TeamTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var teamLBL: UILabel!
    @IBOutlet weak var logoIMG: UIImageView!
    @IBOutlet weak var carIMG: UIImageView!
    
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var driver1Container: UIView!
    @IBOutlet weak var driver2Container: UIView!
    
    @IBOutlet weak var driver1NameLBL: UILabel!
    @IBOutlet weak var driver1IMG: UIImageView!
    
    @IBOutlet weak var driver2NameLBL: UILabel!
    @IBOutlet weak var driver2IMG: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardContainer.layer.cornerRadius = 10
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.5
        cardContainer.layer.shadowOffset = CGSize(width: 4, height: 4)
        cardContainer.layer.shadowRadius = 4 // Adjust the shadow spread as needed

        // Optionally, you can add a border to the view
        cardContainer.layer.borderWidth = 0.7
        cardContainer.layer.borderColor = UIColor.darkGray.cgColor
        
        //Rounded corners for drivers
        driver1Container.layer.cornerRadius = 10
        driver2Container.layer.cornerRadius = 10
        
        //Set up GIF Loader
        let loadingGIF = UIImage.gifImageWithName("LoadingTransparent")
        carIMG.image = loadingGIF
        driver1IMG.image = loadingGIF
        driver2IMG.image = loadingGIF
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
