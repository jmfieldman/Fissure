//
//  LevelManager.h
//  Fissure
//
//  Created by Jason Fieldman on 4/28/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LevelManager : NSObject {
	NSDictionary *_sourceDictionary;
	
	NSDictionary *_levelDictionary;
	NSArray      *_levelOrder;
}

SINGLETON_INTR(LevelManager);

- (NSString*) levelIdAtPosition:(int)position;
- (int) levelCount;
- (NSDictionary*) levelDictionaryForId:(NSString*)levelId;

- (int) levelNumForId:(NSString*)levelId;

- (BOOL) isAvailable:(NSString*)levelId;
- (void) setAvailable:(NSString*)levelId;
- (BOOL) isComplete:(NSString*)levelId;
- (void) setComplete:(NSString*)levelId;

@end
