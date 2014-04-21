//
//  FissureScene.h
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SpawnPoint.h"
#import "SceneControl.h"

#define PHYS_CAT_EDGE              0x0001
#define PHYS_CAT_PROJ              0x0002
#define PHYS_CAT_GOAL              0x0004

#define PHYS_CAT_CONTROL_TRANS     0x0100



#define PROJECTILE_PHYS_RADIUS 3


@interface FissureScene : SKScene <SKPhysicsContactDelegate> {
	/* Timing */
	CFTimeInterval _lastFrameTime;
	
	/* Holds projectile particle effects */
	SKNode *_projectileParticleLayerNode;
	
	/* Which control am I dragging/scaling? */
	SceneControl *_draggedControl;
	CGPoint       _dragOffset;
	SceneControl *_scalingControl;
	float         _scalingOffset;
}

@property (nonatomic, readonly) NSMutableArray *spawnPoints;
@property (nonatomic, readonly) NSMutableArray *controls;


- (void) loadFromLevelDictionary:(NSDictionary*)level;

@end
