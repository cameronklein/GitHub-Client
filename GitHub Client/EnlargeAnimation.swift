//
//  EnlargeAnimation.swift
//  GitHub Client
//
//  Created by Cameron Klein on 10/22/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class EnlargeAnimation : NSObject, UIViewControllerAnimatedTransitioning {
  
  var animator : UIDynamicAnimator?
  var gravity : UIGravityBehavior?
  var collision : UICollisionBehavior?
  var itemBehavior : UIDynamicItemBehavior?
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return 3.0
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let sourceVC      = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as SearchViewController
    let destVC        = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as ProfileViewController
    let containerView = transitionContext.containerView()
    
    let selectedCell = sourceVC.selectedCell
    let originalCellFrame = selectedCell!.frame
    
    containerView.addSubview(destVC.view)
    destVC.view.alpha = 0.0
    
    var collectionView = sourceVC.collectionView
    var items = [UIView]()
    var labels = [UILabel]()
    
    for cell in collectionView.visibleCells(){
      let myCell = cell as UserCollectionCell
      labels.append(myCell.nameLabel)
      if cell as UserCollectionCell != selectedCell {
        items.append(cell as UIView)
      } else {
        println("Found selected cell!")
      }
    }
    
    animator      = UIDynamicAnimator(referenceView: containerView)
    collision     = UICollisionBehavior(items: items)
    itemBehavior  = UIDynamicItemBehavior(items: items)
    gravity       = UIGravityBehavior(items: items)
   
    gravity!.magnitude = 2.0
    
    collision?.translatesReferenceBoundsIntoBoundary = false

    sourceVC.view.bringSubviewToFront(selectedCell!)
    
    UIView.animateWithDuration(0.4,
      animations: { () -> Void in
      for label in labels{
        label.alpha = 0.0
      }
    }) { (success) -> Void in
      self.animator!.addBehavior(self.gravity)
      self.animator?.addBehavior(self.collision)
      self.animator?.addBehavior(self.itemBehavior)
      
      UIView.animateWithDuration(1.0,
        delay: 0.5,
        options: UIViewAnimationOptions.CurveEaseInOut,
        animations: { () -> Void in
          selectedCell?.transform = CGAffineTransformMakeScale(10.0, 10.0)
          return ()
        },
        completion: { (success) -> Void in
          
          UIView.animateWithDuration(1.0,
            animations: { () -> Void in
              destVC.view.alpha = 1.0
          }, completion: { (success) -> Void in
            
            transitionContext.completeTransition(true)
            selectedCell!.frame = originalCellFrame
            println("Success!")
            
          })
      })
    }
    
    
    
  }
  
}