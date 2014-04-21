//
//  SpawnPoint.h
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpawnPoint : NSObject

@property (nonatomic, assign) CGPoint  position;
@property (nonatomic, assign) CGSize   positionJitter;
@property (nonatomic, assign) CGVector initialVelocity;
@property (nonatomic, assign) float    friction;

- (id) initWithDictionary:(NSDictionary*)dictionary forSceneSize:(CGSize)sceneSize;

@end
