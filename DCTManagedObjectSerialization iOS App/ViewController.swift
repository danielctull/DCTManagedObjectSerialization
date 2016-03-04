
import UIKit
import Tweets

class ViewController: UIViewController {

	@IBOutlet var indicator: UIActivityIndicatorView!

	@IBAction func importTweets(sender: UIButton) {

		sender.enabled = false
		indicator.startAnimating()
		let start = NSDate()

		Tweets.importTweets { tweets in

			dispatch_async(dispatch_get_main_queue()) {
				self.indicator.stopAnimating()
				sender.enabled = true
				print(NSDate().timeIntervalSinceDate(start), "imported", tweets.count, "tweets")
			}
		}
	}
}
