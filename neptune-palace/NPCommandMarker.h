//
//  NPCommandMarker.h
//  neptune-palace
//
//  Created by Michael Garrido on 2/24/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class NPMyScene;

@interface NPCommandMarker : SKNode {
    int movementDirection;
    float rotation;
    
    SKSpriteNode* bodyNode;
    SKSpriteNode* selectedHighlight;
    SKSpriteNode* directionHighlight;
    SKShapeNode* facingDirection;
    
    NPMyScene* delegate;
}

@property (assign,readonly) int movementDirection;
@property (atomic,retain) SKSpriteNode* bodyNode;
@property (atomic,retain) NPMyScene* delegate;

-(id) initWithDirection:(int)direction AtPoint: (CGPoint)origin;
-(void) showSelectedDirection:(int)direction;
-(void) confirmDirection;
-(void) destroy;

@end
