//
//  ViewController.swift
//  iOSFinalProjectDev2
//
//  Created by Chaitanya Sanoriya on 25/03/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var mSignUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting Border around the signup button
        self.mSignUpButton.layer.borderColor = UIColor.lightGray.cgColor
        self.mSignUpButton.layer.borderWidth = CGFloat(0.5)
    }
    
    //IBAction Function when Sign In Button is Clicked
    @IBAction func signInClicked(_ sender: Any) {
        performSegue(withIdentifier: "openSignIn", sender: self)
    }
    
    //IBAction Function when Sign Up Button is Clicked
    @IBAction func signUpClicked(_ sender: Any) {
        performSegue(withIdentifier: "openSignUp", sender: self)
    }
}


//Extension of UIView to Add a shake function
extension UIView {
    
    //Shake Function to shake a UIView (Used for when TextField is empty)
    func shake() {
        
        //Creating Animation
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
        
        //Code to Vibrate the Phone with shaking the UIView
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}


//Extension of UITextField to add a "cancel" and "done" button on Decimal Pad and Number Pad
extension UITextField {
    
    //Function to add a "cancel" and "done" button on Decimal Pad and Number Pad
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    //Actions Performed when "cancel" and "done" button are clicked
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

//Extension of UIPanGestureRecogizer to simply get the direction of Pan Gesture
extension UIPanGestureRecognizer {
    
    public struct PanGestureDirection: OptionSet {
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        static let Up = PanGestureDirection(rawValue: 1 << 0)
        static let Down = PanGestureDirection(rawValue: 1 << 1)
        static let Left = PanGestureDirection(rawValue: 1 << 2)
        static let Right = PanGestureDirection(rawValue: 1 << 3)
    }
    
    private func getDirectionBy(velocity: CGFloat, greater: PanGestureDirection, lower: PanGestureDirection) -> PanGestureDirection {
        if velocity == 0 {
            return []
        }
        return velocity > 0 ? greater : lower
    }
    
    public func direction(in view: UIView) -> PanGestureDirection {
        let velocity = self.velocity(in: view)
        let yDirection = getDirectionBy(velocity: velocity.y, greater: PanGestureDirection.Down, lower: PanGestureDirection.Up)
        let xDirection = getDirectionBy(velocity: velocity.x, greater: PanGestureDirection.Right, lower: PanGestureDirection.Left)
        return xDirection.union(yDirection)
    }
}
