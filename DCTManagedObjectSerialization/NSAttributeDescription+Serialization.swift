
import Foundation
import CoreData

extension NSAttributeDescription {

	- (Class)dct_deserializationClassWithDeserializer:(id<DCTManagedObjectDeserializing>)deserializer {

	// For transformable attributes, have no good idea what the source class is.
	// Assume that the transformer will reject anything unsuitable, so allow basically anything

	BOOL classUnknown = (self.attributeType == NSTransformableAttributeType || [deserializer transformerNamesForProperty:self].count);
	return classUnknown ? [NSObject class] : NSClassFromString([self attributeValueClassName]);
	}

	- (id)dct_valueForSerializedValue:(id)value withDeserializer:(id <DCTManagedObjectDeserializing>)deserializer {

	id transformedValue = [super dct_valueForSerializedValue:value withDeserializer:deserializer];

	if (self.attributeType == NSTransformableAttributeType)
	return transformedValue;

	Class attributeClass = NSClassFromString(self.attributeValueClassName);

	if ([transformedValue isKindOfClass:attributeClass])
	return transformedValue;

	if ([value isKindOfClass:attributeClass])
	return value;

	return nil;
	}

}
