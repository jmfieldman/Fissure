//
//  SceneControl.h
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FissureScene;

typedef enum ControlType {
	
	CONTROL_TYPE_PUSH       = 0,
	CONTROL_TYPE_GRAVITY,
	CONTROL_TYPE_REPEL,
	CONTROL_TYPE_PROPEL,
	CONTROL_TYPE_SLOW,
	CONTROL_TYPE_WARP,
	CONTROL_TYPE_SHAPE,
	
	NUM_CONTROL_TYPES,
	
} ControlType_t;



@interface SceneControl : NSObject {

}

@property (nonatomic, assign) ControlType_t controlType;
@property (nonatomic, assign) float angle;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) float radius;
@property (nonatomic, assign) float minRadius;
@property (nonatomic, assign) float maxRadius;
@property (nonatomic, assign) float power;
@property (nonatomic, assign) CGVector powerVector;
@property (nonatomic, assign) BOOL canScale;
@property (nonatomic, assign) BOOL canRotate;
@property (nonatomic, assign) BOOL canMove;

@property (nonatomic, strong, readonly) SKSpriteNode *node;
@property (nonatomic, strong, readonly) SKSpriteNode *icon;
@property (nonatomic, strong, readonly) SKShapeNode  *shape;
@property (nonatomic, strong, readonly) NSMutableArray *affectedProjectiles;

@property (nonatomic, readonly) CGPoint initialPosition;
@property (nonatomic, readonly) float   initialRadius;

@property (nonatomic, weak) SceneControl *connectedWarp;
@property (nonatomic, weak) FissureScene *scene;

- (id) initWithDictionary:(NSDictionary*)dictionary forSceneSize:(CGSize)sceneSize;

- (void) updateAffectedProjectilesForDuration:(CFTimeInterval)duration;

@end
