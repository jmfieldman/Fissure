//
//  GameEngineViewController.h
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FissureScene.h"

@interface GameEngineViewController : UIViewController {
	/* Scene view */
	SKView *_sceneView;
	
	/* Scene */
	FissureScene *_scene;
	
	/* Controls */
	UIButton *_menuButton;
	UIButton *_restartButton;
}

SINGLETON_INTR(GameEngineViewController);

@end
