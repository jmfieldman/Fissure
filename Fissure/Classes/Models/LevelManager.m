//
//  LevelManager.m
//  Fissure
//
//  Created by Jason Fieldman on 4/28/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import "LevelManager.h"

@implementation LevelManager

SINGLETON_IMPL(LevelManager);

- (id) init {
	if ((self = [super init])) {
		
		PersistentDictionary *source = [PersistentDictionary dictionaryWithName:@"level_info"];
		_sourceDictionary = source.dictionary;
		
		_levelDictionary = _sourceDictionary[@"levels"];
		_levelOrder      = _sourceDictionary[@"level_order"];
		
	}
	return self;
}


- (NSString*) levelIdAtPosition:(int)position {
	return _levelOrder[position];
}

- (int) levelCount {
	return [_levelOrder count];
}

- (NSDictionary*) levelDictionaryForId:(NSString*)levelId {
	return _levelDictionary[levelId];
}



- (BOOL) isAvailable:(NSString*)levelId {
	PersistentDictionary *avail = [PersistentDictionary dictionaryWithName:@"levels_avail"];
	return [avail.dictionary[levelId] boolValue];
}

- (void) setAvailable:(NSString*)levelId {
	PersistentDictionary *avail = [PersistentDictionary dictionaryWithName:@"levels_avail"];
	avail.dictionary[levelId] = @(YES);
	[avail saveToFile];
}

- (BOOL) isComplete:(NSString*)levelId {
	PersistentDictionary *comp = [PersistentDictionary dictionaryWithName:@"levels_complete"];
	return [comp.dictionary[levelId] boolValue];
}

- (void) setComplete:(NSString*)levelId {
	PersistentDictionary *comp = [PersistentDictionary dictionaryWithName:@"levels_complete"];
	comp.dictionary[levelId] = @(YES);
	[comp saveToFile];
}



@end
