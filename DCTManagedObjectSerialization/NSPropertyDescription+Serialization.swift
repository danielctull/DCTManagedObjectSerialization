
import Foundation
import CoreData

extension NSPropertyDescription {

	func serializationName() -> String {

		let key = Properties.serializationName.rawValue
		if let serializationName = userInfo[key] as? String {
			return serializationName
		}

		return name
	}

	func value


	





}



extension PropertyInfo where dynamicType : NSPropertyDescription {


	func serializationName -> String {

		if let key = userInfo[Properties.serializationName.rawValue as NSObject] as? String {
			return key
		}

		return name
	}

}




@implementation NSPropertyDescription (PTKMapper)

- (NSString *)ptk_serverKey {
	NSString *serverKey = self.userInfo[PTKManagedObjectMapperUserInfoKeys.serverKey];
	if (serverKey.length > 0) {
		return serverKey;
	}

	return self.name;
	}

	- (id)ptk_valueInJSON:(NSDictionary *)JSON mapper:(PTKManagedObjectMapper *)mapper {
		return nil;
}

@end

