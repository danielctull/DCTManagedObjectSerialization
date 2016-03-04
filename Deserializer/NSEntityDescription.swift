
import CoreData

extension NSEntityDescription {

	func predicateForUniqueObject(serializedDictionary serializedDictionary: SerializedDictionary, serializationInfo: SerializationInfo) -> NSPredicate? {

		let uniqueAttributes = serializationInfo.uniqueAttributes[self]
		var predicates: [NSPredicate] = []

		for attribute in uniqueAttributes {

			let value = attribute.value(serializedDictionary: serializedDictionary, serializationInfo: serializationInfo)
			let predicate: NSPredicate

			switch value {
				case .Nil: predicate = NSPredicate(format: "%K == nil", argumentArray: [attribute.name])
				case .None: continue
				case .One(let object): predicate = NSPredicate(format: "%K == %@", argumentArray: [attribute.name, object])
				case .Some(let object): predicate = NSPredicate(format: "%K == %@", argumentArray: [attribute.name, object])
			}

			predicates.append(predicate)
		}

		guard predicates.count > 0 else {
			return nil
		}

		return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
	}
}
