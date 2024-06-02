//
//  InformationViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 24/1/24.
//

import UIKit

class InformationViewController: UIViewController {
    
    @IBOutlet weak var driversBTN: UIButton!
    @IBOutlet weak var teamsBTN: UIButton!
    @IBOutlet weak var tracksBTN: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide the tab bar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = false
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
