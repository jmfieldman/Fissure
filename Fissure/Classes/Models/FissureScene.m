//
//  FissureScene.m
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import "FissureScene.h"

#define SCALE_RADIUS_WIDTH 20

static int s_test = 0;

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
	}
	
	NSArray *controlDics = level[@"controls"];
	for (NSDictionary *dic in controlDics) {
		SceneControl *control = [[SceneControl alloc] initWithDictionary:dic forSceneSize:self.size];
		[_controls addObject:control];
		EXLog(MODEL, DBG, @"Loaded control of type %d at (%.2f, %.2f)", control.controlType, control.position.x, control.position.y);
		
		[self addChild:control.node];
	}
	
}


-(void)update:(CFTimeInterval)currentTime {
	/* If we missed more than a certain lapse, pretend it was just a complete skip */
	CFTimeInterval elapsedTime = currentTime - _lastFrameTime;
	_lastFrameTime = currentTime;
	if (elapsedTime > 1) {
		return;
	}
	
	EXLog(ANY, DBG, @"s_test: %d", s_test);
	s_test = 0;
	
	/* Spawn if neeeded */
	[self spawnProjectiles];
	
	/* Update projectiles */
	for (SceneControl *control in _controls) {
		[control updateAffectedProjectilesForDuration:elapsedTime];
	}
}

- (void) spawnProjectiles {
	for (SpawnPoint *point in _spawnPoints) {
		if (![point shouldSpawnThisFrame]) continue;
		
		/* Create the projectile */
		SKSpriteNode *node = [[SKSpriteNode alloc] initWithImageNamed:@"projectile.png"];
		node.position = CGPointMake( point.position.x + (rand() % (int)point.positionJitter.width)  - point.positionJitter.width/2,
									 point.position.y + (rand() % (int)point.positionJitter.height) - point.positionJitter.height/2);
		
		node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:PROJECTILE_PHYS_RADIUS];
		node.physicsBody.friction = point.friction;
		node.physicsBody.velocity = point.initialVelocity;
		
		node.physicsBody.categoryBitMask = PHYS_CAT_PROJ;
		node.physicsBody.collisionBitMask = 0;
		node.physicsBody.contactTestBitMask = PHYS_CAT_EDGE | PHYS_CAT_CONTROL_TRANS;
		
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
	
	s_test++;
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
	if ((firstBody.categoryBitMask & PHYS_CAT_PROJ) && (secondBody.categoryBitMask & PHYS_CAT_CONTROL_TRANS)) {
		SceneControl *control = secondBody.node.userData[@"control"];
		[control.affectedProjectiles addObject:firstBody.node];
		return;
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
	
	/* Check if a projectile leaves a passable control */
	if ((firstBody.categoryBitMask & PHYS_CAT_PROJ) && (secondBody.categoryBitMask & PHYS_CAT_CONTROL_TRANS)) {
		SceneControl *control = secondBody.node.userData[@"control"];
		[control.affectedProjectiles removeObjectIdenticalTo:firstBody.node];
		return;
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
			[touchedControls addObject:node.userData[@"control"]];
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
		for (SceneControl *control in _controls) {
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
