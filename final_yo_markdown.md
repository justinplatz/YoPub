![image](/Users/nyjetsjustin/Documents/PubNub/YoPub/bannerBlog.png)

# (1/2) Using PubNub for Simplified Swift Push Notifications


It is difficult to overemphasize the power of mobile push notifications in your app. There is virtually no other tool that allows you to tap almost two billion people on the shoulder.

Push notifications aren’t a new invention, but as mobile handset growth continues to accelerate along with increasing  IoT connected devices, push alerts only become more important as a method for applications to pass on pressing information and re-engage their users. 

Push notifications can be an ingenious way to prompt a mobile user at the right place, at the right time, regarding the right piece of information. 

If you observed the impressive splash made by the mobile messaging app Yo, then you may have seen how impactful a simple push notification can be.

In this tutorial I will show you how you can use PubNub & Swift to easily implement push notifications across many different channels by creating a Yo-esque app.


##Overview

My app, dubbed YoPub!, consisted of a few technologies:

* ***Swift*** as our development language of choice
* ***CocoaPods*** for our import library management
* ***Parse*** to handle the User Management 
* ***PubNub*** to simplify handling Push Notifications 


If you are familiar with using these technologies already, then you should skip to <***Part Two***> where I will focus on how to use ***PubNub*** & Swift to send Push Notifications.

If any of this is unfamiliar to you, do not fret we will cover how to build this app line by line. Also, should you want to peek at how my code was done, the github repo for this project can be found at: <https://www.google.com>

#### Creating A New Project

First, open Xcode and Go To: File -> New
Select a **Single View Application** and press **Next**.

Enter YoPub! for the **Product Name**, set the **Language** to **Swift**, and **Devices** to **iPhone**. Make sure Use **Core Data** is **unchecked**, and click **Next**.<br><br>
Choose a directory to save your project, and click **Create**.


#### Installing CocoaPods

If you have never installed a Pod before, a really good tutorial on how to get started can be found the CocoaPods official website at:

<https://guides.cocoapods.org/using/using-cocoapods.html>

Once you have **CocoaPods** installed go ahead and open the **PodFile** for YoPub and set it up to look just like this:

	# Uncomment this line to define a global platform for your project
	# platform :ios, '8.0'

	target 'yopub' do

	source 'https://github.com/CocoaPods/Specs.git'

	pod 'PubNub', :git => 'https://github.com/pubnub/objective-c.git', :branch => '4.0b3'
	pod 'Parse', '~> 1.7'


	end

	target 'yopubTests' do



	end



Make sure you grab the most recent pod versions in your project. Also, it is important that after installing our pods here on out we operate entirely in the Workspace part of our project. 

### Adding a Bridging-Header

The next thing we need to do to connect our Swift app to our pods is create an **Objective-C bridging header**. To do this you need to create a new File (File -> New -> File) of type Objective-C File. Call this whatever you like because we will end up deleting this file. Here I have just called it testHeader. When you see "Would you like to configure an Objective-C bridging header?" select Yes. This is the file we really care about.

Now it will add some new files to your project. Click on the File: YoPub!-Bridging-Header.h. Underneath the commented code we need to add an #import so that our project knows to use the Parse  and also the PubNub iOS SDK. To do this we simply add the following lines into this file: 
										
			#import <Parse/Parse.h>
			#import <PubNub/PubNub.h>
	
That is it. Now your Xcode project is set up with CocoaPods, and your Bridging-Header is ready to go. 

### User Login and Sign Up Views
First we are going to design the basic UI of the Login and Sign Up view. We will want to be able to determine that when we reach our home screen it is because we are in fact signed in, so we add a UILabel anywhere to the view and write "We are signed in". This page will later become our home screen of the app.

Next we will create the Login and Sign Up views. We begin by dragging a new View Controller onto the storyboard. On this new View Controller, we drag three UI Labels and title them "Login View","Username","Password". We add UITextfields beneath the "Username" and "Password" labels so users can enter their information.  Then, we drag a UIButton onto the view and label it Login. Your Storyboard should now look similar to this:

![image](/Users/nyjetsjustin/Documents/PubNub/YoPub/Views1.png)

We also want to provide new users the ability to Sign Up. We do so by dragging a UIButton to the Login View and title it Sign Up.

Now, we want to make sure that our main view is protected and that the user must be signed in to see the main page. To do so we need to embed the Signed In View in a view controller. We do so by clicking on the view, and going to <br>
Editor->Embed In->Navigation View Controller. 

Since we want the Login View to appear on top, or before, the Signed In page, we must add a segue. To do so, we Control Click from the Signed In View Controller and drag to the Login View Controller, and select present modally. We click on the segue arrow and give it an identifier: loginViewSegue. This method will ensure that Login View will appear on top of the Signed In view. Now your Storyboard should look like this:
![image](/Users/nyjetsjustin/Documents/PubNub/YoPub/Views2.png)

We additionally need a view to allow new users to Sign Up, so we drag a new View Controller beneath our Login View. This view will be very similar to our Sign Up view, however we add one more field and label for Phone Number, and only one button for Sign Up. We should also account for Users who clicked Sign Up perhaps by accident, so we add a new button onto the view which we label Back To Login.

From the Login View, we click on the Sign Up button and Control Click and drag to Sign Up View and again choose Present Modally. We give the segue an identifier: SignUpViewSegue

We can test if our work so far works by clicking on our Signed In View, selecting the Assistant editor, and pasting the following code: 

	 override func viewDidAppear(animated: Bool) {
     	self.performSegueWithIdentifier("loginViewSegue", sender: self)
    }

Run the app and try it for yourself. Immediately you should see the Login page will appear. 

We now need to add a new file. So click <br>File->New->File->Cocoa Touch Class->Next.<br> Give it Class: SignUpViewController, Subclass of: UIViewController and Language: Swift and create.

Back in the storyboard we must connect the Sign Up View to the SignUpViewController. We do so by clicking on the Sign Up View and giving it class: SignUpViewController. Now click on the assistant editor. In the assistant editor we begin to connect all of our text fields by doing Control Click and dragging the textfields above our ViewDidLoad() function. I used common sense names for the outlets like: usernameTextField, passwordTextField. We then Control Click and drag out SignUp button , make it an action not an outlet, and give it name SignUpButtonTapped. Paste the following code into your SignUpViewController: 
		
	@IBAction func SignUpButtonTapped(sender: AnyObject) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        //Check for empty fields
        if(username.isEmpty || password.isEmpty){
            //Display alert message
            displayAlertMessage("All Fields are Required")
            
            return
        }
        
        //Store data
        
    }
    
    func displayAlertMessage(myMessage:String){
    
        var myAlert = UIAlertController(
        	title: "Alert", 
        	message: myMessage, 	
        	preferredStyle:UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(
        	title: "OK", 
        	style: UIAlertActionStyle.Default, 
        	handler: nil)
        
        myAlert.addAction(okAction)
        
        self.presentViewController(
        	myAlert, 
        	animated: true, 
        	completion: nil)
    }

At this point our screen only checks that a user has entered ***any information***, and will display an error only if a field is left empty. In your app you may also want to do a check here on the information which is entered (ie. Username is not already taken, password is X characters long ... etc). Since it is now necessary to store our data in a backend, so we will go ahead and set up Parse!

###Using Swift to connect to Parse.com

If you do not have an account with Parse.com, now is the time to make one. Parse is an initially free service and does not take long to register. 

Once you are signed in go back to the Parse.com log in area and select the Settings from the navigation pane. On this page, down the left hand side you will see another menu structure. We need to click the Keys link.

You will then be shown quite a few different application keys. The ones we want are the Application ID and the Client Key.

With these, we now need to go to the AppDelegate.swift in Xcode and change this function:


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
by adding the following line into the function:

			Parse.setApplicationId(“your_application_key”, clientKey: “your_client_key”)

Next, replace your_application_key and your_client_key with the keys that we just got from the Parse Keys link.

Setting up Parse with Swift is pretty much that easy! 

We want to use Parse to manage our user registration so on Parse.com click Data -> Add Class and select User. 

Also go ahead and create a new class named Relation which has two Col's of type String named Sender & Friend (we will use this later to manage user relationships).

Lets go back into our SignUpViewController and visit the SignUpButtonTapped function and change it as follows:

	@IBAction func SignUpButtonTapped(sender: AnyObject) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        //Check for empty fields
        if(username.isEmpty || password.isEmpty){
            //Display alert message
            displayAlertMessage("All Fields are Required")
            
            return
        }
        
        //Create and store data
        var newUser = PFUser()
        newUser.username = username
        newUser.password = password
        
        newUser.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue()) {
                   self.dismissViewControllerAnimated(true, completion: nil)
                }
                
            } 
            else {                
                if (let message: AnyObject = error!.userInfo["error"]) {
                    self.displayAlertMessage("There is an Error")
                }
            }
        }
        
    }
    
If you try running the app, and Signing up you should notice the User information being stored in your data on Parse.com 

Now that we can Sign Up, we also need to be able to Log In. We go to our storyboard, click on Log In View and select Create File->Cocoa Touch Class. Give the file Class:LogInViewController and Subclass Of: UIViewController and Language: Swift.

In our LogInViewController we should now go ahead and connect our textfields, and connect the Login button by giving it an action called loginButtonTapped. We add the following code:


	    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        let usrName = usernameTextField.text
        let pWord = passwordTextField.text
        
        //Validate Username and Password
        PFUser.logInWithUsernameInBackground(usrName, password:pWord) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                
                var currentUser = PFUser.currentUser()
                isUserLoggedIn = true
                var usrname = currentUser?.username
                
                var query = PFQuery(className:"Relation")
                query.whereKey("Sender", equalTo : usrname!)
                query.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        // The find succeeded.
                        if let objects = objects as? [PFObject] {
                            for object in objects {
                                var friendName = object["Friend"] as! String
                                friendsArray.append(friendName)
                            }
                        }
                    }
                    else {
                        // Log details of the failure
                        println("There is an error in the query it is Error: \(error!) \(error!.userInfo!)")
                    }
                }
                
                ViewController().setChannel(currentUser!)
                self.dismissViewControllerAnimated(true, completion: nil)
                
                
                
            } else {
                // The login failed. Check error to see why.
                self.displayAlertMessage("Username Or Password Is Incorrect")
            }
        }
    }
    
In my version of the app I added a  global variable "isUserLoggedIn" to keep track of whether the User is logged in, so above the class 

	class LogInViewController: UIViewController, UITextFieldDelegate{
 we add this line:

	var isUserLoggedIn = false
	
Now we can go back into  our original ViewController and edit our ViewDidAppear function to check if the user must log in like this:
	
	override func viewDidAppear(animated: Bool) { 
        if(!isUserLoggedIn){
            self.performSegueWithIdentifier("loginViewSegue", sender: self)
        }
    }

Lastly, we need to give a user the ability to log out. So we go back to our storyboard and click on our SignedIn View. From the components library we drag a Bar Button onto the top left corner. Lets change the title of this button from Item to Log Out. We control drag the LogOut button to our view controller and give it an action LogOutButtonTapped. In that function we simply add:

        currentUser = PFUser.currentUser()
        
By now your app should be able to switch between Login and Signup, check for empty fields and respond with alerts, store user data into Parse, and finally take us into the app upon valid login.
 
 ![image](/Users/nyjetsjustin/Documents/PubNub/YoPub/IMG_1429.gif)

In the next part of this tutorial I will show you how to populate your UITableView using Parse and then after that in <***Part Two***> we will use PubNub to allow users to send YoPub! Push Notifications!

### Creating the YoPub! Table View

Click on Main.storyboard, in the lower right corner drag a **Table View** onto the storyboard and drag it to cover the Signed In View Controller.

Next, connect the Table View to an outlet in ViewController.swift: show the Assistant Editor, select the Table View, control-drag from it into ViewController.swift, just inside the class block, and name the outlet yoTableView.

The YOPub! UI is essentially just a table field with the user's Friends, so in the table you need to create a cell to represent each Friend. 

So were going to need to be able to add friends, right?

Lets drag another bar button onto the top right corner. We change the identifier from Custom to Add because it looks fancy.  And we connect the Add button to our ViewController and give it an action called AddButtonTapped. Now we will define the action for when we click to add a new friend.



<script src="https://gist.github.com/justinplatz/bfb2b4cb4a7c811bb102.js"></script>

Before this will work properly we will need to add some UITableView functions into our code. First, on the storyboard click on the Cell and give it the identifier "Cell". Now, go ahead and add the following: 
    
       func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        (cell as! TableViewCell).usernameLabel.text = friendsArray[indexPath.row] as String
              
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
    }
    
        
        
On our cell we want to place a label which will be used to represent our friend's username.
We also want to create a new file named TableViewCell.swift which is of type UITableViewCell. The code for this file should look like this: 

	import UIKit


	class TableViewCell: UITableViewCell {
    
    //Make sure you connect your cell label from the Storyboard to this
    @IBOutlet weak var usernameLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
	}

At this point when we sign in we should see a table filled with friends! And we can even check if we are adding a friend with an invalid username. 
![image](/Users/nyjetsjustin/Documents/PubNub/YoPub/IMG_1430.gif)

That means we are more than halfway done to making our YoPub! app. 

All we need to do now is to incorporate PubNub to simplify how we will send our YoPub Push Notifications to our friends.

-----
# (2/2) Using PubNub for Simplified Swift Push Notifications


Before we go any further it is very important that you set up push notifications for your project through Apple. If you have never done this before there are clear instructions on how to do so at: <https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/ConfiguringPushNotifications/ConfiguringPushNotifications.html> This will require you have an Apple dev membership and getting a few .certs. For a first timer this can be a headache but this process unfortunately must be done for all iOS apps which will use push notifications. 

You will also need to enable Push Notifications on your PubNub account. This can be done at <https://admin.pubnunb.com>

Now then...


The PubNub iOS SDK should already be present in our project. Our goal now is to be able to click on a friends name  from the TableView and send them a YoPub! Push Notification. Luckily for us both, PubNub makes this functionality really easy to do, and although I will only cover how to send push notifications to one person at a time, it is just as simple to send notifications to larger groups all at once. 

I'm going to teach you the bare necessities of setting up Push Notifications in your Swift app, and how to use PubNub to simplify the process of managing the Push Notifications. If you skipped Part 1 then you should go back and check out how to install the necessary CocoaPods, and also how to set up your Bridging Header. Now, if you are just interested in the nitty, gritty and want the code you can clone my repo at <https://github.com/justinplatz/yopub>.

Lets go back into our AppDelegate. Beneath the class, but outside of any function we need to add the following code to initialize an instance of PubNub like so: 

    var client:PubNub?
    
    
Here we are initializing an instance of PubNub and naming it client. We will use client to handle most of our PubNub related functionality.

Lets go back into our didFinishLaunchingWithOptions function. We want to have our app request to enable push notifications, we can do this by adding the following lines:

<script src="https://gist.github.com/justinplatz/671d9671c6a815e1ccbc.js"></script>

We need a few more functions into our AppDelegate, here they are:

<script src="https://gist.github.com/justinplatz/63bfee036c9748ab9293.js"></script>

        
If you are unfamiliar with what a Push Notification composition looks like, take a gander at this: 
![image](/Users/nyjetsjustin/Documents/PubNub/YoPub/views4.png)

The way we will set up our push notifications is most similar to Example 2, using an aps dictionary. Looking closer at the didReceiveRemoteNotification you can see we are setting up our Push Notification alert. Since every Push Notification simply says "YoPub!" we set the alert.message to be "YoPub!". Our alert.title will show us who sent us the message we get from userInfo["aps"]!.objectForKey("alert") as AnyObject? as! String . 

Now that our AppDelegate is all setup to receive Push Notifications we should go back into our ViewController and create a way to actually send the Push Notifications. 
    
We need to go back into the ViewDidLoad Function and add a few things to configure our instance of PubNub:
  
<script src="https://gist.github.com/justinplatz/2d4c6c4d7cf839561f1b.js"></script>

We need to subscribe to the right channels when we login each time so back in the LoginViewController we will edit our loginButtonTapped like so:

<script src="https://gist.github.com/justinplatz/4538f5e0c10bdf15a62e.js"></script>

In the case of YoPub!, when a user signs out, he should be unsubscribed from all channels, so we need to go back into ViewController and edit the LogOutButtonTapped and adjust it to contain:

<script src="https://gist.github.com/justinplatz/908f19d85ec4ee3b33ab.js"></script>

Our app is nearly done! But we still need to send the Push Notifications when we click on a friends name. Lets go back to our didSelectRowAtIndexPath function in the ViewController. We add the following:

<script src="https://gist.github.com/justinplatz/903c238bd5356c179297.js"></script>
        
 We can now send Push Notifications! Go ahead and try it out... a simple way is to add yourself as a friend and try sending one. It is also useful to utilize the Console at <http://www.PubNub.com/Console> to send push notifications to your phone, and checking that they are showing up as expected. 


Push Notifications are a powerful tool in a developers toolbox. Many apps experience a large customer base of inactive users who have downloaded the app but do not use it daily. Push notifications allow developers to provide up-date relevant information to users, encouraging engagement, increasing recognition and increasing involvement. They are certainly a good method to keeping your app fresh in the users focus, and PubNub can be an invaluable tool in this process. 

Should you have any questions about my finished project, my entire code can be viewed and downloaded at: <https://github.com/justinplatz/yopub>


