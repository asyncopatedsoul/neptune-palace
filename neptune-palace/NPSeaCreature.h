//
//  NPSeaCreature.h
//  neptune-palace
//
//  Created by Michael Garrido on 2/23/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class NPCommandMarker, NPMyScene;

@interface NPSeaCreature : SKNode
{
    NPMyScene* scene;
    
    NPCommandMarker* currentCommandMarker;
    
    SKSpriteNode* bodyNode;
    SKShapeNode* facingDirection;
    CGPoint destination;
    int creatureClass;
    int sizeClass;
    int movementDirection;
    float movementSpeed;
    float rotation;
    float deltaX;
    float deltaY;
    
    float healthLevel;
    float foodLevel;
    
    NSArray* levelUpLimits;
    
    bool willReceiveCommands;
}
@property (atomic,retain) SKSpriteNode* bodyNode;
@property (assign,readwrite) int creatureClass;
@property (assign,readwrite) int sizeClass;
@property (assign,readwrite) float movementSpeed;

-(id) initWithCreatureClass: (int)_creatureClass AndSizeClass: (int)_sizeClass AtPoint: (CGPoint)origin;
-(void) startSwimmingInDirection: (int)_movementDirection;

-(void) updateDirectionFromCommand:(NPCommandMarker*)command;

-(void) clearLastCommand;

-(bool) willEatCreature:(NPSeaCreature*)otherCreature;

-(void) eatCreature:(NPSeaCreature*)otherCreature;

-(void) wrapMovement;

-(void) destroy;

@end
