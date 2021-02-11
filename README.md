# Car-Inventory-iOS
This is an iOS application to maintain car inventory in application. It uses coreData to store car information and images.
<br/>
The application has the following basic functionalities.
- Startup Screen
- Registration Screen
- Login Screen
- Browsing Cars Screen
- Car Details Screen
- Add Cars (For Manager)
- Modify Cars (For Manager)
- Remove Cars (For Manager)

### Startup Screen
The Screen contains two buttons for Login and Sign Up, each is clickable for their specific functions. Each Screen is either usable by either manager or a normal user.
<p align="center">
  <img alt="Startup Screen" src="screenshots/startScreen.gif" />
</p>
<br/>

### Registration Screen
The screen asks user to enter full name, username, password and a re-type password. The application first checks if all the data is entered, where ever the data is not entered the phone vibrates and the empty text field shakes. Next, the application checks if the password matches with the re-typed password or not. Next, the application checks if the username is already in use or not. If none of these problem arises the user is registered. While registering the password is converted in SHA—256 hash for storage

<p align="center">
  <img alt="Registration Screen" src="screenshots/registeration.gif" />
</p>
<br/>

Process of Registration also has some checks, the process is as follows:
1. Check If Text Fields are empty
1. Check if password match
1. Check if the user name is already in use
1. Sign Up User
<p align="center">
  <img alt="User Already Exists Error" src="screenshots/username.png" />
</p>

<br/>
### Login Screen
The screen asks user to enter username and password. The application checks if the username, password pair exists in the database. If it does, it is checked if the user is a manager or not. The application only has one manager account with Username “manager” and Password “Test”. If the user is manager, this information is saved into application session.
<br/>
<p align="center">
  <img alt="Login Screen" src="screenshots/login.gif" />
</p>
<br/>

### Browsing Car Screen
The Screen uses UICollectionView to show cars. The UICollectionView uses a custom Cell, with a minimalist design, which shows the image of the car along with name and price.
The Cell contains a separate Card View, which can be slide up to show more information about the car, while the image of the car is faded. The Cell also has the animation which is that the cards presses down when pushed or hold onto. Clicking on the Cells takes you onto a Screen which shows more information about the car. The Screen also contains a search bar which can be used to filter the results.
<br/>
<p align="center">
  <img alt="Browsing Car Screen" src="screenshots/browse.gif" />
</p>
<br/>

This screen has two versions
- For Manager
- For User

The only difference between these two screens is that the user does not have a button to get add a new car
<br/>
<p align="center">
  <img alt="Manager Screen" src="screenshots/manager.png" />
  &#09;&#09;
  <img alt="User Screen" src="screenshots/user.png" />
</p>
<br/>

### Car Details Screen
The Screen uses Information about the car. The Cell contains a separate Card View, which can be slide up to show more information about the car, while the image of the car is faded. 
<br/>
<p align="center">
  <img alt="Car Details Screen" src="screenshots/carDetailsScreen.gif" />
</p>
<br/>

This screen has two versions
- For Manager
- For User

The only difference between these two screens is that the information in manager version is editable and is used to modify the car details. This same screen is also used to add new cars with blank details.
<br/>
<p align="center">
  <img alt="Car Details Screen for Manager" src="screenshots/carDetails-1.gif" />
  &#09;&#09;
  <img alt="Car Details Screen for Users" src="screenshots/carDetails-2.gif" />
</p>
<br/>

### Add Car
A car can only be added by the manager. It uses the same Car Details Screen but all the data is blank while trying to add car. The application uses Car Vin as a unique number, therefore no two cars can have the same Vin. When a new car is being added and has the same Vin as existing car it gives an error. The application can also fetch car image from Photo Library or Camera, but the image is not necessary to add a new car in the inventory. 
<br/>
<p align="center">
  <img alt="Adding Cars" src="screenshots/addCar.gif" />
</p>
<br/>

### Modify Car
A car can only be modified by the manager. It uses the same Car Details Screen but data is editable. The application uses Car Vin as a unique number, therefore while modifying a car Vin not modifiable.
<br/>
<p align="center">
  <img alt="Modifying Cars" src="screenshots/modify.gif" />
</p>
<br/>

### Remove Car
A car can only be removed by the manager. It uses the same Car Details Screen but data is editable. Under the editable details, there is a delete button which deletes the car.
<br/>
<p align="center">
  <img alt="Removing Cars" src="screenshots/removeCar.gif" />
</p>
<br/>

## Subtle Features
The Application contains some subtle UX features, such as:
- Password is Stored as SHA-256 Hash
- Empty TextFields Shake and vibrate phone
- Whole UI moves up when keyboard is shown
- Collection View Cell Contains another View Controller inside to display cars
- Animations when car details shows up
- Custom Segue Animations
- While Searching the Cell Animates
- Cells held animation
- Swipe down in Car Details Screen to go back
- Default Cell

### Password is Stored as SHA-256 Hash
The Password entered and stored is converted in SHA-256 hash for security
<br/>
<p align="center">
  <img alt="SHA 256" src="screenshots/sha256.png" />
</p>
<br/>

### Empty TextFields
Empty TextFields Shake and vibrate phone. It is done by writing an extension to UIView and adding animations to them. The Vibration is achieved by AudioServicesPlaySystemSound.
<br/>
<p align="center">
  <img alt="Shake Feature" src="screenshots/shake-1.gif" />
  &#09;&#09;
  <img alt="Shake Feature" src="screenshots/shake-2.gif" />
</p>
<br/>

### Whole UI moves up when keyboard is shown
This is done by two method:
- TextField Delegate and ScrollView
- NotificationCenter

<br/>
<p align="center">
  <img alt="Keyboard Feature" src="screenshots/keyboard-1.gif" />
  &#09;&#09;
  <img alt="Keyboard Feature" src="screenshots/keyboard-2.gif" />
</p>
<br/>

### Car Details
Collection View Cell Contains another View Controller inside to display cars. This is done by adding a View Controller as a sub view of the cell itself. The sub View Controller in itself holds another Table View
<br/>
<p align="center">
  <img alt="Car details" src="screenshots/ViewControllerInsideCell.gif" />
</p>
<br/>

### Animations when car details shows up
These uses UIViewPropertyAnimator for animating. Both uses Blur Animation and Translation Animation. But the right one also uses corner radius animation.
<br/>
<p align="center">
  <img alt="Animation" src="screenshots/ViewControllerInsideCell.gif" />
  &#09;&#09;
  <img alt="Animation" src="screenshots/animations.gif" />
</p>
<br/>

### Custom Segue Animations
Done by creating a Custom Segue Storyboard Class
<br/>
<p align="center">
  <img alt="Custom Segue" src="screenshots/CustomSegue.gif" />
</p>
<br/>

### While Searching the Cell Animates
Done by adding animation to cell, by using collectionView function with willDisplay.
<br/>
<p align="center">
  <img alt="Search Animations" src="screenshots/searchAnimation.gif" />
</p>
<br/>

### Cells held animation
Done by adding animation to cell, by using collectionView functions with didHighlightItemAt and didUnHighlightItemAt
<br/>
<p align="center">
  <img alt="Cell Held Animations" src="screenshots/cellHeld.gif" />
</p>
<br/>

### Swipe down in Car Details Screen to go back
It is simply adding a UIPanGestureRecognizer to the View
<br/>
<p align="center">
  <img alt="Swipe down to go back" src="screenshots/CustomSegue.gif" />
</p>
<br/>

### Default Cell
If there are no cars in inventory, the application shows a default cell that says ”No car in inventory”
<br/>
<p align="center">
  <img alt="Default Cell" src="screenshots/empty.png" />
</p>
<br/>
