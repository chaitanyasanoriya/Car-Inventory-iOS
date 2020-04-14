//
//  Utilities.swift
//  iOSFinalProjectDev2
//
//  Created by Chaitanya Sanoriya on 25/03/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import Foundation
import UIKit

class Utilities
{
    //Member Variables (Always starting with small m to denote member variables of a class)
    static private var mManager: Bool = false
    
    //Enum Errors Declaration
    enum Errors: Error
    {
        case VinAlreadyUsed
        case InvalidCarVin
        case InvalidCarIndex
    }
    
    //Getting Function for Member Function mManager
    static func isManager() -> Bool
    {
        return Utilities.mManager
    }
    
    //Setter Function for Member Function mManager
    static func setManager(ismanager: Bool)
    {
        Utilities.mManager = ismanager
    }
    
    //Function to check the text of a UITextField
    static func checkText(textfield: UITextField) -> Bool
    {
        if textfield.text == ""
        {
            textfield.shake()
            return true
        }
        return false
    }
    
    //Function to show an alert box with passed Title and Message
    static func showErrorDialog(title: String, message: String, viewcontroller: UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
        viewcontroller.present(alert, animated: true)
    }
    
}
