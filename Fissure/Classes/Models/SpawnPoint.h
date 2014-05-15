//
//  SpawnPoint.h
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SpawnPoint : NSObject {
	/* Determine when to spawn */
	int _frameCount;
}

@property (nonatomic, assign) CGPoint  position;
@property (nonatomic, assign) CGSize   positionJitter;
@property (nonatomic, assign) CGVector initialVelocity;
@property (nonatomic, assign) float    friction;
@property (nonatomic, assign) int      frameInterval;

@property (nonatomic, strong) SKSpriteNode *node;

- (id) initWithDictionary:(NSDictionary*)dictionary forSceneSize:(CGSize)sceneSize;

- (BOOL) shouldSpawnThisFrame;

@end
