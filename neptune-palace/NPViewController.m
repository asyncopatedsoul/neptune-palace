//
//  NPViewController.m
//  neptune-palace
//
//  Created by Michael Garrido on 2/23/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

#import "NPViewController.h"
#import "NPMyScene.h"

@implementation NPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    //SKScene * scene = [NPMyScene sceneWithSize:skView.bounds.size];
    SKScene * scene = [NPMyScene sceneWithSize:CGSizeMake(536.0, 320.0)];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    //scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskLandscape;
        //return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
