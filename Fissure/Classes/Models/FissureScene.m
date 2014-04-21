//
//  FissureScene.m
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import "FissureScene.h"

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
		node.physicsBody.contactTestBitMask = PHYS_CAT_EDGE;
		
		[self addChild:node];
		
		/* Create the particle effect behind it */
		SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"projectile_trail" ofType:@"sks"]];
		emitter.targetNode = _projectileParticleLayerNode;
		[node addChild:emitter];
		
		/* Attach it to the userData */
		node.userData[@"emitter"] = emitter;
	}
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
	SKPhysicsBody *firstBody, *secondBody;
	
	if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
		firstBody = contact.bodyA;
		secondBody = contact.bodyB;
	} else {
		firstBody = contact.bodyB;
		secondBody = contact.bodyA;
	}
    
	if ((firstBody.categoryBitMask & 1) != 0) {
		[self removeChildrenInArray:@[secondBody.node]];
	}
}

@end
