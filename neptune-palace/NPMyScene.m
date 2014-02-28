//
//  NPMyScene.m
//  neptune-palace
//
//  Created by Michael Garrido on 2/23/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

#import "NPMyScene.h"
#import "NPSeaCreature.h"
#import "NPCommandMarker.h"

@implementation NPMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        self.physicsWorld.contactDelegate = self;
        
        self.backgroundColor = [SKColor colorWithRed:0.2 green:1.0 blue:0.8 alpha:1.0];
        
        isGameOver = NO;
        isGameStarted = NO;
        
        // TODO set command limit from plist or server
        commandLimit = 3;
        commands = [[NSMutableArray alloc] init];

        creatureLimit = 15;
        creatures = [[NSMutableArray alloc] init];
        protectedCreatures = [[NSMutableArray alloc] init];
        
        [self startGame];
        
    }
    return self;
}

-(void) startGame {
    
    [self removeAllChildren];
    [self removeAllActions];
    
    [creatures removeAllObjects];
    [commands removeAllObjects];
    [protectedCreatures removeAllObjects];
    
    touchStart = CGPointZero;
    touchCurrent = CGPointZero;
    nextCreatureSpawnTime = 0;
    pendingCommand = nil;
    
    // TODO load from plist or server
    
    NSString* path = [[ NSBundle mainBundle] bundlePath];
    NSString* finalPath = [ path stringByAppendingPathComponent:@"GameData.plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    NSArray* creaturesData = [NSArray arrayWithArray:[plistData objectForKey:@"creatures"]];
    
    [self spawnCreaturesFromData:creaturesData];
    
    // setup gameover state
    
    SKLabelNode* gameOverLabel = [SKLabelNode node];
    gameOverLabel.text = @"Game Over";
    gameOverLabel.fontColor = [UIColor redColor];
    
    gameOverRoot = [SKNode node];
    gameOverRoot.position = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    gameOverRoot.hidden = YES;
    [gameOverRoot addChild:gameOverLabel];
    
    [self addChild:gameOverRoot];
    
    isGameOver = NO;
    isGameStarted = YES;
    
}

-(CGPoint) pointAtGridX:(int)x AndGridY:(int)y {
    
    float positionX = x*kTileWidth;
    float positionY = y*kTileWidth;
    
    return CGPointMake(positionX,positionY);
}

-(void) spawnCreaturesFromData:(NSArray*)creaturesData {
    
    NSLog(@"creatures data: %@",creaturesData);
    
     [creaturesData enumerateObjectsUsingBlock:^(id creatureData, NSUInteger idx, BOOL *stop) {
         
         int newCreatureClass = [[creatureData valueForKey:@"class"] intValue];
         
         [self spawnCreatureWithClass:newCreatureClass Size:[[creatureData valueForKey:@"size"] intValue] Direction:[[creatureData valueForKey:@"direction"] intValue] AtX:[[creatureData valueForKey:@"x"] intValue] AndY:[[creatureData valueForKey:@"y"] intValue]];
         
     }];
}

-(void) spawnCreatureWithClass:(int)class Size:(int)size Direction:(int)direction AtX:(int)x AndY:(int)y {
    
    NSLog(@"spawning creature: class %i, size %i, direction %i, x %i, y %i",class,size,direction,x,y);
    
    CGPoint newCreaureOrigin = [self pointAtGridX:x AndGridY:y];
    
    NPSeaCreature* creature = [[NPSeaCreature alloc] initWithCreatureClass:class AndSizeClass:size AtPoint:newCreaureOrigin];
    
    if (class==0) {
        [protectedCreatures addObject:creature];
    }
    
    [self addChild:creature];
    [creatures addObject:creature];
    
    if (direction!=0) {
        [creature startSwimmingInDirection:direction];
    }
    
}

-(void) spawnCreaturesContinuously {
    
    double currentTime = CACurrentMediaTime();
    
    if ( currentTime > nextCreatureSpawnTime && [creatures count]<creatureLimit) {
        
        NSLog(@"creature count: %i",[creatures count]);
        
        float timeToNextSpawn = [self randomValueBetween:1.0 andValue:3.0];
        
        nextCreatureSpawnTime = currentTime+timeToNextSpawn;
        
        int newCreatureClass = 1;
        int newCreatureSize = floorf([self randomValueBetween:0 andValue:3]);
        int newCreatureX = 0;
        int newCreatureY = floorf([self randomValueBetween:0 andValue:8]);
        int newCreatureDirection = 2;
        
        [self spawnCreatureWithClass:newCreatureClass Size:newCreatureSize Direction:newCreatureDirection AtX:newCreatureX AndY:newCreatureY];
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    if (isGameOver) {
        // TODO reset level
        [self startGame];
    }
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        NSLog(@"touch began location:%f, %f",location.x,location.y);
        
        [self placeCommandAtPoint:location];
        
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        //NSLog(@"touch moved location:%f, %f",location.x,location.y);
        touchCurrent = location;
        
        CGFloat angle = atan2f(touchCurrent.y - touchStart.y, touchCurrent.x - touchStart.x);
        
        //NSLog(@"angle between touches: %f",angle);
        
        if (angle>M_PI/4 && angle<M_PI*3/4) {
            [pendingCommand showSelectedDirection:kUpDirection];
        } else if (angle<M_PI/4 && angle>-M_PI/4) {
            [pendingCommand showSelectedDirection:kRightDirection];
        } else if (angle<-M_PI/4 && angle>-M_PI*3/4) {
            [pendingCommand showSelectedDirection:kDownDirection];
        } else if (angle<-M_PI*3/4 || angle>M_PI*3/4) {
            [pendingCommand showSelectedDirection:kLeftDirection];
        }
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [touchMask removeFromParent];
    touchMask = nil;
    [self confirmCommand];
    
}

-(void) placeCommandAtPoint:(CGPoint)rawPosition {
    
    float xPadding = 0;//5.0;
    float yPadding = 15.0;
    
    // pad raw position for more perceived accuracy of placement
    CGPoint paddedPosiiton = CGPointMake(rawPosition.x+xPadding, rawPosition.y+yPadding);
    
    // round off to nearest tile
    CGPoint gridPosition = [self gridPositionNearValue:paddedPosiiton];
    
    NPCommandMarker* commandMarker = [[NPCommandMarker alloc] initWithDirection:1 AtPoint:gridPosition];
    
    [self addChild:commandMarker];
    
    touchStart = rawPosition;
    pendingCommand = commandMarker;
}

-(void) confirmCommand {
    
    // remove oldest command, if at limit
    if ([commands count]==commandLimit) {
        NPCommandMarker* command = (NPCommandMarker*)[commands objectAtIndex:0];
        
        [self removeCommand:command];
    }
    
    [pendingCommand confirmDirection];
    pendingCommand.delegate = self;
    [commands addObject:pendingCommand];
    touchStart = CGPointZero;
    touchCurrent = CGPointZero;
    pendingCommand = nil;

    NSLog(@"active commands:%@",commands);
}

-(void) removeCommand:(NPCommandMarker*)command {
    
    if ([commands containsObject:command]) {
        
        [commands removeObject:command];
        [command destroy];
        
    }
    
}

-(void) removeCreature:(NPSeaCreature *)creature {
    
    if ([creatures containsObject:creature]) {
        [creatures removeObject:creature];
        
        if ([protectedCreatures containsObject:creature]) {
            [protectedCreatures removeObject:creature];
        }
        
        [creature destroy];
    }
}

#pragma mark Utilities

- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

-(CGPoint) gridPositionNearValue:(CGPoint)rawPosition {
    float gridX;
    float gridY;
    
    gridX = floorf(rawPosition.x/kTileWidth)*kTileWidth;
    gridY = floorf(rawPosition.y/kTileWidth)*kTileWidth;
    
    return CGPointMake(gridX, gridY);
}

#pragma mark Animation Loop

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    //game over condition
    if (isGameStarted && [protectedCreatures count]==0) {
        [self endGame];
    }
    
    // creature spawning
    [self spawnCreaturesContinuously];


    // creature movement and commands
    [self enumerateChildNodesWithName:@kNodeCreatureName usingBlock:^(SKNode *nodeB, BOOL *stop) {
        
        NPSeaCreature* creature = (NPSeaCreature*)nodeB;
        
        [creature wrapMovement];
        [creature clearLastCommand];
        
        [self enumerateChildNodesWithName:@kNodeCommandName usingBlock:^(SKNode *nodeA, BOOL *stop) {
            
            NPCommandMarker* command = (NPCommandMarker*)nodeA;
            //NSLog(@"command:%@",command);
        
            if ([command.bodyNode intersectsNode:creature.bodyNode]) {
                //NSLog(@"command intersects creature");
                
                float xProximity = fabsf(command.position.x-creature.position.x);
                float yProximity = fabsf(command.position.y-creature.position.y);
                
                if (xProximity<5.0 && yProximity<5.0) {
                    NSLog(@"command intersects creature");
                    [creature updateDirectionFromCommand:command];
                }
            }
                
        }];

    }];
        
        
    
}

-(void) didBeginContact:(SKPhysicsContact *)contact {
    
    NSLog(@"did begin contact:%@",contact);
    
    SKPhysicsBody *firstBody, *secondBody;
    
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
    
    if (firstBody.categoryBitMask==1 && secondBody.categoryBitMask==1) {
        // both sea creatures
        
        NPSeaCreature* creatureA = (NPSeaCreature*)firstBody.node;
        NPSeaCreature* creatureB = (NPSeaCreature*)secondBody.node;
        
        if ([creatureA willEatCreature:creatureB]) {
            [creatureA eatCreature:creatureB];
        } else if ([creatureB willEatCreature:creatureA]) {
            [creatureB eatCreature:creatureA];
        }
    }
    
    
    
}

-(void) endGame {
    
    NSLog(@"game over");
    
    gameOverRoot.hidden = NO;
    
    isGameStarted = NO;
    isGameOver = YES;
}

@end
