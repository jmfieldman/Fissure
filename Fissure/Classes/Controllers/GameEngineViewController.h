//
//  GameEngineViewController.h
//  Fissure
//
//  Created by Jason Fieldman on 4/20/14.
//  Copyright (c) 2014 fieldman.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameEngineViewController : UIViewController {
	/* Scene view */
	SKView *_sceneView;
}

SINGLETON_INTR(GameEngineViewController);

@end
