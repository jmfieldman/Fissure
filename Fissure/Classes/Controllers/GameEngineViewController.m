//
//  GameEngineViewController.m
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import "GameEngineViewController.h"
#import "FissureScene.h"

@interface GameEngineViewController ()

@end

@implementation GameEngineViewController

SINGLETON_IMPL(GameEngineViewController);

- (id)init {
	if ((self = [super init])) {

		self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		self.view.backgroundColor = [UIColor redColor];
		
		_sceneView = [[SKView alloc] initWithFrame:self.view.bounds];
		_sceneView.showsFPS = YES;
		_sceneView.showsNodeCount = YES;
		_sceneView.showsDrawCount = YES;
		[self.view addSubview:_sceneView];
		
		FissureScene *scene = [[FissureScene alloc] initWithSize:self.view.bounds.size];
		[_sceneView presentScene:scene];
	}
	return self;
}



@end
