//
//  NPMyScene.h
//  neptune-palace
//

//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class NPCommandMarker,NPSeaCreature;

@interface NPMyScene : SKScene <SKPhysicsContactDelegate> {
    
    bool isGameOver;
    bool isGameStarted;
    
    double nextCreatureSpawnTime;
    
    NSMutableArray* commands;
    NSMutableArray* creatures;
    
    NSMutableArray* protectedCreatures;
    
    CGPoint touchStart;
    CGPoint touchCurrent;
    
    SKSpriteNode* touchMask;
    
    SKNode* gameOverRoot;
    
    int commandLimit;
    int creatureLimit;
    
    NPCommandMarker* pendingCommand;
}

-(void) removeCommand:(NPCommandMarker*)command;
-(void) removeCreature:(NPSeaCreature*)creature;

@end
