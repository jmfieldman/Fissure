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



#define NUM_LEVELS              36
#define NUM_LEVEL_ROWS          6
#define NUM_LEVEL_COLS          6
#define MENU_BUTTON_VERT_INSET  10
#define MENU_BUTTON_HORZ_INSET  10

#define MENU_SIZE_RATIO         0.85

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
		[_menuButton addTarget:self action:@selector(pressedMenu:) forControlEvents:UIControlEventTouchUpInside];
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
		#if 0
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
		
		/* Create level menu */
		_levelButtons = [NSMutableArray array];
		
		_levelMenuView = [[UIView alloc] initWithFrame:self.view.bounds];
		_levelMenuView.alpha = 0;
		_levelMenuView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
		[self.view addSubview:_levelMenuView];
		
		UIButton *closeMenu = [UIButton buttonWithType:UIButtonTypeCustom];
		closeMenu.frame = _levelMenuView.bounds;
		[closeMenu addTarget:self action:@selector(pressedCloseMenu:) forControlEvents:UIControlEventTouchDown];
		[_levelMenuView addSubview:closeMenu];
		
		int menuWidth    = self.view.bounds.size.width  * MENU_SIZE_RATIO;
		int menuHeight   = self.view.bounds.size.height * MENU_SIZE_RATIO;
		
		int initialXOffset = (self.view.bounds.size.width - menuWidth) / 2;
		int initialYOffset = self.view.bounds.size.height - menuHeight;
		
		int buttonWidth  = (menuWidth  - (NUM_LEVEL_COLS+1) * MENU_BUTTON_HORZ_INSET) / NUM_LEVEL_COLS;
		int buttonHeight = (menuHeight - (NUM_LEVEL_ROWS+1) * MENU_BUTTON_VERT_INSET) / NUM_LEVEL_ROWS;
		int buttonOffsetX = buttonWidth  + MENU_BUTTON_HORZ_INSET;
		int buttonOffsetY = buttonHeight + MENU_BUTTON_VERT_INSET;
		
		int levelIndex = 0;
		for (int r = 0; r < NUM_LEVEL_ROWS; r++) {
			for (int c = 0; c < NUM_LEVEL_COLS; c++) {
				UIButton *levelButton = [UIButton buttonWithType:UIButtonTypeCustom];
				levelButton.backgroundColor = [UIColor redColor];
				levelButton.frame = CGRectMake(c * buttonOffsetX + MENU_BUTTON_HORZ_INSET + initialXOffset,
											   r * buttonOffsetY + MENU_BUTTON_VERT_INSET + initialYOffset,
											   buttonWidth,
											   buttonHeight);
				NSString *levelName = [[LevelManager sharedInstance] levelIdAtPosition:levelIndex];
				int dim = ([UIScreen mainScreen].bounds.size.height < 482) ? 480 : 568;
				UIImage *bImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%d-thumb", levelName, dim]];
				[levelButton setImage:bImage forState:UIControlStateNormal];
				levelButton.tag = levelIndex;
				[levelButton addTarget:self action:@selector(pressedLevel:) forControlEvents:UIControlEventTouchUpInside];
				
				levelButton.layer.shadowColor   = [UIColor blackColor].CGColor;
				levelButton.layer.shadowOffset  = CGSizeMake(0,0);
				levelButton.layer.shadowOpacity = 0.5;
				levelButton.layer.shadowRadius  = 2;
				levelButton.layer.shouldRasterize = YES;
				levelButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
				
				[_levelMenuView addSubview:levelButton];
				[_levelButtons addObject:levelButton];
				levelIndex++;
			}
		}
		
		/* Load initial level */
		[self loadLevelId:@"intro-1"];
	}
	return self;
}

/* We don't want a status bar */
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void) pressedLevel:(UIButton*)button {
	
}

- (void) pressedMenu:(UIButton*)button {
	for (UIButton *b in _levelButtons) {
		b.alpha = 0;
		
		float delay = 0.2 + floatBetween(0, 0.25);
		[UIView animateWithDuration:0.25
							  delay:delay
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 b.alpha = 1;
						 } completion:nil];
		
		SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:@"transform"];
		bounceAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)];
		bounceAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
		bounceAnimation.duration = 0.5f;
		bounceAnimation.beginTime = CACurrentMediaTime() + delay + 0.1;
		bounceAnimation.removedOnCompletion = NO;
		bounceAnimation.fillMode = kCAFillModeForwards;
		bounceAnimation.numberOfBounces = 3;
		bounceAnimation.stiffness = SKBounceAnimationStiffnessLight;
		
		[b.layer addAnimation:bounceAnimation forKey:nil];
		
	}
	
	[UIView animateWithDuration:0.25
						  delay:0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 _levelMenuView.alpha = 1;
					 } completion:nil];
}

- (void) pressedCloseMenu:(UIButton*)button {
	[UIView animateWithDuration:0.25
						  delay:0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 _levelMenuView.alpha = 0;
					 } completion:nil];
}

- (void) pressedRestart:(UIButton*)button {
	[_scene resetControlsToInitialPositions];
}

- (void) pressedNext:(UIButton*)button {
	[self pressedSnap:nil];
	[_scene forceWin];
}

- (void) pressedSnap:(UIButton*)button {
	int menuWidth    = self.view.bounds.size.width  * MENU_SIZE_RATIO;
	int menuHeight   = self.view.bounds.size.height * MENU_SIZE_RATIO;
	
	int buttonWidth  = (menuWidth  - (NUM_LEVEL_COLS+1) * MENU_BUTTON_HORZ_INSET) / NUM_LEVEL_COLS;
	int buttonHeight = (menuHeight - (NUM_LEVEL_ROWS+1) * MENU_BUTTON_VERT_INSET) / NUM_LEVEL_ROWS;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [NSString stringWithFormat:@"%@/thumbs", [paths objectAtIndex:0]];
	[fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	
	CGSize imageSize = CGSizeMake(buttonWidth, buttonHeight);
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.0);
    [_sceneView drawViewHierarchyInRect:CGRectMake(0, 0, imageSize.width, imageSize.height) afterScreenUpdates:YES];
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	NSData *imgData = UIImagePNGRepresentation(screenshot);
	[imgData writeToFile:[NSString stringWithFormat:@"%@/%@-%d-thumb@2x~iphone.png", documentsDirectory, _currentLevelId, ([UIScreen mainScreen].bounds.size.height < 482) ? 480 : 568] atomically:YES];
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
