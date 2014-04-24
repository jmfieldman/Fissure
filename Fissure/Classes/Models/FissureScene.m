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
		
		/* Initialize timing */
		_lastFrameTime = 0;
		
		/* Create boundary */
		self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectInset(self.frame, -75, -75)];
		self.physicsBody.categoryBitMask = PHYS_CAT_EDGE;
		
		/* Create the projectile particle layer */
		_projectileParticleLayerNode = [SKNode node];
		_projectileParticleLayerNode.position = CGPointMake(50, 200);
		[self addChild:_projectileParticleLayerNode];
		
    }
    return self;
}

- (void) loadFromLevelDictionary:(NSDictionary*)level {
	
	NSArray *spawnDics = level[@"spawns"];
	for (NSDictionary *dic in spawnDics) {
		SpawnPoint *spawn = [[SpawnPoint alloc] initWithDictionary:dic forSceneSize:self.size];
		[_spawnPoints addObject:spawn];
		EXLog(MODEL, DBG, @"Loaded spawn point at (%.2f, %.2f)", spawn.position.x, spawn.position.y);
		
		[self addChild:spawn.node];
	}
	
	NSArray *controlDics = level[@"controls"];
	for (NSDictionary *dic in controlDics) {
		SceneControl *control = [[SceneControl alloc] initWithDictionary:dic forSceneSize:self.size];
		[_controls addObject:control];
		EXLog(MODEL, DBG, @"Loaded control of type %d at (%.2f, %.2f)", control.controlType, control.position.x, control.position.y);
		
		[self addChild:control.node];
		[self addChild:control.icon];
	}
	
	NSArray *fissureDics = level[@"fissures"];
	int fissureIndex = 1;
	for (NSDictionary *dic in fissureDics) {
		Fissure *fissure = [[Fissure alloc] initWithDictionary:dic forSceneSize:self.size];
		fissure.fissureIndex = fissureIndex;
		[_fissures addObject:fissure];
		EXLog(MODEL, DBG, @"Loaded fissure at (%.2f, %.2f)", fissure.position.x, fissure.position.y);
		
		[self addChild:fissure];
		fissureIndex++;
	}
	
	NSArray *targetDics = level[@"targets"];
	for (NSDictionary *dic in targetDics) {
		Target *target = [[Target alloc] initWithDictionary:dic forSceneSize:self.size];
		if (target.matchedFissure) {
			target.color = ((Fissure*)_fissures[target.matchedFissure-1]).color;
		}
		
		[_targets addObject:target];
		EXLog(MODEL, DBG, @"Loaded target at (%.2f, %.2f)", target.position.x, target.position.y);
		
		[self addChild:target.node];
	}
	
	
	
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
		if (target.timeFull < (target.hysteresis * 2)) allFull = NO;
	}
	
	if (allFull) {
		[self allTargetsFull];
	}
	
}


- (void) allTargetsFull {
	
}


- (void) spawnProjectiles {
	for (SpawnPoint *point in _spawnPoints) {
		if (![point shouldSpawnThisFrame]) continue;
		
		/* Create the projectile */
		SKSpriteNode *node = [[SKSpriteNode alloc] initWithImageNamed:@"line5x1"];
		node.position = CGPointMake( point.position.x + (rand() % (int)point.positionJitter.width)  - point.positionJitter.width/2,
									 point.position.y + (rand() % (int)point.positionJitter.height) - point.positionJitter.height/2);
		node.color = [UIColor grayColor];
		node.colorBlendFactor = 1;
		
		node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:PROJECTILE_PHYS_RADIUS];
		node.physicsBody.friction = point.friction;
		node.physicsBody.velocity = point.initialVelocity;
		node.physicsBody.affectedByGravity = NO;
		node.physicsBody.allowsRotation = NO;
		node.physicsBody.linearDamping = 0.2;
		node.zRotation = atan2(node.physicsBody.velocity.dy, node.physicsBody.velocity.dx);
		
		node.physicsBody.categoryBitMask = PHYS_CAT_PROJ;
		node.physicsBody.collisionBitMask = 0;
		node.physicsBody.contactTestBitMask = PHYS_CAT_EDGE | PHYS_CAT_CONTROL_TRANS | PHYS_CAT_TARGET | PHYS_CAT_FISSURE;
		
		[self addChild:node];
		
		/* Create the particle effect behind it */
		SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"projectile_trail" ofType:@"sks"]];
		emitter.targetNode = _projectileParticleLayerNode;
		[node addChild:emitter];
		
		/* Attach it to the userData */
		node.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"emitter":emitter}];
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
		[self removeChildrenInArray:@[secondBody.node]];
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
	
		NSMutableArray *touchedControls = [NSMutableArray array];
		for (SKNode *node in touchedNodes) {
			if (![node.userData[@"isControl"] boolValue]) continue;
			SceneControl *control = node.userData[@"control"];
			if (!control.canMove) continue;
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
		}
	}
	
}

-(void)touchesMoved:(NSSet*) touches withEvent:(UIEvent*) event {
	if ([touches count] > 1) return;
	
	CGPoint touchPoint = [[touches anyObject] locationInNode:self];
		
	if (_draggedControl) {

		/* Update position of control (this should update the node position as well */
		_draggedControl.position = CGPointMake(touchPoint.x + _dragOffset.x, touchPoint.y + _dragOffset.y);
		
	} else if (_scalingControl) {
		
		/* Update radius of control */
		float dx = touchPoint.x - _scalingControl.position.x;
		float dy = touchPoint.y - _scalingControl.position.y;
		float dist = sqrt(dx * dx + dy * dy);
		float radius = dist + _scalingOffset;
		
		_scalingControl.radius = radius;
	}
}

-(void)touchesEnded:(NSSet*) touches withEvent:(UIEvent*) event {
	_draggedControl = nil;
	_scalingControl = nil;
}


@end
