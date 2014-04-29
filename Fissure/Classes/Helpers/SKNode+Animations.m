//
//  SKNode+Animations.m
//  Fissure
//
//  Created by Jason Fieldman on 4/27/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import "SKNode+Animations.h"

@implementation SKNode (AnimationStuff)

- (void) bounceInAfterDelay:(float)delay duration:(float)duration bounces:(int)bounces {
	
	CGFloat stiffnessCoefficient = 0.01f;
	

	CGFloat startValue = 0.8;
	CGFloat endValue   = 1;
	CGFloat diff       = endValue - startValue;
	CGFloat coeff      = startValue - endValue;
	
	CGFloat alpha      = log2f(stiffnessCoefficient/fabsf(diff));
	if (alpha > 0) alpha = -1.0f * alpha;
	
	CGFloat numberOfPeriods = bounces/2 + 0.5;
	CGFloat omega           = numberOfPeriods * 2*M_PI;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self runAction:[SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
			
			CGFloat progress = elapsedTime / duration;
			CGFloat oscillationComponent = cos(omega * progress);
			
			CGFloat value = coeff * pow(M_E, alpha * progress) * oscillationComponent + endValue;
			
			[node setScale:value];
			
		}]];
	});
	
}

- (void) bounceOutAfterDelay:(float)delay duration:(float)duration bounces:(int)bounces {

	CGFloat stiffnessCoefficient = 0.01f;
	
	CGFloat startValue = self.xScale * 0.8;
	CGFloat endValue   = self.xScale * 1;
	CGFloat diff       = endValue - startValue;
	CGFloat coeff      = startValue - endValue;
	
	CGFloat alpha      = log2f(stiffnessCoefficient/fabsf(diff));
	if (alpha > 0) alpha = -1.0f * alpha;
	
	CGFloat numberOfPeriods = bounces/2 + 0.5;
	CGFloat omega           = numberOfPeriods * 2*M_PI;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self runAction:[SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
			
			CGFloat progress = 1.0 - (elapsedTime / duration);
			CGFloat oscillationComponent = cos(omega * progress);
			
			CGFloat value = coeff * pow(M_E, alpha * progress) * oscillationComponent + endValue;
			
			[node setScale:value];
			
		}]];
	});
}

- (void) bounceToPosition:(CGPoint)point scale:(float)scale delay:(float)delay duration:(float)duration bounces:(int)bounces {
	
	CGFloat stiffnessCoefficient = 0.01f;
	
	CGFloat startScale = self.xScale;
	CGFloat endScale   = scale;
	CGFloat diffScale  = endScale - startScale;
	CGFloat coeffScale = startScale - endScale;

	CGFloat startX     = self.position.x;
	CGFloat endX       = point.x;
	CGFloat diffX      = endX - startX;
	CGFloat coeffX     = startX - endX;

	CGFloat startY     = self.position.y;
	CGFloat endY       = point.y;
	CGFloat diffY      = endY - startY;
	CGFloat coeffY     = startY - endY;
	
	CGFloat alphaScale = (diffScale == 0) ? 1 : log2f(stiffnessCoefficient/fabsf(diffScale));
	if (alphaScale > 0) alphaScale = -1.0f * alphaScale;
	
	CGFloat alphaX = (diffX == 0) ? 1 : log2f(stiffnessCoefficient/fabsf(diffX));
	if (alphaX > 0) alphaX = -1.0f * alphaX;
	
	CGFloat alphaY = (diffY == 0) ? 1 : log2f(stiffnessCoefficient/fabsf(diffY));
	if (alphaY > 0) alphaY = -1.0f * alphaY;
	
	CGFloat numberOfPeriods = bounces/2 + 0.5;
	CGFloat omega           = numberOfPeriods * 2*M_PI;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self runAction:[SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
			
			CGFloat progress = elapsedTime / duration;
			CGFloat oscillationComponent = cos(omega * progress);
			
			CGFloat valueScale	= coeffScale * pow(M_E, alphaScale * progress) * oscillationComponent + endScale;
			CGFloat valueX      = coeffX     * pow(M_E, alphaX     * progress) * oscillationComponent + endX;
			CGFloat valueY      = coeffY     * pow(M_E, alphaY     * progress) * oscillationComponent + endY;
						
			node.position = CGPointMake(valueX, valueY);
			[node setScale:valueScale];
			
		}]];
	});
}

- (void) animateToAlpha:(float)alpha delay:(float)delay duration:(float)duration {
	
	CGFloat startAlpha = self.alpha;
	CGFloat alphaDiff  = alpha - startAlpha;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self runAction:[SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
			
			CGFloat progress = elapsedTime / duration;
			
			CGFloat value = startAlpha + alphaDiff * progress;
			
			node.alpha = value;
			
		}]];
	});
	
}

- (void) animateToScale:(float)scale delay:(float)delay duration:(float)duration {
	
	CGFloat startScale = self.xScale;
	CGFloat scaleDiff  = scale - startScale;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self runAction:[SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
			
			CGFloat progress = elapsedTime / duration;
			
			CGFloat value = startScale + scaleDiff * progress;
			
			[node setScale:value];
			
		}]];
	});
	
}

@end
