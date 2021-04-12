//
//  CustomAnimationDismisser.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 12/04/21.
//

import UIKit

class CustomAnimationDismisser: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //custom animation code
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else { return }
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        containerView.addSubview(toView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            fromView.frame = .init(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            toView.frame = .init(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
        } completion: { _ in
            transitionContext.completeTransition(true)
        }

    }
}
