//
//  Car.swift
//  iOSFinalProjectDev2
//
//  Created by Chaitanya Sanoriya on 25/03/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import Foundation
import UIKit

//Model Class for Car
class Car
{
    
    //Member Variables (Always starting with small m to denote member variables of a class)
    private var mName: String
    private var mModel: String
    private var mYear: Int
    private var mPrice: Float
    private var mColor: String
    private var mVin: String
    private var mImage: UIImage?
    
    //Parameterized constructor for Car Model
    init(name: String, model: String, year: Int, price: Float, color: String, vin: String, image: UIImage?) {
        self.mName = name
        self.mModel = model
        self.mYear = year
        self.mPrice = price
        self.mColor = color
        self.mVin = vin
        self.mImage = image
    }
    
    
    //Getters
    internal func getName() -> String
    {
        return self.mName
    }
    
    internal func getModel() -> String
    {
        return self.mModel
    }
    
    internal func getYear() -> Int
    {
        return self.mYear
    }
    
    internal func getPrice() -> Float
    {
        return self.mPrice
    }
    
    internal func getColor() -> String
    {
        return self.mColor
    }
    
    internal func getVin() -> String
    {
        return self.mVin
    }
    
    internal func getImage() -> UIImage?
    {
        return self.mImage
    }
}
