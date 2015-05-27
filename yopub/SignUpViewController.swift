//
//  SignUpViewController.swift
//  YoPub!
//
//  Created by Justin Platz on 5/20/15.
//  Copyright (c) 2015 ioJP. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField! = nil
    @IBOutlet weak var passwordTextField: UITextField! = nil
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        usernameTextField.delegate=self
        passwordTextField.delegate=self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
            if error == nil {
                
                dispatch_async(dispatch_get_main_queue()) {
                    //self.performSegueWithIdentifier("loginViewSegue", sender: self)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
            } else {
                
                self.activityIndicator.stopAnimating()
                
                if let message: AnyObject = error!.userInfo!["error"] {
                    self.displayAlertMessage("There is an Error")
                }
            }
        }
        
    }
    
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
