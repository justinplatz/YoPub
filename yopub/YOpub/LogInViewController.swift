//
//  LogInViewController.swift
//  YoPub!
//
//  Created by Justin Platz on 5/20/15.
//  Copyright (c) 2015 ioJP. All rights reserved.
//

import UIKit

var currentUser:PFUser?
var isUserLoggedIn = false

class LogInViewController: UIViewController, UITextFieldDelegate, PNObjectEventListener {
    
    var tokenID:NSData?
    
    @IBOutlet weak var usernameTextField: UITextField! = nil
    
    @IBOutlet weak var passwordTextField: UITextField! = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        passwordTextField.delegate=self
        usernameTextField.delegate=self
        
        isUserLoggedIn = false
        friendsArray = []

    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        let usrName = usernameTextField.text
        let pWord = passwordTextField.text
        
        //Validate Username and Password
        PFUser.logInWithUsernameInBackground(usrName, password:pWord) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                
                var currentUser = PFUser.currentUser()
                println(currentUser?.username)

                if currentUser != nil {
                    // Do stuff with the user
                } else {
                    // Show the signup or login screen
                }
                
                isUserLoggedIn = true
                var usrname: String! = currentUser!.username as String!
                
                println("Current user is " + usrname!)
                var query = PFQuery(className:"Relation")
                query.whereKey("Sender", equalTo : usrname!)
                query.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        // The find succeeded.
                        if let objects = objects as? [PFObject] {
                            for object in objects {
                                var friendName = object["Friend"] as! String
                                //println(friendName)
                                friendsArray.append(friendName)
                                
                                //let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
                                //appDel.client?.publish("Online", toChannel: friendName, withCompletion: nil)

                            }
                        }
                    }
                    else {
                        // Log details of the failure
                        println("There is an error in the query it is Error: \(error!) \(error!.userInfo!)")
                    }
                }
                
                let appDel = UIApplication.sharedApplication().delegate as! AppDelegate

                let deviceToken: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken")

                appDel.client?.addListeners([self])
                
                ///// 
                // First lets remove all channels
                appDel.client?.removeAllPushNotificationsFromDeviceWithPushToken(deviceToken as! NSData, andCompletion: nil)
            
                //////
                // Now lets add just the one that we want
                appDel.client?.addPushNotificationsOnChannels([currentUser!.username as String!], withDevicePushToken: deviceToken as! NSData,andCompletion: nil)
                
                

                self.dismissViewControllerAnimated(true, completion: nil)
                
                
            } else {
                // The login failed. Check error to see why.
                self.displayAlertMessage("Username Or Password Is Incorrect")
            }
        }
    }
    
    func displayAlertMessage(myMessage:String){
        var myAlert = UIAlertController(title: "Alert", message: myMessage, preferredStyle:UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    
    
}
