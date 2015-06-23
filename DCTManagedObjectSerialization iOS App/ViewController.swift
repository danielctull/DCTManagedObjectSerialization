
import UIKit
import Tweets

class ViewController: UIViewController {
	
	@IBAction func importTweets(sender: AnyObject) {
		Tweets.importTweets { tweets in }
	}
}

