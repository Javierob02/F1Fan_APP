//
//  BottomSheetPresentationController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 9/2/24.
//
import UIKit

class BottomSheetPresentationController: UIPresentationController {

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect.zero }
        let height: CGFloat = containerView.bounds.height / 2 // Adjust the fraction as needed
        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let presentedView = presentedView else { return }
        containerView.addSubview(presentedView)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        presentedView.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let presentedView = presentedView else { return }

        let translation = gestureRecognizer.translation(in: presentedView)
        let velocity = gestureRecognizer.velocity(in: presentedView)

        switch gestureRecognizer.state {
        case .changed:
            presentedView.frame.origin.y = max(containerView!.frame.height - presentedView.frame.height + translation.y, 0)
        case .ended:
            let threshold: CGFloat = 1000 // Adjust the threshold as needed
            let shouldDismiss = velocity.y > threshold || presentedView.frame.origin.y > containerView!.frame.height / 3
            if shouldDismiss {
                presentedViewController.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    presentedView.frame.origin.y = self.containerView!.frame.height - presentedView.frame.height
                }
            }
        default:
            break
        }
    }
}
