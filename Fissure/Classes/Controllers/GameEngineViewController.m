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

		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
		self.view.backgroundColor = [UIColor redColor];
		
		_sceneView = [[SKView alloc] initWithFrame:self.view.bounds];
		_sceneView.showsFPS = YES;
		_sceneView.showsNodeCount = YES;
		_sceneView.showsDrawCount = YES;
		_sceneView.showsPhysics   = NO;
		[self.view addSubview:_sceneView];
		
		FissureScene *scene = [[FissureScene alloc] initWithSize:self.view.bounds.size];
		PersistentDictionary *d = [PersistentDictionary dictionaryWithName:@"level_info"];
		[scene loadFromLevelDictionary:(d.dictionary[@"levels"])[@"test2"]];
		[_sceneView presentScene:scene];
	}
	return self;
}

/* We don't want a status bar */
- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
