//
//  SceneControl.m
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import "SceneControl.h"
#import "FissureScene.h"

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
		_power           = [dictionary[@"power"] floatValue];
		_powerVector     = CGVectorMake(_power * sceneSize.width * cos(_angle), _power * sceneSize.width * sin(_angle));
		
		CHECK_VALUE(@"px");
		CHECK_VALUE(@"py");
		CHECK_VALUE(@"type");
		CHECK_VALUE(@"angle");
		CHECK_VALUE(@"radius");
		CHECK_VALUE(@"maxRadius");
		CHECK_VALUE(@"minRadius");
		CHECK_VALUE(@"canRotate");
		CHECK_VALUE(@"canScale");
		CHECK_VALUE(@"power");
		
		/* Create affected array */
		_affectedProjectiles = [NSMutableArray array];
		
		/* Create the node for this control */
		_node = [SKSpriteNode spriteNodeWithImageNamed:@"disc"];
		_node.alpha = 0.1;
		_node.color = [UIColor redColor];
		_node.colorBlendFactor = 1;
		_node.size = CGSizeMake(_radius*2, _radius*2);
		_node.position = _position;
		_node.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"isControl":@(YES), @"control":self}];
		
		_node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_radius];
		_node.physicsBody.dynamic = NO;
		_node.physicsBody.categoryBitMask = PHYS_CAT_CONTROL_TRANS;
		_node.physicsBody.collisionBitMask = 0;
		_node.physicsBody.contactTestBitMask = 0;
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


- (void) setPosition:(CGPoint)position {
	_position = position;
	
	/* Update node position */
	_node.position = position;
}

- (void) updateAffectedProjectilesForDuration:(CFTimeInterval)duration {
	switch (_controlType) {
		case CONTROL_TYPE_PUSH:
			for (SKNode *node in _affectedProjectiles) {
				node.physicsBody.velocity = CGVectorMake(node.physicsBody.velocity.dx + _powerVector.dx, node.physicsBody.velocity.dy + _powerVector.dy);;
			}
			break;
			
		default:
			break;
	}
}

@end

