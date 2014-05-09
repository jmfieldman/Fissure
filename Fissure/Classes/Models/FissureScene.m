//
//  FissureScene.m
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import "FissureScene.h"

#define SCALE_RADIUS_WIDTH 20


@implementation FissureScene


-(id)initWithSize:(CGSize)size {
	if (self = [super initWithSize:size]) {
		self.backgroundColor = [SKColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
		
		/* Initialize the physics of the scene */
		self.physicsWorld.gravity = CGVectorMake(0, 0);
		self.physicsWorld.contactDelegate = self;
		
		/* Create spawn zone array */
		_spawnPoints = [NSMutableArray array];
		
		/* Create controls */
		_controls = [NSMutableArray array];
		
		/* Create targets */
		_targets = [NSMutableArray array];
		
		/* Create fissures */
		_fissures = [NSMutableArray array];
		
		/* Create static images */
		_staticImages = [NSMutableArray array];
		
		/* Initialize timing */
		_lastFrameTime = 0;
		
		/* Create boundary */
		self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectInset(self.frame, -150, -100)];
		self.physicsBody.categoryBitMask = PHYS_CAT_EDGE;
		
    }
    return self;
}

- (void) loadFromLevelDictionary:(NSDictionary*)level {
	
	CGSize screenSize = self.size;
	
	for (NSDictionary *staticDic in level[@"static"]) {
		NSString *image = staticDic[@"image"];
		SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:image];
		node.alpha = 0;
		[self addChild:node];
		node.position = CGPointMake(self.size.width/2, self.size.height/2);
		[node animateToAlpha:0.65 delay:1.5 duration:1.5];
		[_staticImages addObject:node];
	}	
	
	/* Create the projectile particle layer */
	_projectileParticleLayerNode = [SKNode node];
	_projectileParticleLayerNode.position = CGPointMake(50, 200);
	[self addChild:_projectileParticleLayerNode];
	
	_projectileLayerNode = [SKNode node];
	_projectileLayerNode.zPosition = 0.5;
	[self addChild:_projectileLayerNode];
	
	/* Show proj layers */
	_projectileParticleLayerNode.alpha = 1;
	_projectileLayerNode.alpha         = 1;
	
	/* Allow spawns after delay */
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		_shouldSpawnProjectiles = YES;
	});
	
	NSArray *spawnDics = level[@"spawns"];
	int spawnIndex = 0;
	for (NSDictionary *dic in spawnDics) {
		SpawnPoint *spawn = [[SpawnPoint alloc] initWithDictionary:dic forSceneSize:screenSize];
		[_spawnPoints addObject:spawn];
		EXLog(MODEL, DBG, @"Loaded spawn point at (%.2f, %.2f)", spawn.position.x, spawn.position.y);
		
		[self addChild:spawn.node];
		
		/* Scale in */
		float delay = 0.1 + (spawnIndex * 0.25); spawnIndex++;
		spawn.node.alpha = 0;
		[spawn.node bounceInAfterDelay:delay duration:0.9 bounces:5];
		[spawn.node animateToAlpha:0.1 delay:delay duration:0.4];
	}
	
	NSArray *controlDics = level[@"controls"];
	NSMutableArray *warps = [NSMutableArray array];
	int controlIndex = 0;
	for (NSDictionary *dic in controlDics) {
		if ([dic[@"ignore"] boolValue]) continue;
		SceneControl *control = [[SceneControl alloc] initWithDictionary:dic forSceneSize:screenSize];
		control.scene = self;
		[_controls addObject:control];
		EXLog(MODEL, DBG, @"Loaded control of type %d at (%.2f, %.2f)", control.controlType, control.position.x, control.position.y);
		
		if (control.node)  [self addChild:control.node];
		if (control.icon)  [self addChild:control.icon];
		if (control.shape) [self addChild:control.shape];
		
		if (control.controlType == CONTROL_TYPE_WARP) [warps addObject:control];
		
		/* Scale in */
		float delay = 0.1 + (controlIndex * 0.1); controlIndex++;
		control.node.alpha = 0;
		control.icon.alpha = 0;
		control.shape.alpha = 0;
		[control.node  bounceInAfterDelay:delay duration:0.9 bounces:5];
		if (control.controlType != CONTROL_TYPE_SHAPE) [control.node  animateToAlpha:0.1 delay:delay duration:0.4];
		[control.icon  bounceInAfterDelay:delay duration:0.9 bounces:5];
		[control.icon  animateToAlpha:1   delay:delay duration:0.4];
		[control.shape bounceInAfterDelay:delay duration:0.9 bounces:5];
		[control.shape animateToAlpha:1   delay:delay duration:0.4];
	}
	
	NSArray *fissureDics = level[@"fissures"];
	int fissureIndex = 1;
	for (NSDictionary *dic in fissureDics) {
		Fissure *fissure = [[Fissure alloc] initWithDictionary:dic forSceneSize:screenSize];
		fissure.fissureIndex = fissureIndex;
		[_fissures addObject:fissure];
		EXLog(MODEL, DBG, @"Loaded fissure at (%.2f, %.2f)", fissure.position.x, fissure.position.y);
		
		[self addChild:fissure];
		fissureIndex++;
		
		float delay = 0.25 + (fissureIndex * 0.25);
		fissure.alpha = 0;
		[fissure animateToAlpha:1 delay:delay duration:1.5];
	}
	
	NSArray *targetDics = level[@"targets"];
	int targetIndex = 0;
	for (NSDictionary *dic in targetDics) {
		Target *target = [[Target alloc] initWithDictionary:dic forSceneSize:screenSize];
		if (target.matchedFissure) {
			target.color = ((Fissure*)_fissures[target.matchedFissure-1]).color;
		}
		
		[_targets addObject:target];
		EXLog(MODEL, DBG, @"Loaded target at (%.2f, %.2f)", target.position.x, target.position.y);
		
		[self addChild:target.node];
		
		
		/* Scale in */
		float delay = 0.1 + (targetIndex * 0.15); targetIndex++;
		target.node.alpha = 0;
		[target.node bounceInAfterDelay:delay duration:0.9 bounces:5];
		[target.node animateToAlpha:1 delay:delay duration:0.4];
	}
	
	/* This part connects the warp zones */
	if ([warps count] == 0) {
		EXLog(MODEL, DBG, @"No warp zones");
	} else if ([warps count] % 2 == 0) {
		for (int i = 0; i < [warps count]; i+=2) {
			SceneControl *w1 = warps[i];
			SceneControl *w2 = warps[i+1];
			w1.connectedWarp = w2;
			w2.connectedWarp = w1;
		}
	} else {
		EXLog(MODEL, DBG, @"Invalid warp count: %d", (int)[warps count]);
	}
	
	
	/* Allow full trigger! */
	_canTriggerFull = YES;
}


-(void)update:(CFTimeInterval)currentTime {
	/* If we missed more than a certain lapse, pretend it was just a complete skip */
	CFTimeInterval elapsedTime = currentTime - _lastFrameTime;
	_lastFrameTime = currentTime;
	if (elapsedTime > 1) {
		return;
	}
	
	/* Spawn if neeeded */
	[self spawnProjectiles];
	
	/* Update projectiles */
	for (SceneControl *control in _controls) {
		[control updateAffectedProjectilesForDuration:elapsedTime];
	}
	
	/* Update targets */
	BOOL allFull = YES;
	for (Target *target in _targets) {
		[target updateForDuration:elapsedTime];
		if (target.timeFull < (target.hysteresis + 0.25)) allFull = NO;
	}
	
	if (allFull) {
		[self allTargetsFull];
	}
	
	/* Check for stopped nodes */
	for (SKNode *node in _projectileLayerNode.children) {
		float dx = node.physicsBody.velocity.dx;
		float dy = node.physicsBody.velocity.dy;
		if (dx < 10 && dy < 10 && dx > -10 && dy > -10) {
			BOOL found = NO;
			for (SceneControl *control in _controls) {
				//if (control.controlType != CONTROL_TYPE_PUSH) continue;
				if ([control.affectedProjectiles indexOfObjectIdenticalTo:node] != NSNotFound) {
					found = YES;
					break;
				}
			}
			if (!found) [node removeFromParent];
		}
	}
}


- (void) allTargetsFull {
	if (!_canTriggerFull) return;
	_canTriggerFull = NO;
	
	[self.sceneDelegate sceneAllTargetsLit];
	[self levelOverStageOne];
}

- (void) forceWin {
	[self allTargetsFull];
}

/* animate all objects out */
- (void) levelOverStageOne {
	
	/* Alpha-out statics */
	for (SKNode *node in _staticImages) {
		[node animateToAlpha:0 delay:0 duration:0.5];
	}
	
	/* Alpha-out controls */
	int controlIndex = 0;
	for (SceneControl *control in _controls) {
		float delay = 0.5 + controlIndex * 0.15;
		
		[control.node  bounceOutAfterDelay:delay-0.25 duration:0.9 bounces:2];
		[control.icon  bounceOutAfterDelay:delay-0.25 duration:0.9 bounces:2];
		[control.shape bounceOutAfterDelay:delay-0.25 duration:0.9 bounces:2];
		
		[control.node  animateToAlpha:0 delay:delay duration:0.5];
		[control.icon  animateToAlpha:0 delay:delay duration:0.5];
		[control.shape animateToAlpha:0 delay:delay duration:0.5];
						
		//[control.node  animateToScale:0.5 delay:delay duration:0.5];
		//[control.icon  animateToScale:0.5 delay:delay duration:0.5];
		//[control.shape animateToScale:0.5 delay:delay duration:0.5];
		
		controlIndex++;
	}
		
	/* Alpha-out projectiles */
	[_projectileLayerNode         animateToAlpha:0 delay:0 duration:0.75];
	[_projectileParticleLayerNode animateToAlpha:0 delay:0 duration:0.75];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		_shouldSpawnProjectiles = NO;
	});
	
	/* Alpha-out targets */
	int targetIndex = 0;
	for (Target *target in _targets) {
		float delay = 1 + targetIndex * 0.15;
		[target.node animateToAlpha:0   delay:delay duration:0.5];
		[target.node animateToScale:0.5 delay:delay duration:0.5];
		targetIndex++;
	}
	
	/* Alpha-out fissures */
	int fissureIndex = 0;
	for (Fissure *fissure in _fissures) {
		float delay = 1 + fissureIndex * 0.15;
		[fissure animateToAlpha:0   delay:delay duration:0.5];
		[fissure animateToScale:0.5 delay:delay duration:0.5];
		fissureIndex++;
	}
	
	/* Alpha-out spawn points */
	int spawnIndex = 0;
	for (SpawnPoint *spawn in _spawnPoints) {
		float delay = 1 + spawnIndex * 0.15;
		[spawn.node animateToAlpha:0   delay:delay duration:0.5];
		[spawn.node animateToScale:0.5 delay:delay duration:0.5];
		spawnIndex++;
	}
	
	/* Trigger stage 2 */
	[self performSelector:@selector(levelOverStageTwo) withObject:nil afterDelay:2];
}

/* Kill all objects and remove from tree */
- (void) levelOverStageTwo {
	for (SKNode *node in _staticImages) {
		[node removeFromParent];
	}
	[_staticImages removeAllObjects];
	
	for (SceneControl *c in _controls) {
		[c.node removeFromParent];
		[c.icon removeFromParent];
		[c.shape removeFromParent];
	}
	[_controls removeAllObjects];
	
	for (Fissure *f in _fissures) {
		[f removeFromParent];
	}
	[_fissures removeAllObjects];
	
	for (SpawnPoint *s in _spawnPoints) {
		[s.node removeFromParent];
	}
	[_spawnPoints removeAllObjects];
	
	for (Target *t in _targets) {
		[t.node removeFromParent];
	}
	[_targets removeAllObjects];
	
	/* Particles */
	[_projectileLayerNode removeFromParent];
	[_projectileParticleLayerNode removeFromParent];

	_projectileLayerNode = nil;
	_projectileParticleLayerNode = nil;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self levelOverStageThree];
	});
}

- (void) levelOverStageThree {
	[self.sceneDelegate sceneReadyToTransition];
}

- (void) spawnProjectiles {
	if (!_shouldSpawnProjectiles) return;
	
	for (SpawnPoint *point in _spawnPoints) {
		if (![point shouldSpawnThisFrame]) continue;
		
		/* Create the projectile */
		SKSpriteNode *node = [[SKSpriteNode alloc] initWithImageNamed:@"line5x1"];
		//node.position = CGPointMake( point.position.x + (rand() % (int)point.positionJitter.width)  - point.positionJitter.width/2,
		//							 point.position.y + (rand() % (int)point.positionJitter.height) - point.positionJitter.height/2);
		node.position = CGPointMake( point.position.x + floatBetween(-point.positionJitter.width, point.positionJitter.width),
									 point.position.y + floatBetween(-point.positionJitter.height, point.positionJitter.height) );
		
		node.color = [UIColor grayColor];
		node.colorBlendFactor = 1;
		
		node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:PROJECTILE_PHYS_RADIUS];
		node.physicsBody.friction = point.friction;
		node.physicsBody.velocity = point.initialVelocity;
		node.physicsBody.affectedByGravity = NO;
		node.physicsBody.allowsRotation = YES;
		node.physicsBody.linearDamping = point.friction;
		node.physicsBody.restitution = 1;
		node.zRotation = atan2(node.physicsBody.velocity.dy, node.physicsBody.velocity.dx);
		
		node.physicsBody.categoryBitMask = PHYS_CAT_PROJ;
		node.physicsBody.collisionBitMask = PHYS_CAT_CONTROL_COLL;
		node.physicsBody.contactTestBitMask = PHYS_CAT_EDGE | PHYS_CAT_CONTROL_TRANS | PHYS_CAT_TARGET | PHYS_CAT_FISSURE | PHYS_CAT_CONTROL_COLL;
		
		[_projectileLayerNode addChild:node];
		
		/* Create the particle effect behind it */
		SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"projectile_trail" ofType:@"sks"]];
		emitter.targetNode = _projectileParticleLayerNode;
		[node addChild:emitter];
		
		/* Attach it to the userData */
		node.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"emitter":emitter}];
	}
}

- (void) removeNodeFromAllControlsNotInRange:(SKNode*)node {
	for (SceneControl *control in _controls) {
		
		if (control.controlType == CONTROL_TYPE_WARP) continue;
		
		float dx = node.position.x - control.position.x;
		float dy = node.position.y - control.position.y;
		float dist = sqrt(dx * dx + dy * dy);
		
		if (dist > control.radius) {
			[control.affectedProjectiles removeObjectIdenticalTo:node];
		}
	}
}

- (void) resetControlsToInitialPositions {
	for (SceneControl *control in _controls) {
		[control.node  bounceToPosition:control.initialPosition scale:1 delay:0 duration:1.1 bounces:5];
		[control.icon  bounceToPosition:control.initialPosition scale:1 delay:0 duration:1.1 bounces:5];
		[control.shape bounceToPosition:control.initialPosition scale:1 delay:0 duration:1.1 bounces:5];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			control.position = control.initialPosition;
			control.radius   = control.initialRadius;
		});
	}
}


#pragma mark Contact Checks

- (void) didBeginContact:(SKPhysicsContact *)contact {
	SKPhysicsBody *firstBody, *secondBody;
	
	/* Order the nodes by category for easier processing */
	if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
		firstBody = contact.bodyA;
		secondBody = contact.bodyB;
	} else {
		firstBody = contact.bodyB;
		secondBody = contact.bodyA;
	}
    
	/* If a projectile hits an edge, remove it */
	if ((firstBody.categoryBitMask & PHYS_CAT_EDGE) && (secondBody.categoryBitMask & PHYS_CAT_PROJ)) {
		[_projectileLayerNode removeChildrenInArray:@[secondBody.node]];
		return;
	}
	
	/* Check if a projectile hits a passable control */
	if (firstBody.categoryBitMask & PHYS_CAT_PROJ) {
		if (secondBody.categoryBitMask & PHYS_CAT_CONTROL_TRANS) {
			SceneControl *control = secondBody.node.userData[@"control"];			
			[control.affectedProjectiles addObject:firstBody.node];
			return;
		}
		
		/* Check if a projectile hits a target */
		if (secondBody.categoryBitMask & PHYS_CAT_TARGET) {
			Target *target = secondBody.node.userData[@"target"];
			SKSpriteNode *proj = (SKSpriteNode*)firstBody.node;
			
			if ([proj.userData[@"fissureIndex"] intValue] == target.matchedFissure) {
				[target hitByProjectile];
			}
			return;
		}
		
		/* Change projectile rotation */
		if (secondBody.categoryBitMask & PHYS_CAT_CONTROL_COLL) {
			SKSpriteNode *proj = (SKSpriteNode*)firstBody.node;
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				proj.zRotation = atan2(proj.physicsBody.velocity.dy, proj.physicsBody.velocity.dx);
			});
			//proj.zRotation = atan2(proj.physicsBody.velocity.dy, proj.physicsBody.velocity.dx);
			return;
			//NSLog(@"vel: %f %f %f", proj.physicsBody.velocity.dx, proj.physicsBody.velocity.dy, proj.zRotation);
		}
				
	}
}

- (void) didEndContact:(SKPhysicsContact *)contact {
	SKPhysicsBody *firstBody, *secondBody;
	
	/* Order the nodes by category for easier processing */
	if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
		firstBody = contact.bodyA;
		secondBody = contact.bodyB;
	} else {
		firstBody = contact.bodyB;
		secondBody = contact.bodyA;
	}
		
	
	if (firstBody.categoryBitMask & PHYS_CAT_PROJ) {
		
		/* Projectile leaves a control */
		if (secondBody.categoryBitMask & PHYS_CAT_CONTROL_TRANS) {
			SceneControl *control = secondBody.node.userData[@"control"];
			[control.affectedProjectiles removeObjectIdenticalTo:firstBody.node];
			if (control.controlType == CONTROL_TYPE_WARP) [firstBody.node.userData removeObjectForKey:@"warped"];
			return;
		}
		
		/* Check if a projectile hits a fissure */
		if (secondBody.categoryBitMask & PHYS_CAT_FISSURE) {
			/* Update fissure */
			Fissure *fissure = (Fissure*)secondBody.node;
			SKSpriteNode *proj = (SKSpriteNode*)firstBody.node;
			proj.color = fissure.color;
			proj.colorBlendFactor = 0.95;
			proj.userData[@"fissureIndex"] = @(fissure.fissureIndex);
			
			/* Update emitter color */
			SKEmitterNode *emitter = (SKEmitterNode*)proj.userData[@"emitter"];
			CGFloat r,g,b,a;
			[fissure.color getRed:&r green:&g blue:&b alpha:&a];
			emitter.particleColorSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[[UIColor colorWithRed:r green:g blue:b alpha:0.15],
																								 [UIColor colorWithRed:r green:g blue:b alpha:0]] times:@[@(0), @(1)]];;
			return;
		}
				
	}
}


#pragma mark Touch Controls

-(void)touchesBegan:(NSSet*) touches withEvent:(UIEvent*) event {
	if ([touches count] == 1) {
			
		CGPoint touchPoint = [[touches anyObject] locationInNode:self];
		NSArray *touchedNodes = [self nodesAtPoint:touchPoint];
		
		/* Debug touch output */
		#ifdef EXDEBUGENABLED
		EXLog(ANY, DBG, @"%f %f", (touchPoint.x - (([UIScreen mainScreen].bounds.size.height < 481)?0:44))/480.0, touchPoint.y / 320.0);
		#endif
		
		NSMutableArray *touchedControls = [NSMutableArray array];
		for (SKNode *node in touchedNodes) {
			if (![node.userData[@"isControl"] boolValue]) continue;
			SceneControl *control = node.userData[@"control"];
			if (!control.canMove && !control.canScale) continue;
			[touchedControls addObject:control];
			/*
			for (SceneControl *control in _controls) {
				if (control.node == node) {
					[touchedControls addObject:control];
					break;
				}
			}
			 */
		}
		
		/* No controls touched?  break */
		if (![touchedControls count]) return;
		
		/* Default to drag behavior */
		_draggedControl = nil;
		float minDist = 1000000;
		for (SceneControl *control in touchedControls) {
			float dx = control.position.x - touchPoint.x;
			float dy = control.position.y - touchPoint.y;
			float dist = sqrt(dx * dx + dy * dy);
			if (dist < minDist) {
				minDist = dist;
				_draggedControl = control;
				_dragOffset = CGPointMake(dx, dy);
			}
		}
		
		/* See if it's scaling instead */
		if (!_draggedControl.canScale) return;
		if (minDist > (_draggedControl.radius - SCALE_RADIUS_WIDTH)) {
			_scalingControl = _draggedControl; _draggedControl = nil;
			_scalingOffset  = _scalingControl.radius - minDist;
		} else if (!_draggedControl.canMove) {
			_draggedControl = nil;
		}
	}
	
}

-(void)touchesMoved:(NSSet*) touches withEvent:(UIEvent*) event {
	if ([touches count] > 1) return;
	
	CGPoint touchPoint = [[touches anyObject] locationInNode:self];
		
	if (_draggedControl) {

		/* Update position of control (this should update the node position as well */
		_draggedControl.position = CGPointMake(touchPoint.x + _dragOffset.x, touchPoint.y + _dragOffset.y);
		
		[self resetTargetTimers];
		
	} else if (_scalingControl) {
		
		/* Update radius of control */
		float dx = touchPoint.x - _scalingControl.position.x;
		float dy = touchPoint.y - _scalingControl.position.y;
		float dist = sqrt(dx * dx + dy * dy);
		float radius = dist + _scalingOffset;
		
		_scalingControl.radius = radius;
		
		[self resetTargetTimers];
	}
}

- (void) resetTargetTimers {
	for (Target *t in _targets) {
		[t controlMoved];
	}
}

-(void)touchesEnded:(NSSet*) touches withEvent:(UIEvent*) event {
	_draggedControl = nil;
	_scalingControl = nil;
}


@end
