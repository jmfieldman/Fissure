//
//  Target.m
//  Fissure
//
//  Created by Jason Fieldman on 4/21/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import "Target.h"
#import "FissureScene.h"

#define CHECK_VALUE(_v) if (!dictionary[_v]) { EXLog(MODEL, WARN, @"Target dictionary missing parameter %@", _v ); }

#define TARGET_RADIUS 20
#define DIALS_PER_TARGET 7
#define NUM_DIAL_IMAGES  7


@implementation Target

- (id) initWithDictionary:(NSDictionary*)dictionary forSceneSize:(CGSize)sceneSize {
	if ((self = [super init])) {
		
		float offset = (sceneSize.width > 481) ? 44 : 0;
		sceneSize.width = 480;
		
		_position        = CGPointMake( [dictionary[@"px"] floatValue] * sceneSize.width + offset, [dictionary[@"py"] floatValue] * sceneSize.height );
		_matchedFissure  = [dictionary[@"matchedFissure"] intValue];
		
		CHECK_VALUE(@"px");
		CHECK_VALUE(@"py");
		
		/* Initial values */
		_progress        = 0;
		_hysteresis      = 1;
		_progressPerHit  = 0.5;
		_lastHitTime     = 0;
		_lossPerTime     = 0.6;
		
		/* Create dials array */
		_dials = [NSMutableArray array];
		
		/* Create the node for this control */
		_node = [SKNode node];
		_node.position = _position;
		_node.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"isTarget":@(YES), @"target":self}];
		
		_node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:TARGET_RADIUS];
		_node.physicsBody.dynamic = YES;
		_node.physicsBody.categoryBitMask = PHYS_CAT_TARGET;
		_node.physicsBody.collisionBitMask = 0;
		_node.physicsBody.contactTestBitMask = 0;
		_node.physicsBody.friction = 0;
		
		/* Create dials */
		static float dial_factor[DIALS_PER_TARGET] = { 1, 0.8, 1, 0.4, 1, 0.6, 1 };
		for (int i = 0; i < DIALS_PER_TARGET; i++) {
			
			SKSpriteNode *dial = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"activity_disc_%d", i]];
			dial.position = CGPointZero;
			dial.color = [UIColor blackColor];
			dial.colorBlendFactor = 1;
			dial.alpha = 0.15;
			dial.size = CGSizeMake(TARGET_RADIUS*2 * dial_factor[i], TARGET_RADIUS*2 * dial_factor[i]);
			dial.zRotation = rand()%1000/1000.0 * 2 * M_PI;

			dial.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:TARGET_RADIUS];
			dial.physicsBody.dynamic = YES;
			dial.physicsBody.categoryBitMask = 0;
			dial.physicsBody.collisionBitMask = 0;
			dial.physicsBody.contactTestBitMask = 0;
			dial.physicsBody.angularVelocity = 0;//2 * ((i<3)?1:-1) * (float)(i+2)/DIALS_PER_TARGET;
			dial.physicsBody.affectedByGravity = NO;
			dial.physicsBody.friction = 0;
			dial.physicsBody.angularDamping = 0;
			
			[_node addChild:dial];
			[_dials addObject:dial];
		}
		
	}
	return self;
}

- (void) setColor:(UIColor *)color {
	_color = color;
	
	for (SKSpriteNode *dial in _dials) {
		dial.color = color;
		dial.alpha = 0.4;
	}
}

- (void) hitByProjectile {
	_accelToTime = _currentTime + 0.1;
}

- (void) updateForDuration:(CFTimeInterval)duration {
	_currentTime += duration;
	
	/* Was hit? */
	if (_currentTime < _accelToTime) {
		_lastHitTime = _currentTime;
		
		/* Don't do anything if already at 1 */
		if (_progress < 1) {
			_progress += _progressPerHit * duration;
			if (_progress > 1) _progress = 1;
		}
	}
	
	/* Full? */
	if (_progress >= 1) {
		_timeFull += duration;
	} else {
		_timeFull = 0;
	}
	
	/* If already resting, no need to update */
	if (_progress <= 0) return;
	
	CFTimeInterval sinceLastHit = _currentTime - _lastHitTime;
	if (sinceLastHit > _hysteresis) {
		_progress -= (duration * _lossPerTime);
	}
	
	[self updateDialSpeed];
}


- (void) controlMoved {
	/* Moving control resets timers on all targets */
	_timeFull = 0;
}

- (void) updateDialSpeed {
	int i = 0;
	for (SKSpriteNode *dial in _dials) {
		dial.physicsBody.angularVelocity = 4 * ((i<3)?1:-1) * (float)(i+2)/DIALS_PER_TARGET * _progress;
		i++;
	}
}


@end
