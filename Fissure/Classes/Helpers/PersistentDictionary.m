//
//  PersistentDictionary.m
//  

#import "PersistentDictionary.h"

#define USE_DEFAULT_DICTIONARIES 1

static __strong NSMutableDictionary *s_dictionaryDictionary = nil;

@implementation PersistentDictionary

+ (NSString*) coffee {
	return [NSString stringWithFormat:@"%@_!@#$", [@"hotcoffee.jpg" md5]];
}

+ (NSString*) caffinate:(NSString*)str {
	NSString *pre = [[NSString stringWithFormat:@"%@%@%@", str, [PersistentDictionary coffee], [UIDevice currentDevice].identifierForVendor] md5];
	NSString *pst = [[NSString stringWithFormat:@"%@%@", [PersistentDictionary coffee], str] md5];
	return [NSString stringWithFormat:@"%@%@", [pre substringToIndex:16], [pst substringFromIndex:16] ];
}


+ (PersistentDictionary*) dictionaryWithName:(NSString*)name {
	if (!s_dictionaryDictionary) {
		s_dictionaryDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];		
	}
	
	PersistentDictionary *dic = [s_dictionaryDictionary valueForKey:name];
	if (!dic) {
		dic = [[PersistentDictionary alloc] initWithFileName:name];
		if (dic) [s_dictionaryDictionary setValue:dic forKey:name];
	}
	return dic;
}



+ (void) saveAllDictionaries {
	if (!s_dictionaryDictionary) return;
	NSArray *dictionaries = [s_dictionaryDictionary allValues];
	for (int i = 0; i < [dictionaries count]; i++) {
		PersistentDictionary *dic = [dictionaries objectAtIndex:i];
		[dic saveToFile];
	}
}

+ (void) clearDictionaryMemCache {
	s_dictionaryDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
}


+ (void) clearDictionaryDiskCache {
	
	/* Let's create the full path to the dictionary */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [NSString stringWithFormat:@"%@/dics", [paths objectAtIndex:0]];

	if ([fileManager fileExistsAtPath:documentsDirectory]) {
		[fileManager removeItemAtPath:documentsDirectory error:nil];
	}
	
}


- (id) initWithFileName:(NSString*)name {
	if (self = [super init]) {
		_fileName = [name copy];
		
		/* Let's create the full path to the dictionary */
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [NSString stringWithFormat:@"%@/dics", [paths objectAtIndex:0]];
		[fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
		NSString *dicFilePath = [documentsDirectory stringByAppendingPathComponent:name];
		_filePath = [NSString stringWithFormat:@"%@.plist", dicFilePath];
		_md5Path  = [NSString stringWithFormat:@"%@.md5", dicFilePath];
				
		/* If the file exists, let's reconstruct the dictionary from the file */
		if ([fileManager fileExistsAtPath:_filePath]) {
			NSData *propListData = [NSData dataWithContentsOfFile:_filePath];
			if (propListData) {
				NSPropertyListFormat format;
				_dictionary = [NSPropertyListSerialization propertyListWithData:propListData options:NSPropertyListMutableContainersAndLeaves format:&format error:nil];
			}
			
			/* Check md5 hash */
			#if 0
			if (_dictionary) {
				NSString *dataString = [[NSString alloc] initWithData:propListData encoding:NSUTF8StringEncoding];
				NSString *coffee = [PersistentDictionary caffinate:dataString];
				NSString *storedCoffee = [NSString stringWithContentsOfFile:_md5Path encoding:NSUTF8StringEncoding error:nil];
				if (![coffee isEqualToString:storedCoffee]) {
					_dictionary = nil;
					NSLog(@"dictionary [%@] md5 mismatch (%@ vs %@)", _fileName, coffee, storedCoffee);
				}
			}
			#endif
		}
	
		/* Otherwise we can try defaults */
		#if USE_DEFAULT_DICTIONARIES
		if (!_dictionary) {
			NSString *defaultDicPath = [[NSBundle mainBundle] pathForResource:_fileName ofType:@"plist"];
			if ([fileManager fileExistsAtPath:defaultDicPath]) {
				NSData *propListData = [NSData dataWithContentsOfFile:defaultDicPath];
				if (propListData) {
					NSPropertyListFormat format;
					_dictionary = [NSPropertyListSerialization propertyListWithData:propListData options:NSPropertyListMutableContainersAndLeaves format:&format error:nil];
				}
			}
		}
		
		/* Try the JSON version if the plist doesn't exist */
		if (!_dictionary) {
			NSString *defaultDicPath = [[NSBundle mainBundle] pathForResource:_fileName ofType:@"json"];
			if ([fileManager fileExistsAtPath:defaultDicPath]) {
				NSData *jsonData = [NSData dataWithContentsOfFile:defaultDicPath];
				if (jsonData) {
					NSError *error;
					id val = [NSJSONSerialization JSONObjectWithData:jsonData options:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves) error:&error];
					if (error) {
						EXLog(HELPER, ERR, @"JSON deserialization error for dictionary [%@]: %@", _fileName, error);
					} else if ([val isKindOfClass:[NSDictionary class]]) {
						_dictionary = val;
					}
				}
			}
		}
		#endif
		
		/* Now create the dictionary if it's still nil */
		if (!_dictionary) {
			_dictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
		}		
	}
	return self;
}



- (void) saveToFile {
	NSString *errorStr;
	NSData *propListData = [NSPropertyListSerialization dataFromPropertyList:_dictionary format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorStr];
	if (errorStr) {
		NSLog(@"Error string: %@", errorStr);
	} else {
		[propListData writeToFile:_filePath atomically:YES];
		
		#if 0
		NSString *dataString = [[NSString alloc] initWithData:propListData encoding:NSUTF8StringEncoding];
		NSString *coffee = [PersistentDictionary caffinate:dataString];
		[coffee writeToFile:_md5Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
		#endif
	}
}



@end

