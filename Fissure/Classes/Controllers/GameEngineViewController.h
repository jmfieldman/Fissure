//
//  GameEngineViewController.h
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FissureScene.h"

@interface GameEngineViewController : UIViewController <FissureSceneDelegate> {
	/* Scene view */
	SKView *_sceneView;
	
	/* Scene */
	FissureScene *_scene;
	
	/* Controls */
	UIButton *_menuButton;
	UIButton *_restartButton;
	
	/* Making thumbnails */
	UIButton *_snapButton;
	UIButton *_nextButton;
	
	/* Current level */
	NSString *_currentLevelId;
	
	/* Level menu */
	UIView         *_levelMenuView;
	NSMutableArray *_levelButtons;
	NSMutableArray *_starImageViews;
	NSString       *_menuToLevelId;
	UIImageView    *_titleImage;
}

SINGLETON_INTR(GameEngineViewController);

@end
