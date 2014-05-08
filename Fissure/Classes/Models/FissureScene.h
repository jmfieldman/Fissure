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
#import "Target.h"
#import "Fissure.h"

#define PHYS_CAT_EDGE              0x0001
#define PHYS_CAT_PROJ              0x0002
#define PHYS_CAT_TARGET            0x0004
#define PHYS_CAT_FISSURE           0x0008

#define PHYS_CAT_CONTROL_TRANS     0x0100
#define PHYS_CAT_CONTROL_COLL      0x0200


#define PROJECTILE_PHYS_RADIUS 3


@protocol FissureSceneDelegate <NSObject>
- (void) sceneAllTargetsLit;
- (void) sceneReadyToTransition;
@end

@interface FissureScene : SKScene <SKPhysicsContactDelegate> {
	/* Timing */
	CFTimeInterval _lastFrameTime;
	
	/* Holds projectile particle effects */
	SKNode       *_projectileParticleLayerNode;
	SKNode       *_projectileLayerNode;
	
	/* Which control am I dragging/scaling? */
	SceneControl *_draggedControl;
	CGPoint       _dragOffset;
	SceneControl *_scalingControl;
	float         _scalingOffset;
	
	/* Can trigger full state? */
	BOOL          _canTriggerFull;
	
	/* Should spawn projectiles? */
	BOOL          _shouldSpawnProjectiles;
}

@property (nonatomic, readonly) NSMutableArray *spawnPoints;
@property (nonatomic, readonly) NSMutableArray *controls;
@property (nonatomic, readonly) NSMutableArray *targets;
@property (nonatomic, readonly) NSMutableArray *fissures;
@property (nonatomic, readonly) NSMutableArray *staticImages;

@property (nonatomic, weak) id<FissureSceneDelegate> sceneDelegate;

- (void) loadFromLevelDictionary:(NSDictionary*)level;

- (void) removeNodeFromAllControlsNotInRange:(SKNode*)node;

- (void) resetControlsToInitialPositions;

- (void) forceWin;

@end
