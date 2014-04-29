//
//  SKNode+Animations.h
//  Fissure
//
//  Created by Jason Fieldman on 4/27/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKNode (AnimationStuff)

- (void) bounceInAfterDelay:(float)delay duration:(float)duration bounces:(int)bounces;
- (void) bounceOutAfterDelay:(float)delay duration:(float)duration bounces:(int)bounces;
- (void) animateToAlpha:(float)alpha delay:(float)delay duration:(float)duration;
- (void) animateToScale:(float)scale delay:(float)delay duration:(float)duration;

- (void) bounceToPosition:(CGPoint)point scale:(float)scale delay:(float)delay duration:(float)duration bounces:(int)bounces;

@end
