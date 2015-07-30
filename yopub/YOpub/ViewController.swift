//
//  ViewController.swift
//  YoPub!
//
//  Created by Justin Platz on 5/20/15.
//  Copyright (c) 2015 ioJP. All rights reserved.

import UIKit

var friendsArray: [String] = []

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var tokenID: NSData?


    var colorsArray: [UInt] = [0xE84C3d, 0x1BBC9B, 0x2DCC70, 0x3598DB, 0x34495E, 0x16A086, 0xF1C40F, 0x297FB8, 0x8D44AD]
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        let config = PNConfiguration(
            publishKey: "pub-c-f83b8b34-5dbc-4502-ac34-5073f2382d96",
            subscribeKey: "sub-c-34be47b2-f776-11e4-b559-0619f8945a4f")
      
        appDel.client = PubNub.clientWithConfiguration(config)
                
        var image = UIImage(named: "yopubW.png")
        self.navigationItem.titleView = UIImageView(image: image)
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        var navColor = UIColorFromRGB(0x3598DB)
        navigationController?.navigationBar.barTintColor = navColor

    }

    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        (cell as! TableViewCell).usernameLabel.text = friendsArray[indexPath.row].uppercaseString as String
    
        var color = UIColorFromRGB(colorsArray[indexPath.row])
        (cell as! TableViewCell).backgroundColor = color

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        var myName = PFUser.currentUser()?.username?.uppercaseString

        var payload =
        ["apns":
                ["alert":myName!,
                "badge":"1",
                "sound":"default"]
        ]
        
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        appDel.client?.publish(
            "test",
            toChannel: friendsArray[indexPath.row] as String,
            mobilePushPayload: payload,
            withCompletion: nil)
        
        var sentAlert = UIAlertView()
        sentAlert.title = "YoPub! Sent To"
        sentAlert.message = (friendsArray[indexPath.row] as String).uppercaseString
        sentAlert.addButtonWithTitle("OK")
        sentAlert.show()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(animated: Bool) {
        if(!isUserLoggedIn){
            self.performSegueWithIdentifier("loginViewSegue", sender: self)
        }
        else{
            self.tableView .reloadData()
        }
    }
    

    
    @IBAction func LogOutButtonTapped(sender: AnyObject) {
        
        currentUser = PFUser.currentUser()
       
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        appDel.client?.removeAllPushNotificationsFromDeviceWithPushToken(tokenID, andCompletion: nil)
        
        let deviceToken: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken")
        appDel.client?.removePushNotificationsFromChannels(nil, withDevicePushToken: deviceToken as! NSData, andCompletion: nil)
    }
    
    
    @IBAction func AddButtonTapped(sender: AnyObject) {
        var inputTextField: UITextField?
        
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Add Friend", message: "Enter Friend's Username", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            self.tableView .reloadData()
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add the OK action
        let nextAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            
            var query = PFUser.query()
            query!.whereKey("username", equalTo: inputTextField!.text)
            var friend = query!.findObjects()
            
            if (friend!.isEmpty){
                var alert = UIAlertView()
                alert.title = "Username Does Not Exist"
                alert.addButtonWithTitle("Done")
                alert.show()
            }
            else{
                var newRelation = PFObject(className: "Relation")
                newRelation["Sender"] = PFUser.currentUser()?.username
                newRelation["Friend"] = inputTextField!.text
                newRelation.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        friendsArray.append(inputTextField!.text)
                        self.tableView.reloadData()
                    } else {
                        // There was a problem, check error.description
                    }
                }
            }
        }
        actionSheetController.addAction(nextAction)
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            // you can use this text field
            inputTextField = textField
        }
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
  
    
}















