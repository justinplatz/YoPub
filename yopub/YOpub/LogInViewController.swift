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
                var usrname = currentUser?.username
                
                
                //println("Current user is " + usrname!)
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
    

    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        
//        println("Code goes here")
//        if (segue.identifier == "dismissViewControllerAnimated" ){
//            println("Then does it go herE?")
//            let vc = segue.destinationViewController as! ViewController
//            vc.channelOfSignedIn = "Test"
//        }
//    }
    
    
    func displayAlertMessage(myMessage:String){
        var myAlert = UIAlertController(title: "Alert", message: myMessage, preferredStyle:UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    
    
}
