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

- (int) levelNumForId:(NSString*)levelId {
	int levelIndex = 0;
	for (NSString *Id in _levelOrder) {
		if ([levelId isEqualToString:Id]) return levelIndex;
		levelIndex++;
	}
	return -1;
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


- (NSString*) currentLevelId {
	PersistentDictionary *comp = [PersistentDictionary dictionaryWithName:@"current_level"];
	if (!comp.dictionary[@"currentId"]) {
		return @"intro-1";
	}
	return comp.dictionary[@"currentId"];
}

- (void) setCurrentLevelId:(NSString *)currentLevelId {
	PersistentDictionary *comp = [PersistentDictionary dictionaryWithName:@"current_level"];
	comp.dictionary[@"currentId"] = currentLevelId;
	[comp saveToFile];
}


@end
