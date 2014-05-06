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

#define WARP_NODE_RADIUS_UNIT 28.4

static NSString *s_controlStrings[NUM_CONTROL_TYPES] = {
	@"push",
	@"gravity",
	@"repel",
	@"propel",
	@"slow",
	@"warp",
	@"shape",
};



@implementation SceneControl

- (id) initWithDictionary:(NSDictionary*)dictionary forSceneSize:(CGSize)sceneSize {
	if ((self = [super init])) {
		
		float offset = (sceneSize.width > 481) ? 44 : 0;
		sceneSize.width = 480;
		
		_controlType     = [self controlTypeForString:dictionary[@"type"]];
		_angle           = [dictionary[@"angle"] floatValue];
		_position        = CGPointMake( [dictionary[@"px"] floatValue] * sceneSize.width + offset, [dictionary[@"py"] floatValue] * sceneSize.height );
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
		_initialPosition = _position;
		
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
				_node.color = [UIColor colorWithRed:1 green:0.5 blue:0 alpha:1];
				break;
				
			case CONTROL_TYPE_REPEL:
				_icon = [SKSpriteNode spriteNodeWithImageNamed:@"disc_repel"];
				_icon.zRotation = M_PI / 2;
				_node.color = [UIColor colorWithRed:1 green:0.4 blue:1 alpha:1];
				break;
				
			case CONTROL_TYPE_WARP: {
				//[_node setScale:(_radius / WARP_NODE_RADIUS_UNIT)];
				_node.color = [UIColor clearColor];
				SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"warp" ofType:@"sks"]];
				emitter.particleScale *= (_radius / WARP_NODE_RADIUS_UNIT);
				emitter.particleScaleSpeed *= (_radius / WARP_NODE_RADIUS_UNIT);
				emitter.particleSpeedRange *= (_radius / WARP_NODE_RADIUS_UNIT);
				[_node addChild:emitter];
			} break;
				
			case CONTROL_TYPE_SHAPE: {
				
				_node.alpha = 0.0;
				
				_shape = [SKShapeNode node];
				NSArray *points = dictionary[@"points"];
				if (!points) {
					_shape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-_radius, -_radius, _radius*2, _radius*2)].CGPath;
					_shape.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_radius];
				} else {
					BOOL first = YES;
					UIBezierPath *path = [UIBezierPath bezierPath];
					for (NSDictionary *point in points) {
						float angle  = [point[@"angle"] floatValue];
						float radius = [point[@"radius"] floatValue];
						float px = cos(angle) * radius * _radius;
						float py = sin(angle) * radius * _radius;
						if (first) {
							[path moveToPoint:CGPointMake(px, py)];
							first = NO;
						} else {
							[path addLineToPoint:CGPointMake(px, py)];
						}
					}
					[path closePath];
					_shape.path = path.CGPath;
					_shape.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path.CGPath];
				}
				
				_shape.zRotation = _angle;
				_shape.antialiased = YES;
				_shape.fillColor = [UIColor colorWithWhite:0.5 alpha:0.3];
				_shape.strokeColor = [UIColor colorWithWhite:0.5 alpha:0.7];
				_shape.lineWidth = 1;
				_shape.position = _position;
				
				_shape.physicsBody.friction = 0;
				_shape.physicsBody.dynamic = YES;
				_shape.physicsBody.categoryBitMask    = PHYS_CAT_CONTROL_COLL;
				_shape.physicsBody.collisionBitMask   = 0;
				_shape.physicsBody.contactTestBitMask = 0;
				
				_node.physicsBody.categoryBitMask    = 0;
				_node.physicsBody.collisionBitMask   = 0;
				_node.physicsBody.contactTestBitMask = 0;
				
			} break;
				
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
	_shape.position = position;
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
			float drag  = 1 - (0.5) * duration;
			NSMutableArray *toRemove = [NSMutableArray array];
			for (SKNode *node in _affectedProjectiles) {
				if (!node.parent) [toRemove addObject:node];
				
				float dx = _node.position.x - node.position.x;
				float dy = _node.position.y - node.position.y;
				int distance = FastIntSQRT((int)(dx * dx + dy * dy));
				distance += _radius / 2;
				
				float force = multiplier * 50000 / (distance * distance);
				
				node.physicsBody.velocity = CGVectorMake((node.physicsBody.velocity.dx + dx * force) * drag, (node.physicsBody.velocity.dy + dy * force) * drag);
				node.zRotation = atan2(node.physicsBody.velocity.dy, node.physicsBody.velocity.dx);
				
				float vx = fabs(node.physicsBody.velocity.dx);
				float vy = fabs(node.physicsBody.velocity.dy);
				
				if (vx < 3 && vy < 3) {
					[toRemove addObject:node];
				} else if (fabs(dx) < 6 && fabs(dy) < 6 && vx < 40 && vy < 40) {
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
			
		case CONTROL_TYPE_REPEL: {
			float multiplier = _power * duration;
			for (SKNode *node in _affectedProjectiles) {
				
				float dx = node.position.x - _node.position.x;
				float dy = node.position.y - _node.position.y;
				int distance = FastIntSQRT((int)(dx * dx + dy * dy));
				distance += _radius / 4;
				
				float force = multiplier * 50000 / (distance * distance);
				
				node.physicsBody.velocity = CGVectorMake((node.physicsBody.velocity.dx + dx * force), (node.physicsBody.velocity.dy + dy * force));
				node.zRotation = atan2(node.physicsBody.velocity.dy, node.physicsBody.velocity.dx);
				
				
			}
			break;
		}
			
		case CONTROL_TYPE_WARP: {
			
			//NSMutableArray *toRemove = [NSMutableArray array];
			for (SKNode *node in _affectedProjectiles) {
				
				if (node.userData[@"warped"]) {
					[node.userData removeObjectForKey:@"warped"];
					continue;
				}
				
				float dx = node.position.x - self.position.x;
				float dy = node.position.y - self.position.y;
				node.userData[@"warped"] = @YES;
				node.position = CGPointMake(self.connectedWarp.position.x + dx, self.connectedWarp.position.y + dy);
								
				[self.scene removeNodeFromAllControlsNotInRange:node];
			}
			
			[_affectedProjectiles removeAllObjects];
			//for (SKNode *node in toRemove) {
			//	[_affectedProjectiles removeObjectIdenticalTo:node];
			//}
			
			break;
		}
		
			
		default:
			break;
	}
}

@end

