//
//  SegueFromLeft.swift
//  iOSFinalProjectDev2
//
//  Created by Chaitanya Sanoriya on 25/03/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit

//Custom Segue Class to show the slide from Left Animation when Segue is Performed
class SegueFromLeft: UIStoryboardSegue {
    
    //Overriding perform function
    override func perform() {
        
        //Fetching destination and source
        let src = self.source
        let dst = self.destination
        
        //Showing the destination above source
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        
        //Setting the destination to the left of the display
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        
        //Animating the View
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            
            //Moving the View from left of the screen to center
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { finished in
            
            //Preseting the destination ViewController
            src.present(dst, animated: false, completion: nil)
        }
        )
    }
    
}
