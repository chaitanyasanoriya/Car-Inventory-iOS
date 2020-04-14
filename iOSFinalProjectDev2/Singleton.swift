//
//  Singleton.swift
//  InClassActivityTwo
//
//  Created by Chaitanya Sanoriya on 23/03/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//Singleton Class to handle Core Data Functions and Manage Cars
class Singleton
{
    //Member Variables (Always starting with small m to denote member variables of a class)
    private static var mInstance: Singleton?
    private var mCars: [Car] = []
    
    //Private Constructor, to allow only the Member functions of the class to create its instance
    private init()
    {
    }
    
    //Fuction to return the Instance of the Singleton Class
    internal static func getInstance() -> Singleton
    {
        //If condition to check Member Variable mInstance
        if Singleton.mInstance == nil
        {
            //If Member Variable mInstance is nil
            //Creating a Instance of the Singleton class
            let instance = Singleton()
            
            //Setting Member Variable mInstance to the new created instance
            Singleton.mInstance = instance
        }
        
        //Returning force unwrapped Member Variable mInstance
        return Singleton.mInstance!
    }
    
    //Function to Add a Car
    internal func addCar(new_car: Car, context: NSManagedObjectContext) throws
    {
        //Looping for all cars in Member Variable mCars
        for car in self.mCars
        {
            //If condition to check the cars VIN number against the new car VIN
            if car.getVin() == new_car.getVin()
            {
                //If any car's VIN matches with new car's VIN
                //Throwing an Error that Vin is already being used
                throw Utilities.Errors.VinAlreadyUsed
            }
        }
        
        //Creating a local variable
        var index = 0
        
        //Looping to get the index of where the car should be inserted alphabetically
        for car in self.mCars
        {
            if car.getName() > new_car.getName()
            {
                break
            }
            index += 1
        }
        
        //Inserting the car in the array at a particular index alphabetically
        self.mCars.insert(new_car, at: index)
        
        //Function call to save car in database
        saveCarInDataBase(new_car: new_car, context: context)
    }
    
    //Function to save car in database
    private func saveCarInDataBase(new_car: Car, context: NSManagedObjectContext)
    {
        //Creating a new Car entity
        let new_car_entity = NSEntityDescription.insertNewObject(forEntityName: "Car", into: context)
        
        //Setting the data into entity
        new_car_entity.setValue(new_car.getName(), forKey: "name")
        new_car_entity.setValue(new_car.getModel(), forKey: "model")
        new_car_entity.setValue(new_car.getYear(), forKey: "year")
        new_car_entity.setValue(new_car.getPrice(), forKey: "price")
        new_car_entity.setValue(new_car.getColor(), forKey: "color")
        new_car_entity.setValue(new_car.getVin(), forKey: "vin")
        new_car_entity.setValue(new_car.getImage()?.pngData(), forKey: "image")
        
        //Trying to save the entity into the database
        do
        {
            try context.save()
        }
        catch
        {
            //Prints error if there was a problem in saving the database
            print(error)
        }
    }
    
    //Function to remove a car with a particular Vin
    internal func removeCar(withVin: String, context: NSManagedObjectContext) throws
    {
        //Creating local variables
        var index = 0
        var delete = true
        
        //Looping to remove the car the from array as well as check if the car exists
        for car in self.mCars
        {
            if car.getVin() == withVin
            {
                self.mCars.remove(at: index)
                delete = false
                break
            }
            index += 1
        }
        
        //If condition to check delete (if the car was present)
        if delete
        {
            //If the car was not present
            //Throws an Error that Invalid Vin
            throw Utilities.Errors.InvalidCarVin
        }
        else
        {
            //If the Car was present
            //Function Call to remove the Car from database
            removeCarFromCoreData(vin: withVin, context: context)
        }
    }
    
    //Function to remove a car from database with a particular vin
    private func removeCarFromCoreData(vin: String, context: NSManagedObjectContext)
    {
        //Creating a Request
        let fetch_request = NSFetchRequest<NSFetchRequestResult>(entityName: "Car")
        
        //Setting the search criteria
        fetch_request.predicate = NSPredicate(format: "vin = %@", vin)
        do
        {
            //Fetching the data
            let test = try context.fetch(fetch_request)
            
            //Fetching the Car Object
            let object_to_delete = test[0] as! NSManagedObject
            
            //Deleting the object
            context.delete(object_to_delete)
            do
            {
                //Saving the Database
                try context.save()
            }
            catch
            {
                //Prints error if encountered when saving
                print(error)
            }
        }
        catch
        {
            //Prints error if encountered when fetching
            print(error)
        }
    }
    
    //Function to modify a car
    internal func modifyCar(withVin: String, modified_car: Car, context: NSManagedObjectContext) throws
    {
        //Function Call to remove the car with a particular VIn
        try self.removeCar(withVin: withVin, context: context)
        
        //Creating local variable
        var index = 0
        
        //Looping to get the index of where the car should be inserted alphabetically
        for car in self.mCars
        {
            if car.getName() > modified_car.getName()
            {
                break
            }
            index += 1
        }
        
        //Inserting the car in the array at a particular index alphabetically
        self.mCars.insert(modified_car, at: index)
        
        //Function call to save car in database
        saveCarInDataBase(new_car: modified_car, context: context)
    }
    
    //Function to return the number of cars
    internal func getNumberOfCars() -> Int
    {
        return self.mCars.count
    }
    
    //Function to return all cars
    internal func getAllCars() -> [Car]
    {
        return self.mCars
    }
    
    //Function to return car with a particular VIN
    internal func getCar(withvin: String) throws -> Car
    {
        //Creating a local variable
        var selected_car: Car?
        
        //Looping to find the car with the parameter VIN
        for car in self.mCars
        {
            if car.getVin() == withvin
            {
                selected_car = car
                break
            }
        }
        
        //If condition to check local variable
        if selected_car == nil
        {
            //If local variable if nil
            //Throwing InvalidCarVin Error
            throw Utilities.Errors.InvalidCarVin
        }
        
        //Returning forced unwrapped selected car
        return selected_car!
    }
    
    //Function to load all the cars from database into memory
    internal func loadCars(context: NSManagedObjectContext)
    {
        //If condition to check the number of cars
        if self.mCars.count == 0
        {
            //If the number of cars is zero
            //Creating a Request
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Car")
            
            //Creating a local variable
            var results: [NSManagedObject] = []
            
            do {
                //Fetching all the rows into results
                results = try context.fetch(fetchRequest)
            }
            catch {
                print(error)
            }
            
            //Looping for each result
            for result in results
            {
                //Getting all the car details
                let name = "\(result.value(forKey: "name") as! NSString)"
                let model = "\(result.value(forKey: "model") as! NSString)"
                let year: Int = (result.value(forKey: "year") as! NSNumber).intValue
                let price: Float = (result.value(forKey: "price") as! NSNumber).floatValue
                let color = "\(result.value(forKey: "color") as! NSString)"
                let vin = "\(result.value(forKey: "vin") as! NSString)"
                let image_data = (result.value(forKey: "image") as? NSData)
                
                //Creating a local variable car
                var car: Car
                
                //If Condition to check image_data
                if image_data != nil
                {
                    //If image data is not nil
                    //Converting data into UIImage
                    let image = UIImage(data: image_data! as Data)
                    
                    //Creating a car instance with image
                    car = Car(name: name, model: model, year: year, price: price, color: color, vin: vin, image: image)
                }
                else
                {
                    //Creating a car instance without image
                    car = Car(name: name, model: model, year: year, price: price, color: color, vin: vin, image: nil)
                }
                
                //Adding the car instance into Member Variable mCars
                self.mCars.append(car)
            }
            
            //Sorting the fetched cars alphabetically
            self.mCars.sort { (car1, car2) -> Bool in
                if car1.getName() < car2.getName()
                {
                    return true
                }
                return false
            }
        }
    }
    
    //Function to add a new user
    internal func addNewUser(name: String, username: String, password: String, context: NSManagedObjectContext) -> Bool
    {
        //Creating a local Variable
        var is_saved = false
        
        //Creating a new User entity
        let new_user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
        
        //Setting the data into entity
        new_user.setValue(name, forKey: "name")
        new_user.setValue(username, forKey: "username")
        new_user.setValue(password, forKey: "password")
        new_user.setValue(false, forKey: "manager")
        
        //Trying to save the entity into the database
        do
        {
            try context.save()
            
            //Setting that data is saved
            is_saved = true
        }
        catch
        {
            //Prints error if there was a problem in saving the database
            print(error)
        }
        
        //Returning that if the data is saved (User has been added)
        return is_saved
    }
    
    //Function to check a username
    internal func checkUserName(username: String, context: NSManagedObjectContext) -> Bool
    {
        //Creating a Request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        
        //Creating a local variable
        var results: [NSManagedObject] = []
        
        do {
            //Fetching all the rows into results
            results = try context.fetch(fetchRequest)
        }
        catch {
            print(error)
        }
        
        //Creating a local variable
        var count = 0
        
        //Looping for each result to check if username already exists in database data
        for result in results
        {
            if let uname = result.value(forKey: "username") as? NSString
            {
                let uname1 = "\(uname)"
                if uname1 == username
                {
                    count += 1
                    break
                }
            }
        }
        
        //If condition to check count
        if count > 0
        {
            //If count is greater than zero (The username is already in use)
            //Returning false
            return false
        }
        else
        {
            //If count is zero (The username is not in use)
            //Returning true
            return true
        }
    }
    
    //Function to check username and password
    internal func checkDetails(username: String, password: String, context: NSManagedObjectContext) -> (Bool, Bool)
    {
        //Creating local variables
        var is_manager = false
        
        //Creating a Request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        
        //Creating a local variable
        var results: [NSManagedObject] = []
        
        do {
            //Fetching all the rows into results
            results = try context.fetch(fetchRequest)
        }
        catch {
            print("fetch error: \(error)")
        }
        
        //Creating a local variable
        var count = 0
        
        //Looping for each result, to check if username password pair exists in database and if it does, is it a manager
        for result in results
        {
            if let uname = result.value(forKey: "username") as? NSString, let pass = result.value(forKey: "password") as? NSString, let mngr = result.value(forKey: "manager") as? NSNumber
            {
                let uname1 = "\(uname)"
                let pass1 = "\(pass)"
                if uname1 == username && pass1 == password
                {
                    count += 1
                    if mngr == 1
                    {
                        is_manager = true
                    }
                    break
                }
            }
        }
        
        //Returning if pair exists or not and if it the user is manager
        return (count > 0,is_manager)
    }
    
    //Function to add a manager
    internal func addManagerIfNotPresent(context: NSManagedObjectContext)
    {
        //If condition to check if manager exists
        //Function Call to check if username already exists
        if checkUserName(username: "manager", context: context)
        {
            //Manager does not exist in database
            //Creating a new User entity
            let new_user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
            
            //Setting the data into entity
            new_user.setValue("Manager", forKey: "name")
            new_user.setValue("manager", forKey: "username")
            new_user.setValue("9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08", forKey: "password")
            new_user.setValue(true, forKey: "manager")
            
            //Trying to save the entity into the database
            do
            {
                try context.save()
            }
            catch
            {
                //Prints error if there was a problem in saving the database
                print(error)
            }
        }
    }
}
