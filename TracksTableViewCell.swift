//
//  TracksTableViewCell.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 26/1/24.
//

import UIKit

class TracksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardContainer: UIView!
    
    @IBOutlet weak var trackLBL: UILabel!
    @IBOutlet weak var flagIMG: UIImageView!
    @IBOutlet weak var trackIMG: UIImageView!
    
    @IBOutlet weak var dateLBL: UILabel!
    @IBOutlet weak var lengthLBL: UILabel!
    @IBOutlet weak var countryLBL: UILabel!
    @IBOutlet weak var turnsLBL: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardContainer.layer.cornerRadius = 10
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.5
        cardContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
        cardContainer.layer.shadowRadius = 3 // Adjust the shadow spread as needed

        // Optionally, you can add a border to the view
        cardContainer.layer.borderWidth = 0.7
        cardContainer.layer.borderColor = UIColor.darkGray.cgColor
        
        //Set up GIF Loader
        let loadingGIF = UIImage.gifImageWithName("LoadingTransparent")
        trackIMG.image = loadingGIF
        flagIMG.image = loadingGIF
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
