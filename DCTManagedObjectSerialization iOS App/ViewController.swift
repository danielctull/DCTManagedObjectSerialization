
import UIKit
import Tweets

class ViewController: UIViewController {

	@IBOutlet var indicator: UIActivityIndicatorView!

	@IBAction func importTweets(sender: UIButton) {

		sender.enabled = false
		indicator.startAnimating()

		Tweets.importTweets { tweets in

			dispatch_async(dispatch_get_main_queue()) {
				self.indicator.stopAnimating()
				sender.enabled = true
			}
		}
	}
}
