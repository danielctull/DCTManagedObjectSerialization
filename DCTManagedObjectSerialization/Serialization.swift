
import Foundation

protocol Serialization {
	typealias Key: Hashable
	typealias Value
	subscript (key: Key) -> Value? { get }
}

extension Dictionary: Serialization {}

extension Serialization {

	func ah() -> AnyObject? {
		return nil
	}

}
