//
//  FissureScene.h
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface FissureScene : SKScene <SKPhysicsContactDelegate> {
	/* Timing */
	CFTimeInterval _lastFrameTime;
	
	/* Holds projectile particle effects */
	SKNode *_projectileParticleLayerNode;
}

@property (nonatomic, readonly) NSMutableArray *spawnZones;

@end
