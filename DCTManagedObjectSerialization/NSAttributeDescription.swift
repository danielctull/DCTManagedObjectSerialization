
import CoreData

extension NSAttributeDescription {

	func value(serializedDictionary serializedDictionary: SerializedDictionary, serializationInfo: SerializationInfo) -> Value {

		let x = transformedValue(serializedDictionary: serializedDictionary, serializationInfo: serializationInfo)

		let value: AnyObject
		switch x {
			case .Nil: return .Nil
			case .None: return .None
			case .One(let v): value = v
			case .Some(let v): value = v
		}

		// If it's not valid return .None
		let validationPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: validationPredicates)
		guard validationPredicate.evaluateWithObject(value) else {
			return .None
		}

		return x
	}
}
