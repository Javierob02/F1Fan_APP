//
//  ChatBoxViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 9/2/24.
//

import UIKit

class ChatBoxViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {

        // Hide the tab bar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = false
        }
    }
    

}
