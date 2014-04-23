//
//  Fissure.h
//  Fissure
//
//  Created by Jason Fieldman on 4/22/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fissure : SKNode

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) int      fissureIndex;

- (id) initWithDictionary:(NSDictionary*)dictionary forSceneSize:(CGSize)sceneSize;

@end
