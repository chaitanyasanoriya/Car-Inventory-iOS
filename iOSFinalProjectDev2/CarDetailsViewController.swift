//
//  CarDetailsViewController.swift
//  iOSFinalProjectDev2
//
//  Created by Chaitanya Sanoriya on 27/03/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData

class CarDetailsViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //Outlets for UI Elements
    @IBOutlet weak var mBlurView: UIVisualEffectView!
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mNameTextField: UITextField!
    @IBOutlet weak var mModelTextField: UITextField!
    @IBOutlet weak var mColorTextField: UITextField!
    @IBOutlet weak var mVinTextField: UITextField!
    @IBOutlet weak var mYearTextField: UITextField!
        {
        didSet
        {
            //When mYearTextField is set
            //Function Call to add "done" and "cancel" button to the keyboard when these textfields are being edited. As it uses Numbar Pad
            mYearTextField?.addDoneCancelToolbar()
        }
    }
    @IBOutlet weak var mPriceTextField: UITextField!
        {
        didSet
        {
            //When mPriceTextField is set
            //Function Call to add "done" and "cancel" button to the keyboard when these textfields are being edited. As it uses Numbar Pad
            mPriceTextField?.addDoneCancelToolbar()
        }
    }
    @IBOutlet weak var mDeleteButton: UIButton!
    @IBOutlet weak var mScrollView: UIScrollView!
    @IBOutlet weak var mWholeView: UIView!
    @IBOutlet weak var mBlurViewHandleArea: UIVisualEffectView!
    @IBOutlet weak var mBlurViewCamera: UIVisualEffectView!
    @IBOutlet weak var mCameraButton: UIButton!
    @IBOutlet weak var mDoneButton: UIButton!
    
    //Member Variables (Always starting with small m to denote member variables of a class)
    var mImage: UIImage?
    private var mDy: CGFloat = 0
    private var mIsKeyboardNotVisible: Bool = true
    private var mKeyboardHeight: CGFloat = 0
    let mCardHeight: CGFloat = 575
    let mCardHandleAreaHeight: CGFloat = 25
    private var mOriginalY: CGFloat = 0
    var mTransitionBackY: CGFloat!
    private var mContext: NSManagedObjectContext!
    var mVisualEffectView: UIVisualEffectView! //To blur the ImageView
    var mCardVisible = false
    var mRunningAnimations = [UIViewPropertyAnimator]()
    var mAnimationProgressInterrupted: CGFloat = 0
    var mVin: String?
    private var mCar: Car?
    var mNextState: CardState
    {
        return mCardVisible ? .collapsed : .expanded
    }
    
    //Enum declaration for possible card states
    enum CardState
    {
        case expanded
        case collapsed
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Function Call to Setup Blur Views
        setupBlurViews()
        
        //If condition to check Member Variable mImage
        if mImage != nil
        {
            //If Member Variable mImage is not nil
            //Set Member Variable mImage to Image View
            self.mImageView.image = self.mImage
        }
        
        //If condition to check if user is a manager
        if !Utilities.isManager()
        {
            //If User is not a manager, remove Camera Button and Blur Effect below it
            self.mBlurViewCamera.removeFromSuperview()
            self.mCameraButton.removeFromSuperview()
        }
        
        //Setting up Core Data variables for this UIViewController
        let app_delegate = UIApplication.shared.delegate as! AppDelegate
        self.mContext = app_delegate.persistentContainer.viewContext
        
        //Function Call to fix TextField Width as conflicts in Constrains where common
        fixTextFields()
        
        //Function Call to set all the car details
        setData()
        
        //Defining Observers to call functions when keyboard will appear, will change into some other keyboard or will hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Creating a UIVisualEffectView to blur the ImageView when Card View is expanded
        self.mVisualEffectView = UIVisualEffectView()
        
        //Settings frame same as this View controller in order to blur everything
        self.mVisualEffectView.frame = self.view.frame
        
        //Adding UI Visual Effect View as a subView
        self.view.addSubview(self.mVisualEffectView)
        
        //bringing the interacting views to the front
        self.view.bringSubviewToFront(self.mWholeView)
        self.view.bringSubviewToFront(self.mCameraButton)
        self.view.bringSubviewToFront(self.mDoneButton)
        
        //Creating a tap gesture recognizer
        let tap_gesture_recognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(recognizer:)))
        //Creating a pan gesture recognizer
        let pan_gesture_recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
        //Creating a pan gesture recognizer
        let pan_gesture_recognizer_for_back = UIPanGestureRecognizer(target: self, action: #selector(handleImagePan(recognizer:)))
        
        //Adding both gesture recognizer to the Handle Area of the Card
        self.mBlurViewHandleArea.addGestureRecognizer(tap_gesture_recognizer)
        self.mBlurViewHandleArea.addGestureRecognizer(pan_gesture_recognizer)
        
        //Adding the pan_gesture_recognizer_for_back to the mVisualEffectView
        self.mVisualEffectView.addGestureRecognizer(pan_gesture_recognizer_for_back)
    }
    
    private func setupBlurViews()
    {
        //Rounding the Edges of Blur View Below the Done Button
        self.mBlurView.layer.cornerRadius = 10.0
        self.mBlurView.layer.borderColor = UIColor.clear.cgColor
        self.mBlurView.layer.masksToBounds = true
        
        //Rounding the Edges of Blur View Below the Camera Button
        self.mBlurViewCamera.layer.cornerRadius = 10.0
        self.mBlurViewCamera.layer.borderColor = UIColor.clear.cgColor
        self.mBlurViewCamera.layer.masksToBounds = true
        
        //Setting the mWholeView masksToBounds to true so that it does not extend this UI View Controller
        self.mWholeView.layer.masksToBounds = true
    }
    
    //IBAction Function for Done Button
    @IBAction func donePressed(_ sender: Any) {
        
        //If condition to check if the user is a manager
        if Utilities.isManager()
        {
            //If the user is a manager
            //Creating local variables
            var count = 0
            var no_problem: Bool = true
            
            //If conditions to check if textfields are not empty
            if Utilities.checkText(textfield: self.mNameTextField)
            {
                no_problem = false
                count += 1
            }
            if Utilities.checkText(textfield: self.mModelTextField)
            {
                no_problem = false
                count += 1
            }
            if Utilities.checkText(textfield: self.mColorTextField)
            {
                no_problem = false
                count += 1
            }
            if Utilities.checkText(textfield: self.mColorTextField)
            {
                no_problem = false
                count += 1
            }
            if Utilities.checkText(textfield: self.mVinTextField)
            {
                no_problem = false
                count += 1
            }
            if Utilities.checkText(textfield: self.mYearTextField)
            {
                no_problem = false
                count += 1
            }
            if Utilities.checkText(textfield: self.mPriceTextField)
            {
                no_problem = false
                count += 1
            }
            
            //If condition to check if there is no problem
            if no_problem
            {
                //If there is no problem with the TextFields
                //Getting the text from TextFields
                let name = self.mNameTextField.text!
                let model = self.mModelTextField.text!
                let color = self.mColorTextField.text!
                let vin = self.mVinTextField.text!
                let year = self.mYearTextField.text!
                let price = self.mPriceTextField.text!
                
                //Creating a local variable
                var car: Car
                
                //If condition to check the image in ImageView
                if let image = self.mImageView.image
                {
                    //If there is an image in ImageView
                    //Create an instance of Car class with image
                    car = Car(name: name, model: model, year: Int(year)!, price: Float(price)!, color: color, vin: vin, image: image)
                }
                else
                {
                    //If there is no image in Image View
                    //Create an instance of Car class without image
                    car = Car(name: name, model: model, year: Int(year)!, price: Float(price)!, color: color, vin: vin, image: nil)
                }
                
                //If condition to check Member Variable mCar
                if self.mCar == nil
                {
                    //If Member Variable mCar is nil, meaning that the manager is adding a new car
                    do
                    {
                        //Function call to add a new car
                        try Singleton.getInstance().addCar(new_car: car, context: self.mContext)
                        
                        //Function call to go to Main View Controller, if the above code does not throw an error
                        goBackToMainViewController()
                    }
                    catch
                    {
                        //Static Function call of Utilities Call, named "showErrorDialog" with title, message and viewcontroller instance to show a alert
                        Utilities.showErrorDialog(title: "Vin already in use", message: "Another Car already exists with this Vin number", viewcontroller: self)
                    }
                }
                else if checkCarDetails(name: name, model: model, color: color, vin: vin, year: Int(year)!, price: Float(price)!)
                {
                    //If Car details have been Edited
                    do
                    {
                        //Function call to modify car with the passed vin
                        try Singleton.getInstance().modifyCar(withVin: vin, modified_car: car, context: self.mContext)
                        
                        //Function call to go to Main View Controller, if the above code does not throw an error
                        goBackToMainViewController()
                    }
                    catch
                    {
                        //Static Function call of Utilities Call, named "showErrorDialog" with title, message and viewcontroller instance to show a alert
                        Utilities.showErrorDialog(title: "Invalid Vin", message: "No car exists with \(vin) Vin", viewcontroller: self)
                    }
                }
                else
                {
                    //If the Member Variable mCar is not nil and Car details have not been Edited
                    //Function call to go to Main View Controller
                    goBackToMainViewController()
                }
            }
            else if count == 7
            {
                //If all the TextFields are empty
                //Function call to go to Main View Controller
                goBackToMainViewController()
            }
        }
        else
        {
            //If the user is not a manager
            //Function call to go to Main View Controller
            goBackToMainViewController()
        }
    }
    
    //Function to check if the car details have been edited
    private func checkCarDetails(name: String, model: String, color: String, vin: String, year: Int, price: Float) -> Bool
    {
        if name == self.mCar?.getName() && model == self.mCar?.getModel() && color == self.mCar?.getColor() && vin == self.mCar?.getVin() && year == self.mCar?.getYear() && price == self.mCar?.getPrice()
        {
            return false
        }
        return true
    }
    
    //Function to set data into UI Elements
    private func setData()
    {
        //If condition to check VIN
        if self.mVin != nil && self.mVin != ""
        {
            //If VIN is not empyty
            do
            {
                //Function call to get the car details
                try self.mCar = Singleton.getInstance().getCar(withvin: self.mVin!)
            }
            catch
            {
                print(error)
            }
        }
        
        //If condition to check Memeber Variable mCar
        if self.mCar != nil
        {
            //If Memeber Variable mCar is not nil
            //Setting Data into UI Elements
            self.mNameTextField.text = self.mCar?.getName()
            self.mModelTextField.text = self.mCar?.getModel()
            self.mColorTextField.text = self.mCar?.getColor()
            self.mVinTextField.text = self.mCar?.getVin()
            self.mYearTextField.text = String(self.mCar?.getYear() ?? 0)
            self.mPriceTextField.text = String(self.mCar?.getPrice() ?? 0)
            self.mVinTextField.isEnabled = false
        }
        
        //If condition to check if the user is Manager
        if !Utilities.isManager()
        {
            //If the user is not a manager
            //Setting the TextFields to be un-editable
            self.mNameTextField.isEnabled = false
            self.mModelTextField.isEnabled = false
            self.mColorTextField.isEnabled = false
            self.mVinTextField.isEnabled = false
            self.mYearTextField.isEnabled = false
            self.mPriceTextField.isEnabled = false
            
            //Removing the Delete button
            self.mDeleteButton.removeFromSuperview()
        }
        
        //Function Call to add a minimalist design lower line to the TextField
        addSubLayer(textfield: self.mNameTextField)
        addSubLayer(textfield: self.mModelTextField)
        addSubLayer(textfield: self.mColorTextField)
        addSubLayer(textfield: self.mVinTextField)
        addSubLayer(textfield: self.mYearTextField)
        addSubLayer(textfield: self.mPriceTextField)
    }
    
    //Function to add a minimalist design lower line to the TextField
    private func addSubLayer(textfield: UITextField)
    {
        //Creating a Layer
        let bottom_line = CALayer()
        
        //Setting the line's frame to be at one (0,height of TextField - 1) with the width of TextField and height as 1
        bottom_line.frame = CGRect(x: 0, y: textfield.frame.size.height-1, width: textfield.frame.size.width, height: 1)
        
        //Setting the color of layer as light gray
        bottom_line.backgroundColor = UIColor.lightGray.cgColor
        
        //Adding the created layer as a sublayer
        textfield.layer.addSublayer(bottom_line)
    }
    
    //A function with UITextFieldDelegate to perform actions when return is pressed on keyboard and also to tell keyboard that is return button is clickable
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //To hide the keyboard
        textField.resignFirstResponder()
        
        //Returning true to let the return button be clickable
        return true
    }
    
    //Function to fix TextField Width as conflicts in Constrains where common
    private func fixTextFields()
    {
        //Setting Up TextField Width
        self.mNameTextField.frame.size = CGSize(width: self.view.frame.size.width-20, height: self.mNameTextField.frame.size.height)
        self.mModelTextField.frame.size = CGSize(width: self.view.frame.size.width-20, height: self.mModelTextField.frame.size.height)
        self.mColorTextField.frame.size = CGSize(width: self.view.frame.size.width-20, height: self.mColorTextField.frame.size.height)
        self.mVinTextField.frame.size = CGSize(width: self.view.frame.size.width-20, height: self.mVinTextField.frame.size.height)
        self.mPriceTextField.frame.size = CGSize(width: self.mYearTextField.frame.size.width-40, height: self.mPriceTextField.frame.size.height)
        self.mDeleteButton.frame.size = CGSize(width: self.view.frame.size.width-60, height: self.mDeleteButton.frame.size.height)
    }
    
    //Function to handle when Keyboard will appear. Adding the annotation "@objc" letting the compiler know that this function is objective-C compatible
    @objc func keyboardWillShow(notification: NSNotification) {
        
        //Disabling the user interaction to Handle Area of the Car Details Card, so that the user can not collapse it when it is being edited
        self.mBlurViewHandleArea.isUserInteractionEnabled = false
        
        //Getting the height of the keyboard
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            if self.mIsKeyboardNotVisible
            {
                //When the keyboard is going to show
                //Moving the View above when keyboard is shown
                if self.mNextState == .expanded
                {
                    animateTransitionIfNeeded(state: self.mNextState, duration: 0.2)
                }
                self.mDy = self.mWholeView.frame.origin.y
                self.mWholeView.frame.origin.y -= (keyboardHeight-50)
                self.mIsKeyboardNotVisible = false
                self.mKeyboardHeight = keyboardHeight
            }
            else if keyboardHeight != self.mKeyboardHeight
            {
                //When the keyboard will change into different kind of keyboard
                //Moving the View above when keyboard is shown
                self.mWholeView.frame.origin.y = self.mDy - (keyboardHeight-50)
                self.mKeyboardHeight = keyboardHeight
            }
        }
    }
    
    //Function to handle when Keyboard will hide. Adding the annotation "@objc" letting the compiler know that this function is objective-C compatible
    @objc func keyboardWillHide(notification: NSNotification) {
        
        //Enabling the user interaction to Handle Area of the Car Details Card
        self.mBlurViewHandleArea.isUserInteractionEnabled = true
        
        //Moving the view to original location
        self.mWholeView.frame.origin.y = self.mDy
        self.mIsKeyboardNotVisible = true
    }
    
    //De-Contructor to Remove Observers on the keyboard
    deinit {
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    //Function to handle the the pan gesture on the ImageView or UIVisualEffectView. Adding the annotation "@objc" letting the compiler know that this function is objective-C compatible
    @objc
    func handleImagePan(recognizer: UIPanGestureRecognizer)
    {
        //Getting the direction of the pan
        let direction = recognizer.direction(in: self.mImageView)
        if direction == .Down
        {
            //If the direction is down
            //Function call to go back to Main View Controller
            goBackToMainViewController()
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
            let translation = recognizer.translation(in: self.mBlurViewHandleArea)
            
            //Calculating fractional complete
            var fraction_complete = translation.y / ( self.mCardHeight - (self.mCardHeight - self.mWholeView.frame.origin.y))
            
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
                    //Setting the the Y co-ordinate of the Card View Such that it expands fully and is bounded to the bottom of the UI Collection View Cell
                    self.mOriginalY = self.mWholeView.frame.origin.y
                    self.mWholeView.frame.origin.y = self.view.frame.height  - self.mWholeView.frame.height
                case .collapsed:
                    
                    //If the Card is Collapsing
                    //Setting the the Y co-ordinate of the Card View Such that it is collapsed and is bounded to the bottom of the UI Collection View Cell
                    self.mWholeView.frame.origin.y = self.mOriginalY
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
            
            
            //Creating a translation animation
            let corner_radius_animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state
                {
                case .expanded:
                    
                    //If the Card View is Expanding
                    //Setting the Corner Radius of the Car Details Card
                    self.mWholeView.layer.cornerRadius = 15
                case .collapsed:
                    
                    //If the Card View is Collapsing
                    //Setting the Corner Radius of the Car Details Card
                    self.mWholeView.layer.cornerRadius = 0
                }
            }
            
            //Starting the Cornering Animation
            corner_radius_animator.startAnimation()
            
            //Adding Cornering Animation into Member Variable mRunningAnimations
            self.mRunningAnimations.append(corner_radius_animator)
            
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
    
    
    //IBAction Function for Camera Button
    @IBAction func cameraButtonClicked(_ sender: Any) {
        
        //Creating a UIImagePickerController
        let image = UIImagePickerController()
        
        //Setting that the Delegate of UIImagePickerController is this class
        image.delegate = self
        
        //Setting that the selected image is not editable
        image.allowsEditing = false
        
        //Creating a UIAlertController to ask user if they would like to take image from Camera, Photo Library or Cancel it
        let action_sheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: UIAlertController.Style.actionSheet)
        action_sheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            
            //Setting that the source of the image is Camera
            image.sourceType = UIImagePickerController.SourceType.camera
            
            //Showing the Camera Application to click the image
            self.present(image, animated: true, completion: nil)
        }))
        action_sheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            
            //Setting that the source of the image is Photo Library
            image.sourceType = UIImagePickerController.SourceType.photoLibrary
            
            //Showing the Photo Library to click the image
            self.present(image, animated: true, completion: nil)
        }))
        action_sheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        //Showing the UIAlertController
        self.present(action_sheet, animated: true, completion: nil)
    }
    
    //Function with UIImagePickerControllerDelegate, to get the selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //If condition to check the image
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            //If the image returned is actual a UIImage
            //Setting the selected image onto the Image View
            mImageView.image = image
        }
        else
        {
            //If the image returned is not actual a UIImage
            //Static Function call of Utilities Call, named "showErrorDialog" with title, message and viewcontroller instance to show a alert
            Utilities.showErrorDialog(title: "Error Occured!", message: "There was problem with fetching your image", viewcontroller: self)
        }
        
        //Hiding the UIAlertController
        self.dismiss(animated: true, completion: nil)
    }
    
    //Function with UIImagePickerControllerDelegate, to handle when It has been cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        //Hiding the UIAlertController
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //Function to go back to Main View Controller
    func goBackToMainViewController()
    {
        performSegue(withIdentifier: "backFromDetails", sender: self)
    }
    
    //IBAction Function for delete Button
    @IBAction func deleteButtonClicked(_ sender: Any) {
        
        //If condition to check if the user is the is a manager
        if Utilities.isManager()
        {
            //If the user is a manager
            //If condition to check if Member Variable mCar
            if self.mCar == nil
            {
                //If the Member Variable mCar is nil, meaning that the user was adding a new Car
                //Function call to go back to Main View Controller
                goBackToMainViewController()
            }
            else
            {
                //If the Member Variable mCar is not nil, meaning that the user was modifying a Car
                do
                {
                    //Function call to remove car with the passed vin
                    try Singleton.getInstance().removeCar(withVin: self.mVinTextField.text!, context: self.mContext)
                    
                    //Function call to go to Main View Controller, if the above code does not throw an error
                    goBackToMainViewController()
                }
                catch
                {
                    //Static Function call of Utilities Call, named "showErrorDialog" with title, message and viewcontroller instance to show a alert
                    Utilities.showErrorDialog(title: "Inavlid Vin", message: "No Car Exists with this Vin Number", viewcontroller: self)
                }
            }
        }
    }
}
