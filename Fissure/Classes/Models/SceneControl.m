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
		_radius          = [dictionary[@"radius"] floatValue] * sceneSize.width;
		_minRadius       = [dictionary[@"minRadiusScale"] floatValue] * _radius;
		_maxRadius       = [dictionary[@"maxRadiusScale"] floatValue] * _radius;
		_canRotate       = [dictionary[@"canRotate"] boolValue];
		_canScale        = [dictionary[@"canScale"] boolValue];
		_canMove         = [dictionary[@"canMove"] boolValue];
		_power           = [dictionary[@"power"] floatValue];
		_powerVector     = CGVectorMake(_power * sceneSize.width * cos(_angle), _power * sceneSize.width * sin(_angle));
		
		CHECK_VALUE(@"px");
		CHECK_VALUE(@"py");
		CHECK_VALUE(@"type");
		CHECK_VALUE(@"angle");
		CHECK_VALUE(@"radius");
		CHECK_VALUE(@"maxRadiusScale");
		CHECK_VALUE(@"minRadiusScale");
		CHECK_VALUE(@"canRotate");
		CHECK_VALUE(@"canScale");
		CHECK_VALUE(@"canMove");
		CHECK_VALUE(@"power");
		
		/* Initial values */
		_initialRadius = _radius;
		
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
		_node.physicsBody.friction = 0;
		_node.physicsBody.dynamic = YES;
		_node.physicsBody.categoryBitMask = PHYS_CAT_CONTROL_TRANS;
		_node.physicsBody.collisionBitMask = 0;
		_node.physicsBody.contactTestBitMask = PHYS_CAT_PROJ;
		
		/* Create control icon */
		switch (_controlType) {
			case CONTROL_TYPE_PUSH:
				_icon = [SKSpriteNode spriteNodeWithImageNamed:@"disc_push"];
				_icon.zRotation = _angle - (M_PI/2); /* Because the icon is facing up */
				_node.color = [UIColor colorWithRed:0 green:0.4 blue:1 alpha:1];
				break;
				
			case CONTROL_TYPE_PROPEL:
				_icon = [SKSpriteNode spriteNodeWithImageNamed:@"disc_propel"];
				_node.color = [UIColor colorWithRed:0 green:1 blue:0.4 alpha:1];
				break;
			
			case CONTROL_TYPE_SLOW:
				_icon = [SKSpriteNode spriteNodeWithImageNamed:@"disc_slow"];
				_node.color = [UIColor colorWithRed:1 green:0.4 blue:0.4 alpha:1];
				break;
				
			case CONTROL_TYPE_GRAVITY:
				_icon = [SKSpriteNode spriteNodeWithImageNamed:@"disc_attract"];
				_icon.zRotation = M_PI / 2;
				_node.color = [UIColor colorWithRed:1 green:0.4 blue:1 alpha:1];
				break;
				
			default:
				break;
		}
		
		if (_icon) {
			_icon.color = [UIColor colorWithWhite:0 alpha:0.3];
			_icon.colorBlendFactor = 1;
			_icon.position = _position;
			
		}
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
	_icon.position = position;
}

- (void) setRadius:(float)radius {
	if (radius < _minRadius) radius = _minRadius;
	if (radius > _maxRadius) radius = _maxRadius;
	if (radius == _radius) return;
	
	/* Update */
	_radius = radius;
	[_node setScale:_radius / _initialRadius];
}

- (void) updateAffectedProjectilesForDuration:(CFTimeInterval)duration {
	switch (_controlType) {
		case CONTROL_TYPE_PUSH: {
			float xmag = _powerVector.dx * duration;
			float ymag = _powerVector.dy * duration;
			for (SKNode *node in _affectedProjectiles) {
				node.physicsBody.velocity = CGVectorMake(node.physicsBody.velocity.dx + xmag, node.physicsBody.velocity.dy + ymag);
				node.zRotation = atan2(node.physicsBody.velocity.dy, node.physicsBody.velocity.dx);
			}
			break;
		}
			
		case CONTROL_TYPE_PROPEL: {
			float multiplier = 1 + _power * duration;
			for (SKNode *node in _affectedProjectiles) {
				node.physicsBody.velocity = CGVectorMake(node.physicsBody.velocity.dx * multiplier, node.physicsBody.velocity.dy * multiplier);
			}
			break;
		}
			
		case CONTROL_TYPE_SLOW: {
			float multiplier = 1 - _power * duration;
			NSMutableArray *toRemove = [NSMutableArray array];
			for (SKNode *node in _affectedProjectiles) {
				node.physicsBody.velocity = CGVectorMake(node.physicsBody.velocity.dx * multiplier, node.physicsBody.velocity.dy * multiplier);
				if (fabs(node.physicsBody.velocity.dx) < 3 && fabs(node.physicsBody.velocity.dy) < 3) {
					[toRemove addObject:node];
				}
			}
			if ([toRemove count]) {
				for (SKNode *node in toRemove) {
					[_affectedProjectiles removeObjectIdenticalTo:node];
					[node removeFromParent];
				}
			}
			break;
		}
			
		case CONTROL_TYPE_GRAVITY: {
			float multiplier = _power * duration;
			NSMutableArray *toRemove = [NSMutableArray array];
			for (SKNode *node in _affectedProjectiles) {
				
				float dx = _node.position.x - node.position.x;
				float dy = _node.position.y - node.position.y;
				int distance = FastIntSQRT((int)(dx * dx + dy * dy));
				distance += _radius / 2;
				
				float force = multiplier * 50000 / (distance * distance);
				
				node.physicsBody.velocity = CGVectorMake((node.physicsBody.velocity.dx + dx * force) * 0.98, (node.physicsBody.velocity.dy + dy * force) * 0.98);
				node.zRotation = atan2(node.physicsBody.velocity.dy, node.physicsBody.velocity.dx);
				
				if (fabs(node.physicsBody.velocity.dx) < 3 && fabs(node.physicsBody.velocity.dy) < 3) {
					[toRemove addObject:node];
				} else if (fabs(dx) < 3 && fabs(dy) < 3) {
					[toRemove addObject:node];
				}
				
				
			}
			if ([toRemove count]) {
				for (SKNode *node in toRemove) {
					[_affectedProjectiles removeObjectIdenticalTo:node];
					[node removeFromParent];
				}
			}
			break;
		}
		
		default:
			break;
	}
}

@end

