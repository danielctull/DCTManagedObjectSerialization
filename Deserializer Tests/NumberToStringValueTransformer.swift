
import Foundation

class NumberToStringValueTransformer: NSValueTransformer {

	override class func transformedValueClass() -> AnyClass {
		return NSString.self
	}

	override class func allowsReverseTransformation() -> Bool {
		return false
	}

	override func transformedValue(value: AnyObject?) -> AnyObject? {

		guard let value = value as? NSNumber else {
			return nil
		}

		return value.description
	}
}
