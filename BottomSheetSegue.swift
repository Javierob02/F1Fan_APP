//
//  BottomSheetSegue.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 9/2/24.
//

import UIKit
import Foundation

class BottomSheetSegue: UIStoryboardSegue {

    override func perform() {
        let sourceViewController = source
        let destinationViewController = destination

        // Configure the destination view controller as a bottom sheet
        destinationViewController.modalPresentationStyle = .custom
        destinationViewController.transitioningDelegate = self

        // Perform the segue
        sourceViewController.present(destinationViewController, animated: true, completion: nil)
    }
}

extension BottomSheetSegue: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
