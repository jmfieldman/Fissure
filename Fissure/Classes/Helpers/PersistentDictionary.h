//
//  PersistentDictionary.h
//  

#import <Foundation/Foundation.h>


@interface PersistentDictionary : NSObject {

}

@property (strong, nonatomic, readonly) NSString   *fileName;
@property (strong, nonatomic, readonly) NSString   *filePath;
@property (strong, nonatomic, readonly) NSString   *md5Path;
@property (strong, nonatomic, readonly) NSMutableDictionary *dictionary;

+ (PersistentDictionary*) dictionaryWithName:(NSString*)name;
+ (void) saveAllDictionaries;
+ (void) clearDictionaryMemCache;
+ (void) clearDictionaryDiskCache;

- (id) initWithFileName:(NSString*)name;
- (void) saveToFile;

@end


