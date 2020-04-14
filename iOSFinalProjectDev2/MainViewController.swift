//
//  MainViewController.swift
//  iOSFinalProjectDev2
//
//  Created by Chaitanya Sanoriya on 25/03/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    //Global Variable (Always starting with small m to denote member variables of a class)
    private let mCellIdentifier = "cell"
    private var mCars: [Car]! = []
    private var mIsReloading: Bool = false
    var mCell: CarCollectionViewCell?
    private var mContext: NSManagedObjectContext!
    
    //Outlets for UI Elements
    @IBOutlet weak var mSearchBar: UISearchBar!
    @IBOutlet weak var mAddCarButton: UIButton!
    @IBOutlet weak var mCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Function Call to Register the Custom Collection View Cell
        registerCollectionViewCells()
        
        //Setting the background image of Search Bar as an empty image to remove the border around it
        self.mSearchBar.backgroundImage = UIImage()
        
        //Setting up Core Data variables for this UIViewController
        let app_delegate = UIApplication.shared.delegate as! AppDelegate
        self.mContext = app_delegate.persistentContainer.viewContext
        
        //If Condition checking if the user a manager
        if !Utilities.isManager()
        {
            //If the user is not a manager
            //Removing the Add Car Button
            self.mAddCarButton.removeFromSuperview()
        }
        
        //Function call to load all cars into memory from database
        Singleton.getInstance().loadCars(context: self.mContext)
        
        //Getting all the cars into this View Controller
        self.mCars = Singleton.getInstance().getAllCars()
    }
    
    //Function with UICollectionViewDataSource, returns the number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //If condition to check if the number of cars
        if self.mCars.count != 0
        {
            //If the number of cars is not equal to zero
            //returning the number of cars as the number of cells
            return self.mCars.count
        }
        else
        {
            //If the number of cars is zero
            //returning one as the number of cells
            return 1
        }
    }
    
    //Function with UICollectionViewDataSource, returns the cell at a particular index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //If condition to check if the number of cars
        if self.mCars.count != 0
        {
            //If the number of cars is not equal to zero
            //Getting a Reusable cell as a CarCollectionViewCell
            let cell = mCollectionView.dequeueReusableCell(withReuseIdentifier: self.mCellIdentifier, for: indexPath) as! CarCollectionViewCell
            
            //Function call to send car data into the cell
            sendData(cell: cell, car: self.mCars[indexPath.row])
            
            //If condition to check image of the car
            if self.mCars[indexPath.row].getImage() != nil
            {
                //If the image of the car is present
                //Setting the image of the car to the imageview of the cell
                cell.mImageView.image = self.mCars[indexPath.row].getImage()
            }
            else
            {
                //If the image of the car is not present
                //Setting a placeholder image to the imageview of the cell
                cell.mImageView.image = UIImage(named: "placeholder")
            }
            
            //Setting the Data of the car in the cell
            cell.mNameLabel1.text = self.mCars[indexPath.row].getName()
            cell.mPriceLabel1.text = "$ \(self.mCars[indexPath.row].getPrice())"
            cell.mVin = self.mCars[indexPath.row].getVin()
            
            //returning the cell
            return cell
        }
        else
        {
            //If the number of cars is zero
            //Getting a Reusable cell as a CarCollectionViewCell
            let cell = mCollectionView.dequeueReusableCell(withReuseIdentifier: self.mCellIdentifier, for: indexPath) as! CarCollectionViewCell
            
            //Setting the Data of the car in the cell, to represnt that there is no car in the database
            cell.mNameLabel1.text = "No Car in Inventory"
            cell.mPriceLabel1.text = ""
            cell.mImageView.image = UIImage(named: "placeholder")
            cell.mDetails = nil
            cell.mVin = nil
            
            //returning the cell
            return cell
        }
    }
    
    //Function to send the data of the car to the cell
    private func sendData(cell: CarCollectionViewCell, car: Car?)
    {
        //Creating a local variable
        var details: [String] = []
        
        //Adding data of the car to the local variable
        details.append(car?.getName() ?? "Test")
        details.append(car?.getModel() ?? "Test")
        details.append(String(car?.getYear() ?? 0) )
        details.append("$ \(car?.getPrice() ?? 0.00)")
        details.append(car?.getColor() ?? "Test")
        details.append(car?.getVin() ?? "Test")
        
        //Setting the data of the car into the cell
        cell.mDetails = details
    }
    
    //Function to register Custom Collection View Cell
    func registerCollectionViewCells()
    {
        //Creating the instance of the Custom Collection View Cell
        let custom_collection_view_cell = UINib(nibName: "CarCollectionViewCell", bundle: nil)
        
        //Registering Custom Collection View Cell with UICollectionView
        self.mCollectionView.register(custom_collection_view_cell, forCellWithReuseIdentifier: self.mCellIdentifier)
    }
    
    //Function with UISearchBarDelegate, to perform functions when search is pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Copying all the cars into a local variable
        let cars = Singleton.getInstance().getAllCars()
        
        //Getting the text from search bar in lowercased form
        let search_text = searchBar.text!.lowercased()
        
        //If condition to check the search text
        if search_text != ""
        {
            //If search text is not empty
            //Creating a local variable to store filtered cars
            var filtered_cars: [Car] = []
            
            //Looping for all the cars in cars local variable
            for car in cars
            {
                //If condition to check if any of the car details has that search text
                if car.getName().lowercased().contains(search_text) || car.getModel().lowercased().contains(search_text) || String(car.getYear()).contains(search_text) || String(car.getPrice()).contains(search_text) || car.getColor().contains(search_text) || car.getVin().contains(search_text)
                {
                    //If the details contains search text
                    //Adding the car in filtered cars
                    filtered_cars.append(car)
                }
            }
            
            //Setting the member variable of this class , mCars to filtered cars
            self.mCars = filtered_cars
            
            //Setting the member variable of this class , mIsReloading to true
            self.mIsReloading = true
            
            //Reloading data of UICollectionView
            self.mCollectionView.reloadData()
        }
        else
        {
            //Setting the member variable of this class , mIsReloading to true
            self.mIsReloading = true
            
            //Setting the member variable of this class , mCars to all cars
            self.mCars = cars
            
            //Reloading data of UICollectionView
            self.mCollectionView.reloadData()
        }
        
        //Hiding the keyboard used by search bar
        searchBar.resignFirstResponder()
    }
    
    //Function with UICollectionView Delegate, called when the cell is about to be displayed
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //If Condition to check mIsReloading
        if self.mIsReloading
        {
            //If mIsReloading is true
            
            //Setting up an Animation to translate and fade in
            let transform = CATransform3DTranslate(CATransform3DIdentity, 200, 10, 0)
            cell.layer.transform = transform
            cell.alpha = 0.5
            
            //Animating the Cell
            UIView.animate(withDuration: 0.25) {
                
                //Animating the cell
                cell.layer.transform = CATransform3DIdentity
                cell.alpha = 1.0
                
                //Setting the Member Variabl mIsReloading to false
                self.mIsReloading = false
            }
        }
    }
    
    
    //Function with UICollectionView Delegate, called when the cell is highlighted
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        //Animating the Cell
        UIView.animate(withDuration: 0.5) {
            
            //Fetching the cell that is being highlighted
            if let cell = collectionView.cellForItem(at: indexPath) as? CarCollectionViewCell {
                
                //Animating the Cell to shrink
                cell.transform = .init(scaleX: 0.95, y: 0.95)
            }
        }
    }
    
    //Function with UICollectionView Delegate, called when the cell is  unhighlighted
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
        //Animating the Cell
        UIView.animate(withDuration: 0.5) {
            
            //Fetching the cell that is being highlighted
            if let cell = collectionView.cellForItem(at: indexPath) as? CarCollectionViewCell {
                
                //Animating the Cell to shrink
                cell.transform = .identity
            }
        }
    }
    
    //Function with UICollectionView Delegate, called when the cell is Selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //If conditions to check the number of cars
        if self.mCars.count != 0
        {
            //If the number of cars is not zero
            //Getting the and Setting Member Variable mCell to the selected cell
            self.mCell = (collectionView.cellForItem(at: indexPath) as! CarCollectionViewCell)
            
            //Moving to Car Details View Controller
            self.performSegue(withIdentifier: "showCarDetails", sender: self)
        }
    }
    
    //Function called before segue is performed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //If conditions the segues identifier
        if segue.identifier == "showCarDetails"
        {
            //If segue Identifier is "showCarDetails"
            //Getting the Destination of segue as Car Details View Controller instance
            let cdvc = segue.destination as! CarDetailsViewController
            
            //Setting the starting y of the UICollectionView into Car Details View Controller (to be used when returning from Car Details View Controller to Main View Controller)
            cdvc.mTransitionBackY = self.mCollectionView.frame.origin.y
            
            //Setting Car Data in Car Details View Controller
            cdvc.mVin = self.mCell?.mVin
            cdvc.mImage = self.mCell?.mImageView.image
        }
    }
    
    
    //IBAction function for Add Car Button
    @IBAction func mAddCarButtonClicked(_ sender: Any) {
        
        //Moving to Car Details View Controller
        performSegue(withIdentifier: "showCarDetails", sender: self)
    }
}
