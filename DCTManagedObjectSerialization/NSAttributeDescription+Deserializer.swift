
import CoreData

enum AttributeValue: CustomStringConvertible {
	case One(AnyObject)
	case Nil
	case None

	var description: String {

		switch self {

		case let .One(object):
			return "AttributeValue.One(\(object))"

		case .Nil:
			return "AttributeValue.Nil"

		case .None:
			return "AttributeValue.None"
		}
	}
}

extension NSAttributeDescription {

	func valueForSerializedDictionary(serializedDictionary: SerializedDictionary, serializationInfo: SerializationInfo) -> AttributeValue {

		let serializationName = serializationInfo.serializationName[self]
		guard let serializedValue = serializedDictionary[serializationName] else {
			return .None
		}

		if serializedValue as? NSNull != nil {
			return .Nil
		}

		var transformedValue: AnyObject? = serializedValue
		let transformers = serializationInfo.transformers[self]
		for transformer in transformers {
			transformedValue = transformer.transformedValue(transformedValue)
		}

		guard let value = transformedValue else {
			return .None
		}

		let predicate = NSCompoundPredicate.andPredicateWithSubpredicates(validationPredicates)
		guard predicate.evaluateWithObject(value) else {
			return .None
		}

		return .One(value)
	}
}
