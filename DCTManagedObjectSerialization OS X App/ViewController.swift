
import Cocoa
import Tweets

class ViewController: NSViewController {

	@IBOutlet weak var indicator: UIActivityIndicatorView!
	@IBAction func importTweets(sender: AnyObject) {
		Tweets.importTweets { tweets in	}
	}
}
