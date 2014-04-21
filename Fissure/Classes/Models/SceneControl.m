//
//  SceneControl.m
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import "SceneControl.h"

#define CHECK_VALUE(_v) if (!dictionary[_v]) { EXLog(MODEL, WARN, @"Control dictionary missing parameter %@", _v ); }

static NSString *s_controlStrings[NUM_CONTROL_TYPES] = {
	@"push",
	@"gravity",
	@"propel",
	@"slow",
};

@implementation SceneControl

- (id) initWithDictionary:(NSDictionary*)dictionary forSceneSize:(CGSize)sceneSize {
	if ((self = [super init])) {
		
		_controlType     = [self controlTypeForString:dictionary[@"type"]];
		_angle           = [dictionary[@"angle"] floatValue];
		_position        = CGPointMake( [dictionary[@"px"] floatValue] * sceneSize.width, [dictionary[@"py"] floatValue] * sceneSize.height );
		_radius          = [dictionary[@"radius"] floatValue];
		_minRadius       = [dictionary[@"minRadius"] floatValue];
		_maxRadius       = [dictionary[@"maxRadius"] floatValue];
		_canRotate       = [dictionary[@"canRotate"] boolValue];
		_canScale        = [dictionary[@"canScale"] boolValue];
		
		CHECK_VALUE(@"px");
		CHECK_VALUE(@"py");
		CHECK_VALUE(@"type");
		CHECK_VALUE(@"angle");
		CHECK_VALUE(@"radius");
		CHECK_VALUE(@"maxRadius");
		CHECK_VALUE(@"minRadius");
		CHECK_VALUE(@"canRotate");
		CHECK_VALUE(@"canScale");
		
	}
	return self;
}

- (ControlType_t) controlTypeForString:(NSString*)cString {
	for (int i = 0; i < NUM_CONTROL_TYPES; i++) {
		if ([cString isEqualToString:s_controlStrings[i]]) return i;
	}
	EXLog(MODEL, WARN, @"Invalid control type: %@", cString);
	return CONTROL_TYPE_PUSH;
}


@end

