//
//  SignUpViewController.swift
//  iOSFinalProjectDev2
//
//  Created by Chaitanya Sanoriya on 25/03/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CryptoKit
import CoreData

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    //Outlets for UI Elements
    @IBOutlet weak var mFullNameTextField: UITextField!
    @IBOutlet weak var mUserNameTextField: UITextField!
    @IBOutlet weak var mPasswordTextField: UITextField!
    @IBOutlet weak var mRePasswordTextField: UITextField!
    @IBOutlet weak var mSignUpButton: UIButton!
    @IBOutlet weak var mScrollView: UIScrollView!
    
    //Member Variables (Always starting with small m to denote member variables of a class)
    private var mContext: NSManagedObjectContext?
    private let mUsersEntityName: String = "Users"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Function Call to fix TextField Width as conflicts in Constrains where common
        setupTextFields()
        
        //Function Call to fix Sign In Button Width as conflicts in Constrains where common
        setupButton()
        
        //Setting up Core Data variables for this UIViewController
        let app_delegate = UIApplication.shared.delegate as! AppDelegate
        self.mContext = app_delegate.persistentContainer.viewContext
    }
    
    //IBAction Function to go back to Starting UIViewController as Navigation Controller is not used
    @IBAction func backClicked(_ sender: Any) {
        performSegue(withIdentifier: "signUpBack", sender: self)
    }
    
    //Function to fix TextField Width as conflicts in Constrains where common
    private func setupTextFields()
    {
        //Setting Up TextField Width
        self.mFullNameTextField.frame.size = CGSize(width: self.view.frame.size.width-60, height: self.mUserNameTextField.frame.size.height)
        self.mUserNameTextField.frame.size = CGSize(width: self.view.frame.size.width-60, height: self.mUserNameTextField.frame.size.height)
        self.mPasswordTextField.frame.size = CGSize(width: self.view.frame.size.width-60, height: self.mUserNameTextField.frame.size.height)
        self.mRePasswordTextField.frame.size = CGSize(width: self.view.frame.size.width-60, height: self.mUserNameTextField.frame.size.height)
        
        //Function Call to add a minimalist design lower line to the TextField
        addSubLayer(textfield: self.mFullNameTextField)
        addSubLayer(textfield: self.mUserNameTextField)
        addSubLayer(textfield: self.mPasswordTextField)
        addSubLayer(textfield: self.mRePasswordTextField)
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
    
    //Function to fix Sign In button Width as conflicts in Constrains where common
    private func setupButton()
    {
        self.mSignUpButton.frame.size = CGSize(width: self.view.frame.size.width-60, height: 50)
    }
    
    //IBAction Function performed when Sign Up Button is clicked
    @IBAction func signUpButtonClicked(_ sender: Any) {
        
        //Local variable to check if any of the TextField is empty
        var is_no_problem = true
        //If conditions to check if TextFields are empty
        //Static Function called from Utilities class named "checkText" which return true if TextField is empty and shakes the TextField
        if Utilities.checkText(textfield: self.mFullNameTextField)
        {
            is_no_problem = false
        }
        if Utilities.checkText(textfield: self.mUserNameTextField) || self.mUserNameTextField.text?.contains(" ") ?? true
        {
            is_no_problem = false
            self.mUserNameTextField.shake()
        }
        if Utilities.checkText(textfield: self.mPasswordTextField)
        {
            is_no_problem = false
        }
        if Utilities.checkText(textfield: self.mRePasswordTextField)
        {
            is_no_problem = false
        }
        
        //If Condition to check if there is no problem
        if is_no_problem
        {
            //If Condition to check if password in both Password TextField and Re-type Password TextField as same
            if self.mPasswordTextField.text == self.mRePasswordTextField.text
            {
                //If the passwords are same
                //Getting the username from the TextField
                let username = self.mUserNameTextField.text!
                
                //If condition to check if the Username is already being used
                if Singleton.getInstance().checkUserName(username: username, context: self.mContext!)
                {
                    //If the username is not in use
                    //fetching of all the data
                    let name = self.mFullNameTextField.text!
                    var password = self.mPasswordTextField.text!
                    
                    //Converting the password into SHA-256 hash
                    let password_data = Data(password.utf8)
                    let hash = SHA256.hash(data: password_data)
                    password = hash.compactMap { String(format: "%02x", $0)}.joined()
                    
                    //signUp function call with name, username and password to register user
                    signUp(name: name, username: username, password: password)
                }
                else
                {
                    //If the username already in use
                    //Static Function call of Utilities Call, named "showErrorDialog" with title, message and viewcontroller instance to show a alert
                    Utilities.showErrorDialog(title: "Username Already Exists", message: "\(self.mUserNameTextField.text!) already exists please use any other username" , viewcontroller: self)
                }
            }
            else
            {
                //If Password in Password TextField and Re-type Password TextField are different
                //Shaking the TextFields
                self.mRePasswordTextField.shake()
                self.mPasswordTextField.shake()
                
                //Static Function call of Utilities Call, named "showErrorDialog" with title, message and viewcontroller instance to show a alert
                Utilities.showErrorDialog(title: "Passwords do not Match!", message: "", viewcontroller: self)
            }
        }
    }
    
    //Function with UITextFieldDelegate (called when TextField has begun Editing)
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //Scrolling the ScrollView up to get make all the TextFields visible while being edited
        self.mScrollView.setContentOffset(CGPoint(x: mScrollView.contentOffset.x, y: textField.frame.height +  textField.frame.minY/2 ), animated: true)
    }
    
    //A function with UITextFieldDelegate to perform actions when return is pressed on keyboard and also to tell keyboard that is return button is clickable
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //To hide the keyboard
        textField.resignFirstResponder()
        
        //Returning true to let the return button be clickable
        return true
    }
    
    //Function with UITextFieldDelegate (called when TextField has ended Editing)
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //Scrolling the ScrollView to the original location
        self.mScrollView.setContentOffset(CGPoint(x: 0.00, y: 0.00), animated: true)
    }
    
    //Function to perform Sign Up function
    func signUp(name: String, username: String, password: String)
    {
        //Local Variable to check if Sign Up was successful
        var did_register = false
        
        //Function Call to save the user in the database, returns if it was successful
        did_register = Singleton.getInstance().addNewUser(name: name, username: username, password: password, context: self.mContext!)
        
        //If condition for successful registration
        if did_register
        {
            //Registration was successful
            //Moving to MainView Controller
            performSegue(withIdentifier: "showMainFromSignUp", sender: self)
        }
        else
        {
            //Registration failed
            //Static Function call of Utilities Call, named "showErrorDialog" with title, message and viewcontroller instance to show a alert
            Utilities.showErrorDialog(title: "Error", message: "An error occurred while trying to register you", viewcontroller: self)
        }
    }
    
}
