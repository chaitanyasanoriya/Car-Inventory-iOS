//
//  SignInViewController.swift
//  iOSFinalProjectDev2
//
//  Created by Chaitanya Sanoriya on 25/03/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CryptoKit
import CoreData

class SignInViewController: UIViewController, UITextFieldDelegate {

    //Outlets for UI Elements
    @IBOutlet weak var mUserNameTextField: UITextField!
    @IBOutlet weak var mPasswordTextField: UITextField!
    @IBOutlet weak var mSignInButton: UIButton!
    
    //Member Variables (Always starting with small m to denote member variables of a class)
    private let mUsersEntityName: String = "Users"
    private var mContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Function Call to fix TextField Width as conflicts in Constrains where common
        setupTextFields()
        
        //Function Call to fix Sign In Button Width as conflicts in Constrains where common
        setupButton()
        
        //Setting up Core Data variables for this UIViewController
        let app_delegate = UIApplication.shared.delegate as! AppDelegate
        self.mContext = app_delegate.persistentContainer.viewContext
        
        //Function Call to put a manager object in Core Data if not already exists
        Singleton.getInstance().addManagerIfNotPresent(context: self.mContext!)
    }
    
    //Function to fix TextField Width as conflicts in Constrains where common
    private func setupTextFields()
    {
        //Setting Up TextField Width
        self.mUserNameTextField.frame.size = CGSize(width: self.view.frame.size.width-40, height: self.mUserNameTextField.frame.size.height)
        self.mPasswordTextField.frame.size = CGSize(width: self.view.frame.size.width-40, height: self.mUserNameTextField.frame.size.height)
        
        //Function Call to add a minimalist design lower line to the TextField
        addSubLayer(textfield: self.mUserNameTextField)
        addSubLayer(textfield: self.mPasswordTextField)
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
        self.mSignInButton.frame.size = CGSize(width: self.view.frame.size.width-40, height: 50)
    }
    
    //IBAction Function to go back to Starting UIViewController as Navigation Controller is not used
    @IBAction func backClicked(_ sender: Any) {
        performSegue(withIdentifier: "signInBack", sender: self)
    }
    
    //IBAction Function performed when SignInButton is clicked
    @IBAction func mSignInClicked(_ sender: Any) {
        
        //Local variable to check if any of the TextField is empty
        var is_no_problem = true
        
        //If conditions to check if TextFields are empty
        //Static Function called from Utilities class named "checkText" which return true if TextField is empty and shakes the TextField
        if Utilities.checkText(textfield: self.mUserNameTextField)
        {
            is_no_problem = false
        }
        if Utilities.checkText(textfield: self.mPasswordTextField)
        {
            is_no_problem = false
        }
        
        //If Condition to check if there is no problem
        if is_no_problem
        {
            //Getting texts from TextFields
            let username = self.mUserNameTextField.text!
            var password = self.mPasswordTextField.text!
            
            //Creating SHA-256 Hash of the password
            let password_data = Data(password.utf8)
            let hash = SHA256.hash(data: password_data)
            password = hash.compactMap { String(format: "%02x", $0)}.joined()
            
            //Function Call of login function with username and password hash
            login(username: username, password: password)
        }
    }
    
    //A function with UITextFieldDelegate to perform actions when return is pressed on keyboard and also to tell keyboard that is return button is clickable
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //To hide the keyboard
        textField.resignFirstResponder()
        
        //Returning true to let the return button be clickable
        return true
    }
    
    //Function to perform login function
    private func login(username: String, password: String)
    {
        //Function call to check if the username and password hash pair is present in the Database, returns (if the pair is present, if the user is a manager)
        let (is_true, is_manager) = Singleton.getInstance().checkDetails(username: username, password: password, context: self.mContext!)
        
        //If else condition on is_true
        if is_true
        {
            //If the pair exists in Database
            //Settings the value of is_manager in Utilities, using a static function of Utilities Class
            Utilities.setManager(ismanager: is_manager)
            
            //Moving to MainViewController
            performSegue(withIdentifier: "showMainFromSignIn", sender: self)
        }
        else
        {
            //If the pair does not exist in Database
            //Function call to represnt error
            showInvalidCredentialsError()
        }
    }
    
    //Function for Invalid Credentials Error
    func showInvalidCredentialsError()
    {
        //Static Function call of Utilities Call, named "showErrorDialog" with title, message and viewcontroller instance to show a alert
        Utilities.showErrorDialog(title: "Invalid Credentials", message: "There is a problem with Username or Password", viewcontroller: self)
        
        //Function Call to shake the TextFields
        self.mUserNameTextField.shake()
        self.mPasswordTextField.shake()
    }
}

