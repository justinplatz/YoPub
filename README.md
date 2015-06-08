# Build A DIY Amazon Dash Button With PubNub & Arduino

"...the IoT enables a myriad of applications ranging from the micro to the macro, and from the trivial to the critical" - Brendan O'Brien

The IoT has birthed many great modern innovations ranging from Nest thermostats to Hue lights. The driving factor of IoT innovation is that "smarter" things give us the ability to utilize information in more meaningful and appropriate ways. Perhaps creating a "smarter" and safer planet, and improving humankind simultaneously.

And then Amazon introduced the Dash Button, which serves just a single purpose: to automate your internet shopping with just the push of a button. The intention is that Amazon wants to automate your shopping using the “Internet of Things” and the Dash Button is just a first step. To some button seems laughable. Really, how many consumers who shop with Amazon are so consumed by Kraft Macaroni and Cheese mmmmmm the cheesiest that they want a button in their house announcing their marriage to a specific product?

Perhaps the biggest flaw of the Dash Button, is that each button has one pre-programmed item that it can order i.e. your Gatorade button can only order Gatorade. 

In this tutorial I will show you how you can make a ***Flash Button*** which is fully customizable, and dare I say superior to its Amazon-produced counterpart, by utilizing the PubNub Arduino & JavaScript SDKs. 


<iframe src="https://vine.co/v/eMmr577XuEg/embed/simple?audio=1" width="600" height="600" frameborder="0"></iframe><script src="https://platform.vine.co/static/scripts/embed.js"></script>

## Overview
To make the Flash Button we will be using:

* **Arduino Yun** as the brains for our button
* **PubNub** to allow us to easily communicate with our webpage and help us to confirm our purchases
* **Zinc API** to handle the automated purchasing from Amazon

![image](/Users/nyjetsjustin/Documents/PubNub/proccess.png)

You push the button connected to your Arduino -> Arduino Publishes to PubNub -> Your computer Subscribes to PubNub and receives message -> You confirm purchase, Order script uses Zinc and order is placed with Amazon -> Amazon sends you stuff -> You do things, and need more stuff -> You push the button -> etc -> etc 

I will show you step-by-step how to use PubNub & Arduino to order from Amazon, however you can customize your button to do **just about anything**.

###Programming Your Arduino

My current setup consists of:

* 1 Arduino Yun
* 1 Giant Red Push Button (other variations will suffice)
* 1 LED light (not necessary)
* 1 10K resistor (not necessary)
* 6 male to male cables

So if you want to follow my lead exactly go ahead and grab these pieces now. I use an LED light simply for show, it serves no true purpose in the ordering process. Additionally, there is more than one way to skin a cat, so please feel free improvise and improve my project however you choose.

Firstly, lets plug everything in like so:
 
 * LED attached from pin 13 to ground
 * Push Button attached to pin 2 from +5V
 * 10K resistor attached to pin 2 from ground

The Push Button I use has only two legs. The ones with four legs will of course serve the same purpose but may need to be placed on the breadboard somewhat differently. Also, I only use the LED because I like the visual confirmation of my button being pushed. The LED serves no other real purpose in this project.

![image](/Users/nyjetsjustin/Documents/PubNub/breadboard.jpg)

Ok, so now that we are all connected lets go ahead and open a new Sketch.

Above our setup lets add some includes and constants like so:
	
	#include <Bridge.h>
	#include <HttpClient.h>


	// constants won't change. They're used here to
	// set pin numbers:
	const int buttonPin = 2;     // the number of the pushbutton pin
	const int ledPin =  13;      // the number of the LED pin

	// variables will change:
	int buttonState = 0;         // variable for reading the pushbutton status
	
Now in setup we want to initialize the LED as an output, the button. We then add Bridge.begin(), which is a blocking function, nothing else will happen in your sketch until your bridge starts facilitating communication between the AVR and Linux processor. This should be called once in setup(). Next, Serial.begin() sets the data rate in bits per second for serial data transmission. In this case we will choose 9600. Lastly, we add while(!Serial), because we only want to move on if the serial connection is open. My complete setup looks like this:

	void setup() {
  		// initialize the LED pin as an output:
  		pinMode(ledPin, OUTPUT);
  		// initialize the pushbutton pin as an input:
  		pinMode(buttonPin, INPUT);
  
  		Bridge.begin();
  		Serial.begin(9600);
  		while(!Serial);
	}
	
Now, we need to construct the loop part of our sketch. We want to do something when there is a button press obviously. Specifically, when the button gets pressed  we want to send a secret password to our PubNub channel as well as light up the LED for as a nice aesthetic confirmation. Here is how my loop looks:

	void loop() {
	
		//initialize  a basic HTTP client that connects to the internet
  		HttpClient client;
  		
  		// read the state of the pushbutton value:
  		buttonState = digitalRead(buttonPin);

  		// check if the pushbutton is pressed.
  		// if it is, the buttonState is HIGH:
  		if (buttonState == HIGH) {
    		
    		// turn LED on:
    		digitalWrite(ledPin, HIGH);
    		
    		//Fill in your keys and publish to PubNub
    		client.get("http://pubsub.pubnub.com
			/publish
			/pub-key
			/sub-key
			/signature
			/channel
			/callback
			/message");
			
			//As long as there are bytes from the server in the client buffer, read the bytes and print them to the serial monitor.
    		while (client.available()) {
        		char c = client.read();
        		Serial.print(c);
    		}
    		Serial.print('\n');
    		Serial.flush();
  		}
  		//But if there is no button being pressed
  		else {
    		// turn LED off:
    		digitalWrite(ledPin, LOW);
  		}
  		//repeat every 5 seconds
  		delay(5000);
	}
		
		
Lets look further at the client.get() line. What I am doing is essentially publishing to PubNub by doing a HTTP get request. 

For more information on this check out: 
<http://www.pubnub.com/http-rest-push-api/> and also <http://www.arduino.cc/en/Tutorial/HttpClient>

You should go to your dev console, put in the same pub_key,sub_key and channel you entered into your sketch and check that the button press is in fact publishing to PubNub. If it is then the hard part is done! 

My final sketch looks like this, you should not I am posting to Sub_key:demo, Pub_key:demo, Channel: hi_world and the message I am sending is "abc" :

<script src="https://gist.github.com/justinplatz/19014bf7705253e8fd03.js"></script>

###Automating Amazon Ordering

####Ordering With Zinc
You may be wondering how I went about ordering from Amazon, and the answer is <http://Zinc.io> . Zinc has a super easy to use API which essentially handled all of the Amazon order process easily and seamlessly. What you need to do is check out their Github Repo at : <https://github.com/wangjohn/zinc_cli> and for instructions about installing Zinc.

Next, you will probably want to go ahead and request an API token, which is free, and took me only 1 business day to get a response back. Quick & easy, Zinc is perfect for this project. While you are waiting there is an also free demo token you can use. 

Once you have Zinc installed, and have a API token the next thing you'll want to do is set up your order request. Open your favorite text editor and fill in the blanks and then save this as a JSON object into your project folder:

<script src="https://gist.github.com/justinplatz/b59ded9fd7e4202f9c66.js"></script>

Fill the JSON file out just one time and you won't need to open it again so long as you don't need to alter any of the information. 

Finding the Product ID of your product is different depending on what country you are in, so you may want to google how to find it in your country.

In the repo they show you how to order from the command line:
	
	($python -m zinc -s -f examples/simple_order.json)
You should try that now just to make sure your JSON file is properly filled out. If it is, then when you execute this line you should soon see an email confirmation of your purchase within a few minutes. Do not move on to the next step until you have done this at least once. Don't worry its very easy to cancel a purchase if it works (I did it about 10x during testing).

####Creating Our Webpage

In my project I created a static webpage which is subscribed to the same PubNub channel as my Arduino is publishing to. My page asks me if I really did intend to click the button, if I click yes then I use a PHP file to check that the message received contained my secret password, and if all goes well then I run a process called Order.php which uses Zinc to place the order.

First, Ill show you how I set up my Order.php file: 

<script src="https://gist.github.com/justinplatz/3f04e0f4f24d3de983fd.js"></script>

The first thing I do is check that the message I received from the channel is equal to my secret password, in this case "abc". The reason I do this is so that other people cannot order me things on Amazon without knowing my password, and since I do this check in my PHP file it will not appear to anyone viewing the site.  

As this is a PHP file you will need a server to test. I use MAMP for this. If you go to your local host and run Order.php?p=Your_Password then it should actually process the order... check for your receipt and confirm. 

In my variation of the Flash Button, I created a static webpage which is waiting to receive the published message from the Arduino and then presents me with an option to confirm or reject the order. However, to emulate the Dash button even further one could use Twilio to send a text message with the confirmation/rejection or even make a native app for this. 

Let me show you the key components you'll need for your webpage.

First, connecting to PubNub is super easy with JavaScript. All you do is add this to your body: 
  
  	<script src="http://cdn.pubnub.com/pubnub-3.7.1.min.js"></script>
  	
 And then create a script and add this:
 
   	var pubnub = PUBNUB.init({
      publish_key: 'demo',
      subscribe_key: 'demo'
    });

Just like that you are connected to PubNub! But we want to add a little more logic to our page, so what I did was upon receiving a message from PubNub:
	
	* Hide h1 header
	* Show Alert box

Then my Alert box has Yes and No Buttons each run a different script upon being selected.

Heres what my page looks like after I stripped away all unnecessary styling elements:

<script src="https://gist.github.com/justinplatz/f487d962dd50b9f0682e.js"></script>

Thats it! You should be able to Press your button, see a confirmation box appear on your webpage and be able to order from amazon with just one button press. Its ok to be excited. Binge shopping has literally never been so easy. What is particularly good to note is that you can very easily change the item your button is set to order by simply changing the product_Id in the JSON object. My Github Repo (<https://github.com/justinplatz/FlashButton>) will have all of my styling for you to access. 

If you have any questions or comments I would love to hear them! Please email me at: justin@pubnub.com 
