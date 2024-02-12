//
//  CircuitInfoViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 10/2/24.
//

import UIKit

class CircuitInfoViewController: UIViewController {

    @IBOutlet weak var photoIMG: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoIMG.transform = photoIMG.transform.rotated(by: CGFloat(Double.pi / 2)) //90 degree
        
        // Do any additional setup after loading the view.
        if let imageName = UserDefaults.standard.string(forKey: "currentCircuit") {
            FirebaseUtil.getImage(withPath: imageName) { image in
                if let image = image {
                    DispatchQueue.main.async {
                        //Set ImageName
                        self.photoIMG.image = image
                        print("Image loaded succesfully")
                    }
                } else {
                    print("Image download failed")
                }
            }
        }
    }
    

    

}
