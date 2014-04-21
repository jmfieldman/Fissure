//
//  SpawnPoint.m
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import "SpawnPoint.h"

#define CHECK_VALUE(_v) if (!dictionary[_v]) { EXLog(MODEL, WARN, @"Dictionary missing parameter %@", _v ); }

@implementation SpawnPoint

- (id) initWithDictionary:(NSDictionary*)dictionary forSceneSize:(CGSize)sceneSize {
	if ((self = [super init])) {
		
		_position        = CGPointMake( [dictionary[@"px"] floatValue] * sceneSize.width, [dictionary[@"py"] floatValue] * sceneSize.height );
		_positionJitter  = CGSizeMake(  [dictionary[@"jx"] floatValue] * sceneSize.width, [dictionary[@"jy"] floatValue] * sceneSize.height );
		_initialVelocity = CGVectorMake([dictionary[@"vx"] floatValue] * sceneSize.width, [dictionary[@"vy"] floatValue] * sceneSize.height );
		_friction        = [dictionary[@"friction"] floatValue];
		
		CHECK_VALUE(@"px");
		CHECK_VALUE(@"py");
		CHECK_VALUE(@"jx");
		CHECK_VALUE(@"jy");
		CHECK_VALUE(@"vx");
		CHECK_VALUE(@"vy");
		CHECK_VALUE(@"friction");
		
	}
	return self;
}

@end
