//
//  GameEngineViewController.m
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import "GameEngineViewController.h"
#import "FissureScene.h"
#import "LevelManager.h"

@interface GameEngineViewController ()

@end

@implementation GameEngineViewController

SINGLETON_IMPL(GameEngineViewController);

- (id)init {
	if ((self = [super init])) {

		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
		self.view.backgroundColor = [UIColor redColor];
		
		_sceneView = [[SKView alloc] initWithFrame:self.view.bounds];
		_sceneView.showsFPS       = NO;
		_sceneView.showsNodeCount = NO;
		_sceneView.showsDrawCount = NO;
		_sceneView.showsPhysics   = NO;
		[self.view addSubview:_sceneView];
		
		_scene = [[FissureScene alloc] initWithSize:self.view.bounds.size];
		_scene.sceneDelegate = self;
		[_sceneView presentScene:_scene];
		
		
		/* Add buttons */
		_menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_menuButton.frame = CGRectMake(self.view.bounds.size.width - 40, 0, 40, 40);
		[self.view addSubview:_menuButton];
		
		UIImageView *mImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_menu"]];
		mImage.frame = CGRectMake(15, 5, 20, 20);
		mImage.alpha = 0.25;
		[_menuButton addSubview:mImage];
		
		_restartButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_restartButton.frame = CGRectMake(self.view.bounds.size.width - 40, self.view.bounds.size.height - 40, 40, 40);
		[_restartButton addTarget:self action:@selector(pressedRestart:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:_restartButton];
		
		UIImageView *rImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_restart"]];
		rImage.frame = CGRectMake(15, 15, 20, 20);
		rImage.alpha = 0.25;
		[_restartButton addSubview:rImage];

		/* Thumbnails */
		#if 1
		{
		_snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_snapButton.frame = CGRectMake(0, 0, 40, 40);
		[_snapButton addTarget:self action:@selector(pressedSnap:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:_snapButton];
		
		UIImageView *mImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_menu"]];
		mImage.frame = CGRectMake(15, 5, 20, 20);
		mImage.alpha = 0.25;
		[_snapButton addSubview:mImage];
		
		_nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_nextButton.frame = CGRectMake(0, self.view.bounds.size.height - 40, 40, 40);
		[_nextButton addTarget:self action:@selector(pressedNext:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:_nextButton];
		
		UIImageView *rImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_restart"]];
		rImage.frame = CGRectMake(15, 15, 20, 20);
		rImage.alpha = 0.25;
		[_nextButton addSubview:rImage];
		}
		#endif
		
		/* Load initial level */
		[self loadLevelId:@"warp-nonsense"];
	}
	return self;
}

/* We don't want a status bar */
- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void) pressedRestart:(UIButton*)button {
	[_scene resetControlsToInitialPositions];
}

- (void) pressedNext:(UIButton*)button {
	[_scene forceWin];
}

- (void) pressedSnap:(UIButton*)button {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [NSString stringWithFormat:@"%@/thumbs", [paths objectAtIndex:0]];
	[fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	
	CGSize imageSize = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.0);
    [_sceneView drawViewHierarchyInRect:_sceneView.bounds afterScreenUpdates:YES];
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	NSData *imgData = UIImagePNGRepresentation(screenshot);
	[imgData writeToFile:[NSString stringWithFormat:@"%@/%@-thumb.png", documentsDirectory, _currentLevelId] atomically:YES];
}

#pragma mark FissureSceneDelegate methods

- (void) loadLevelId:(NSString*)levelId {
	_currentLevelId = levelId;
	NSDictionary *levelDic = [[LevelManager sharedInstance] levelDictionaryForId:_currentLevelId];
	
	[_scene loadFromLevelDictionary:levelDic];
	EXLog(MODEL, DBG, @"Loading level %@", _currentLevelId);
}

- (void) sceneAllTargetsLit {
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
	[[LevelManager sharedInstance] setComplete:_currentLevelId];
}

- (void) sceneReadyToTransition {
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	
	int currentLevelNum = [[LevelManager sharedInstance] levelNumForId:_currentLevelId];
	currentLevelNum = (currentLevelNum + 1) % [LevelManager sharedInstance].levelCount;
	[self loadLevelId:[[LevelManager sharedInstance] levelIdAtPosition:currentLevelNum]];
}

@end
