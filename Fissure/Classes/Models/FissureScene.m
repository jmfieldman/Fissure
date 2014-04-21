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
		_spawnZones = [NSMutableArray array];
		
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



-(void)update:(CFTimeInterval)currentTime {
	/* If we missed more than a certain lapse, pretend it was just a complete skip */
	CFTimeInterval elapsedTime = currentTime - _lastFrameTime;
	_lastFrameTime = currentTime;
	if (elapsedTime > 1) {
		return;
	}
	
	static int foo = 0;
	foo = (foo + 1) % 6;
	if (foo != 0) return;
	//if (rand()%4 != 0) return;
	
	//SKSpriteNode *node = [[SKSpriteNode alloc] initWithColor:[UIColor grayColor] size:CGSizeMake(2,2)];
	SKSpriteNode *node = [[SKSpriteNode alloc] initWithImageNamed:@"projectile.png"];
	node.position = CGPointMake(rand()%20+20, rand()%20+20);
	node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:5];
	node.physicsBody.friction = 0.2;
	node.physicsBody.velocity = CGVectorMake(200,200);
	node.physicsBody.collisionBitMask = 0;
	node.physicsBody.contactTestBitMask = 1;
	node.physicsBody.categoryBitMask = 2;
	[self addChild:node];
	
	SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"projectile_trail" ofType:@"sks"]];
	emitter.targetNode = _projectileParticleLayerNode;
	[node addChild:emitter];
	
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
	
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if ((firstBody.categoryBitMask & 1) != 0)
    {
        [self removeChildrenInArray:@[secondBody.node]];
    }
}

@end
