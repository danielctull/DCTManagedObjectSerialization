
import Foundation
import CoreData

extension NSPropertyDescription {


}
//
//- (id)dct_valueForSerializedValue:(id)value withDeserializer:(id <DCTManagedObjectDeserializing>)deserializer {
//
//	__block id transformedValue = value;
//
//	NSArray *transformerNames = [deserializer transformerNamesForProperty:self];
//	[transformerNames enumerateObjectsUsingBlock:^(NSString *transformerName, NSUInteger i, BOOL *stop) {
//		NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:transformerName];
//		transformedValue = [transformer transformedValue:transformedValue];
//		}];
//
//	return transformedValue;
//}