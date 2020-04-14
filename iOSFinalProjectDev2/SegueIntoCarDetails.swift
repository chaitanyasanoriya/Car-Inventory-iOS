//
//  SegueIntoCarDetails.swift
//  iOSFinalProjectDev2
//
//  Created by Chaitanya Sanoriya on 27/03/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit

//Custom Segue Class to Zoom in and Translate Animation when Segue is Performed
class SegueIntoCarDetails: UIStoryboardSegue {
    
    //Overriding perform function
    override func perform() {
        
        //Fetching destination and source as their particular View Controller
        let src = self.source as! MainViewController
        let dst = self.destination as! CarDetailsViewController
        
        //Showing the destination above source
        src.view.superview?.insertSubview(dst.view, at: 0)
        
        //Animating the View
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            
            //Animating the CardView to Slide up
            src.mCell?.animateTransitionIfNeeded(state: .expanded, duration: 2)
            
            //Creating a translate animation
            let translate = CGAffineTransform(translationX: 0, y: -src.mCollectionView.frame.origin.y)
            
            //Creating a Zoom in animation
            let scale = CGAffineTransform(scaleX: 1.2, y: 1.2)
            
            //Adding both the animations to Source View Controller
            src.view.transform = scale.concatenating(translate)
            
            //Also adding fade out animation to Source View Controller
            src.view.alpha = 0.1
        }) { (finished) in
            
            //Preseting the destination ViewController
            src.present(dst, animated: false, completion: nil)
        }
    }
}

//Custom Segue Class to Zoom in and Translate Animation when Segue is Performed
class SegueOutOfCarDetails: UIStoryboardSegue {

    //Overriding perform function
    override func perform() {
        
        //Fetching destination and source as their particular View Controller
        let src = self.source as! CarDetailsViewController
        let dst = self.destination as! MainViewController
        
        //Showing the destination above source
        src.view.superview?.insertSubview(dst.view, at: 0)
        
        //Animating the View
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            
            //Creating a translate animation to the original height of the Cell
            let translate = CGAffineTransform(translationX: 0, y: src.mTransitionBackY)
            
            //Creating a Zoom out animation
            let scale = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            //Adding both the animations to Source View Controller
            src.view.transform = scale.concatenating(translate)
            
            //Also adding fade out animation to Source View Controller
            src.view.alpha = 0.1
        }) { (finished) in
            
            //Preseting the destination ViewController
            src.present(dst, animated: false, completion: nil)
        }
    }
}
