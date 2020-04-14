//
//  CarCollectionViewCell.swift
//  iOSFinalProjectDev2
//
//  Created by Chaitanya Sanoriya on 25/03/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit

class CarCollectionViewCell: UICollectionViewCell{
    
    //Outlets for UI Elements
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mNameLabel1: UILabel!
    @IBOutlet weak var mPriceLabel1: UILabel!
    @IBOutlet weak var mPriceBlurView: UIVisualEffectView!
    @IBOutlet weak var mNameBlurView: UIVisualEffectView!
    
    //Member Variables (Always starting with small m to denote member variables of a class)
    var mDetails: [String]!
    {
        didSet
        {
            //This block will be called when value will be assigned to Member Variable mDetails
            //If condition to check Card View Controller
            if self.mCardViewController != nil
            {
                //If Card View Controller is not nil
                //Setting the Car details into Card View Controller
                self.mCardViewController.mDetails = self.mDetails
            }
        }
    }
    
    //Member Variables (Always starting with small m to denote member variables of a class)
    var mVin: String?
    
    
    //Enum declaration for possible card states
    enum CardState
    {
        case expanded
        case collapsed
    }
    
    //Member Variables (Always starting with small m to denote member variables of a class)
    var mCardViewController: CardViewController! //Not in Main.storyboard, Initialized in setupCard function
    var mVisualEffectView: UIVisualEffectView! //To blur the ImageView
    let mCardHeight: CGFloat = 400
    let mCardHandleAreaHeight: CGFloat = 25
    var mCardVisible = false
    var mNextState: CardState
    {
        return mCardVisible ? .collapsed : .expanded
    }
    var mRunningAnimations = [UIViewPropertyAnimator]()
    var mAnimationProgressInterrupted: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Function Call to setup Card View Controller on the UI
        setupCard()
    }
    
    func setupCard()
    {
        //Creating a UIVisualEffectView to blur the ImageView when Card View is expanded
        self.mVisualEffectView = UIVisualEffectView()
        
        //Settings frame same as this View controller in order to blur everything
        self.mVisualEffectView.frame = self.frame
        
        //Adding UI Visual Effect View as a subView
        self.addSubview(self.mVisualEffectView)
        
        //Initializing Member Variable mCardViewController
        self.mCardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
        
        //Setting car details in Card View Controller
        self.mCardViewController.mDetails = self.mDetails
        
        //Adding Card View Controller as a Sub-View. Since it is being added later than Visual Effect View, so it will be on top of it.
        self.addSubview(self.mCardViewController.view)
        
        //Setting the frame of CardView Controller such that its handle area will be visible only
        self.mCardViewController.view.frame = CGRect(x: 0, y: self.frame.height - self.mCardHandleAreaHeight, width: self.frame.width, height: self.mCardHandleAreaHeight)
        
        //Setting the clips to bound true, so that the Card View does not exceed the bounds of this UI Collection View Cell
        self.mCardViewController.view.clipsToBounds = true
        
        //Making the Corner of Card View Controller round same as this UI Collection View Cell
        self.mCardViewController.view.layer.cornerRadius = 15.0
        self.mCardViewController.view.layer.borderWidth = 5.0
        self.mCardViewController.view.layer.borderColor = UIColor.clear.cgColor
        self.mCardViewController.view.layer.masksToBounds = true
        
        //Creating a tap gesture recognizer
        let tap_gesture_recognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(recognizer:)))
        
        //Creating a pan gesture recognizer
        let pan_gesture_recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
        
        //Adding both gesture recognizer to the Handle Area of the Card View Controller
        self.mCardViewController.mHandleAreaView.addGestureRecognizer(tap_gesture_recognizer)
        self.mCardViewController.mHandleAreaView.addGestureRecognizer(pan_gesture_recognizer)
        
    }
    
    //Function to handle the the tap gesture. Adding the annotation "@objc" letting the compiler know that this function is objective-C compatible
    @objc
    func handleCardTap(recognizer: UITapGestureRecognizer)
    {
        //Switch Case for recognizer state
        switch recognizer.state {
        case .ended:
            //If recognizer state is ended
            //Function Call to add the animation depending upon the nextState
            animateTransitionIfNeeded(state: self.mNextState, duration: 0.9)
        default:
            break
        }
    }
    
    //Function to handle the the pan gesture. Adding the annotation "@objc" letting the compiler know that this function is objective-C compatible
    @objc
    func handleCardPan(recognizer: UIPanGestureRecognizer)
    {
        //Switch Case for recognizer state
        switch recognizer.state
        {
        case .began:
            //If recognizer state is began
            //Function Call to add the animation depending upon the nextState
            startInteractiveTransition(state: self.mNextState, duration: 0.9)
        case .changed:
            //If recognizer state is changed
            //Get how much the gesture has translated (how much the Handle Area of Card View Controller has been dragged up)
            let translation = recognizer.translation(in: self.mCardViewController.mHandleAreaView)
            
            //Calculating fractional complete
            var fraction_complete = translation.y / self.mCardHeight
            
            //Setting the Fraction completed positive or negative depending upon if the Card View Controller is visible
            //So if the Card is visible fraction complete will be positive and the card will translate down
            //If the card is not visible fraction complete will be negative and the card will translate up
            fraction_complete = self.mCardVisible ? fraction_complete : -fraction_complete
            
            //Function Call to Update the Animation
            updateInteractiveTransition(fractionCompleted: fraction_complete)
        case .ended:
            //If recognizer state is ended
            //Function Call to continue the animation (So if you drag up the Card View half way and stop the Card View will automatically slide up)
            continueInterativeTransition()
        default:
            break
        }
    }
    
    //Function to setup all animations and run them
    func animateTransitionIfNeeded(state: CardState, duration: TimeInterval)
    {
        //If condition to check if Member Variable mRunningAnimations is empty or not
        if self.mRunningAnimations.isEmpty
        {
            //If Member Variable mRunningAnimations is empty
            //Creating a translation animation
            let frame_animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                
                //Switch case for the state of the Card View
                switch state
                {
                case .expanded:
                    
                    //If the Card View is Expanding
                    //Setting the Card View to its full height
                    self.mCardViewController.view.frame = CGRect(x: 0, y: self.frame.height - self.mCardHandleAreaHeight, width: self.frame.width, height: self.mCardHeight)
                    
                    //Setting the the Y co-ordinate of the Card View Such that it expands fully and is bounded to the bottom of the UI Collection View Cell
                    self.mCardViewController.view.frame.origin.y = self.frame.height  - self.mCardHeight
                case .collapsed:
                    
                    //If the Card is Collapsing
                    //Setting the Card View height to just its Handle Area height
                    self.mCardViewController.view.frame = CGRect(x: 0, y: self.frame.height - self.mCardHandleAreaHeight, width: self.frame.width, height: self.mCardHandleAreaHeight)
                    
                    //Setting the the Y co-ordinate of the Card View Such that it is collapsed and is bounded to the bottom of the UI Collection View Cell
                    self.mCardViewController.view.frame.origin.y = self.frame.height - self.mCardHandleAreaHeight
                }
            }
            
            //Adding function to perform when Translation Animation Completes
            frame_animator.addCompletion { _ in
                
                //Setting the opposite of what the card visibility is
                self.mCardVisible = !self.mCardVisible
                
                //Removing all the running animation
                self.mRunningAnimations.removeAll()
            }
            
            //Starting the Translation Animation
            frame_animator.startAnimation()
            
            //Adding Translation Animation into Member Variable mRunningAnimations
            self.mRunningAnimations.append(frame_animator)
            
            //Creating a blur animation
            let blur_animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                
                //Switch case for the state of the Card View
                switch state
                {
                case .expanded:
                    
                    //If the Card View is Expanding
                    //Adding the blur effect into the Visual Effect View
                    self.mVisualEffectView.effect = UIBlurEffect(style: .regular)
                case .collapsed:
                    
                    //If the Card View is Collapsing
                    //Removing the blur effect into the Visual Effect View
                    self.mVisualEffectView.effect = nil
                }
            }
            
            //Starting the Blur Animation
            blur_animator.startAnimation()
            
            //Adding Blur Animation into Member Variable mRunningAnimations
            self.mRunningAnimations.append(blur_animator)
        }
    }
    
    //Function to start the animations
    func startInteractiveTransition(state: CardState, duration: TimeInterval)
    {
        //If condition to check if Member variable mRunningAnimations is empty
        if self.mRunningAnimations.isEmpty
        {
            //If Member variable mRunningAnimations is empty
            //Functional Call to animate depending upon the card state
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        
        //Looping for all the animations in Member variable mRunningAnimations
        for animator in self.mRunningAnimations
        {
            //Pause each animation
            animator.pauseAnimation()
            
            //Setting Member variable mAnimationProgressInterrupted as animations fractionComplete
            self.mAnimationProgressInterrupted = animator.fractionComplete
        }
    }
    
    //Function to update the Animations (Used to animate the Animation according to how much it has been completed or how much the Handle Area has been dragged by the user)
    func updateInteractiveTransition(fractionCompleted: CGFloat)
    {
        //Looping through all the animations and updating their fraction complete
        for animator in self.mRunningAnimations
        {
            animator.fractionComplete = fractionCompleted + self.mAnimationProgressInterrupted
        }
    }
    
    //Function to continue the Animations (Used to animate the Animation according to how much it has been completed or how much the Handle Area has been dragged by the user)
    func continueInterativeTransition()
    {
        //Looping through all the animations and making them continue to end (When the gesture is not full for the completion of animation, it will complete itself)
        for animator in self.mRunningAnimations
        {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    //Overriding layoutSubviews function to set attributes of the SubViews
    override func layoutSubviews() {
        
        //Making the this UI Collection View Cell have rounded edges
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.cornerRadius = 15.0
        self.layer.borderWidth = 5.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
        
        //Rounding the edges of ImageView (As it covers the whole cell)
        self.mImageView.layer.backgroundColor = UIColor.white.cgColor
        self.mImageView.layer.cornerRadius = 15.0
        self.mImageView.layer.borderWidth = 5.0
        self.mImageView.layer.borderColor = UIColor.clear.cgColor
        self.mImageView.layer.masksToBounds = true
        
        //Rounding the Edges of Blur View Below the Price
        self.mPriceBlurView.layer.cornerRadius = 15.0
        self.mPriceBlurView.layer.borderWidth = 5.0
        self.mPriceBlurView.layer.borderColor = UIColor.clear.cgColor
        self.mPriceBlurView.layer.masksToBounds = true
        
        //Rounding the Edges of Blur View Below the Name
        self.mNameBlurView.layer.cornerRadius = 15.0
        self.mNameBlurView.layer.borderWidth = 5.0
        self.mNameBlurView.layer.borderColor = UIColor.clear.cgColor
        self.mNameBlurView.layer.masksToBounds = true
        
        //Rounding the edges of Blur View that blurs the ImageView when Card View is expanded
        self.mVisualEffectView.layer.cornerRadius = 15.0
        self.mVisualEffectView.layer.borderWidth = 5.0
        self.mVisualEffectView.layer.borderColor = UIColor.clear.cgColor
        self.mVisualEffectView.layer.masksToBounds = true
        
        //Adding shadow to this UI Collection View Cell
        self.contentView.layer.cornerRadius = 15.0
        self.contentView.layer.borderWidth = 5.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = 15.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
}
