//
//  NPCommandMarker.m
//  neptune-palace
//
//  Created by Michael Garrido on 2/24/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

#import "NPCommandMarker.h"
#import "NPMyScene.h"

@implementation NPCommandMarker

@synthesize movementDirection,bodyNode,delegate;

-(id) initWithDirection:(int)direction AtPoint:(CGPoint)origin{
    self = [super init];
    
    if (self)
    {
        self.position = origin;
        self.userInteractionEnabled = YES;
        self.name = @kNodeCommandName;
        
        movementDirection = direction;
        
        bodyNode = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(kTileWidth, kTileWidth)];
        
        selectedHighlight = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.95 green:0.88 blue:0.55 alpha:0.5] size:CGSizeMake(kTileWidth,kTileWidth)];
        
        directionHighlight = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.95 green:0.88 blue:0.55 alpha:0.5] size:CGSizeMake(kTileWidth,kTileWidth)];
        
        facingDirection = [SKShapeNode node];
        facingDirection.position = CGPointMake(-10.0, -10.0);
        CGPoint triangle[] = {CGPointMake(0.0, 0.0), CGPointMake(10.0, 20.0), CGPointMake(20.0, 0.0)};
        CGMutablePathRef facingPointer = CGPathCreateMutable();
        CGPathAddLines(facingPointer, NULL, triangle, 3);
        facingDirection.path = facingPointer;
        facingDirection.lineWidth = 1.0;
        facingDirection.fillColor = [SKColor whiteColor];
        facingDirection.strokeColor = [SKColor clearColor];
        facingDirection.glowWidth = 0.0;
        
        [self addChild:bodyNode];
        [self addChild:selectedHighlight];
        [self addChild:directionHighlight];
        [self addChild:facingDirection];
        
        [self updateDirection];
    }
    
    return self;
}

-(void) showSelectedDirection:(int)direction {
    
    CGPoint directionHighlightPosition;
    
    switch (direction) {
        case kUpDirection:
            directionHighlightPosition = CGPointMake(0, kTileWidth);
            break;
        case kRightDirection:
            directionHighlightPosition = CGPointMake(kTileWidth, 0);
            break;
        case kDownDirection:
            directionHighlightPosition = CGPointMake(0, -kTileWidth);
            break;
        case kLeftDirection:
            directionHighlightPosition = CGPointMake(-kTileWidth, 0);
            break;
    }
    
    movementDirection = direction;
    directionHighlight.position = directionHighlightPosition;
}

-(void) updateDirection {
    switch (movementDirection) {
        case kUpDirection:
            rotation = 0;
            break;
        case kRightDirection:
            rotation = -M_PI/2;
            break;
        case kDownDirection:
            rotation = M_PI;
            break;
        case kLeftDirection:
            rotation = M_PI/2;
            break;
    }
    
    SKAction* unitRotateAction = [SKAction rotateToAngle:rotation duration:0.1 shortestUnitArc:YES];
    
    [self runAction:unitRotateAction];
}

-(void) destroy {
    
    //TODO check if still referenced by a creature
    
    [self removeFromParent];
    
}

-(void) confirmDirection {
    [self updateDirection];
    selectedHighlight.hidden = YES;
    directionHighlight.hidden = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        NSLog(@"command touched");
        [delegate removeCommand:self];
    }
}

@end
