//
//  SpawnPoint.m
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import "SpawnPoint.h"

#define CHECK_VALUE(_v) if (!dictionary[_v]) { EXLog(MODEL, WARN, @"Spawnpoint dictionary missing parameter %@", _v ); }

@implementation SpawnPoint

- (id) initWithDictionary:(NSDictionary*)dictionary forSceneSize:(CGSize)sceneSize {
	if ((self = [super init])) {
		
		_position        = CGPointMake( [dictionary[@"px"] floatValue] * sceneSize.width, [dictionary[@"py"] floatValue] * sceneSize.height );
		_positionJitter  = CGSizeMake(  [dictionary[@"jx"] floatValue] * sceneSize.width, [dictionary[@"jy"] floatValue] * sceneSize.height );
		_friction        = [dictionary[@"friction"] floatValue];
		_frameInterval   = [dictionary[@"frameInterval"] intValue];
		
		float angle = [dictionary[@"angle"] floatValue];
		float speed = [dictionary[@"speed"] floatValue] * sceneSize.width;
		_initialVelocity = CGVectorMake( cos(angle) * speed , sin(angle) * speed );
		
		CHECK_VALUE(@"px");
		CHECK_VALUE(@"py");
		CHECK_VALUE(@"jx");
		CHECK_VALUE(@"jy");
		CHECK_VALUE(@"angle");
		CHECK_VALUE(@"speed");
		CHECK_VALUE(@"friction");
		CHECK_VALUE(@"frameInterval");
		
		_frameCount = 1;
	}
	return self;
}


- (BOOL) shouldSpawnThisFrame {
	_frameCount++;
	if (_frameCount > _frameInterval) {
		_frameCount = 1;
		return YES;
	}
	return NO;
}

@end
