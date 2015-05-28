//
//  ViewController.swift
//  YoPub!
//
//  Created by Justin Platz on 5/20/15.
//  Copyright (c) 2015 ioJP. All rights reserved.





//typedef void (^PNClientPushNotificationsRemoveHandlingBlock)(PNError *error);
//typedef void (^PNClientPushNotificationsEnableHandlingBlock)(NSArray *channels, PNError *error);
//typedef void (^PNClientPushNotificationsDisableHandlingBlock)(NSArray *channels, PNError *error);
//typedef void (^PNClientPushNotificationsEnabledChannelsHandlingBlock)(NSArray *channels, PNError *error);

import UIKit



var friendsArray: [String] = []




class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PNObjectEventListener {
    
    @IBOutlet weak var tableView: UITableView!
    var client : PubNub?
    
    var alertNotification:NSDictionary = [
        "alert" : [""],
        "badge" : [1],
        "sound" : ["default"]
    ]
    
    
    
    var tokenID: NSData? {
        didSet {
            println("The Token ID has been set*****")
            
            
            client?.pushNotificationEnabledChannelsForDeviceWithPushToken(tokenID, andCompletion: { (result, status) -> Void in
                println("the result is ", result)
                println("the status is ", status)
            })
            
            
     
            
//            client?.addPushNotificationsOnChannels(["channelOfSignedIn"], withDevicePushToken: tokenID, andCompletion: { (status) -> Void in
//                if(!status.error){
//                    println("addpushnotificaitons on channel worked ")
//                }
//                else{
//                    println("add push did not work******")
//                }
//            })
            
            
            
            var channelOfSignedIn:String?{
                didSet {
                    println("This is happening after channel was set *******************")
                    client?.addPushNotificationsOnChannels(["channelOfSignedIn"], withDevicePushToken: tokenID, andCompletion: { (status) -> Void in
                        if(!status.error){
                            println("addpushnotificaitons on channel worked ")
                        }
                        else{
                            println("add push did not work******")
                        }
                    })
                    
                }
                
            }
            


            
        }
    }
    
    
    
    
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
      
        
        client = PubNub.clientWithPublishKey("pub-c-f83b8b34-5dbc-4502-ac34-5073f2382d96", andSubscribeKey: "sub-c-34be47b2-f776-11e4-b559-0619f8945a4f")
        client?.addListeners([self])

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        var navColor = UIColorFromRGB(0x3598DB)
        navigationController?.navigationBar.barTintColor = navColor

        
    }
    
    
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        self.tableView .reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        (cell as! TableViewCell).usernameLabel.text = friendsArray[indexPath.row] as String
        var color = UIColorFromRGB(colorsArray[indexPath.row])
        (cell as! TableViewCell).backgroundColor = color

        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        var name = friendsArray[indexPath.row] as String

        var payload = ["apns":["alert":name, "badge":"1","sound":"default"]]
        client?.publish("test", toChannel: friendsArray[indexPath.row] as String, mobilePushPayload: payload, withCompletion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
    }
    
    
    
    
    
    
    
    @IBAction func AddButtonTapped(sender: AnyObject) {
        var inputTextField: UITextField?
        
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Add Friend", message: "Enter Friend's Username", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some stuff
            self.tableView .reloadData()

        }
        actionSheetController.addAction(cancelAction)
        //Create and an option action
        let nextAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            //Do some other stuff
            
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
                newRelation["Sender"] = currentUser?.username
                newRelation["Friend"] = inputTextField!.text
                newRelation.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        self.tableView .reloadData()
                    } else {
                        // There was a problem, check error.description
                    }
                }
                self.tableView .reloadData()

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















