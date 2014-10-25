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
  var transform : CGAffineTransform?
  
  let GRAVITY_MAGNITUDE : CGFloat       = 3.0
  let RANDOM_MAX_NANOSECONDS :UInt32   = 400
  
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
//    collision     = UICollisionBehavior(items: items)
//    itemBehavior  = UIDynamicItemBehavior(items: items)
    gravity       = UIGravityBehavior()
    self.animator!.addBehavior(self.gravity)
   
    gravity!.magnitude = GRAVITY_MAGNITUDE
    
    collision?.translatesReferenceBoundsIntoBoundary = false

    sourceVC.view.bringSubviewToFront(selectedCell!)
    
    self.animator?.addBehavior(self.collision)
    self.animator?.addBehavior(self.itemBehavior)
    
    //Helper method from http://stackoverflow.com/users/341994/matt
    func delay(delay:Double, closure:()->()) {
      dispatch_after(
        dispatch_time(
          DISPATCH_TIME_NOW,
          Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
    }
    //End helper method
    
    var maxTime : Double = 0.0
    for item in items {
      let time = Double(arc4random_uniform(RANDOM_MAX_NANOSECONDS))/400.0
      if time > maxTime{
        maxTime = time
      }
      println(time)
      var bounds = item.bounds
      delay(time) {
        
        UIView.animateWithDuration(0.3,
          delay: 0.0,
          options: UIViewAnimationOptions.CurveEaseInOut,
          animations: { () -> Void in
            
            self.transform = CGAffineTransformMakeScale(0.7, 0.7)
            self.transform = CGAffineTransformRotate(self.transform!, 5)
            item.transform = self.transform!
            
          },
          completion: { (success) -> Void in
            item.transform = self.transform!
            self.gravity?.addItem(item)
            return ()
        })
        
      }
    }
    
    UIView.animateWithDuration(0.4,
      animations: { () -> Void in
      for label in labels{
        label.alpha = 0.0
      }
    }) { (success) -> Void in
      UIView.animateWithDuration(1.0,
        delay: maxTime + 0.5,
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