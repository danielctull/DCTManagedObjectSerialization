
import Cocoa
import Tweets

class ViewController: NSViewController {

	@IBAction func importTweets(sender: AnyObject) {
		Tweets.importTweets { tweets in	}
	}
}
