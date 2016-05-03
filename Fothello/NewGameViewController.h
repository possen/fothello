//
//  NewGameViewController.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/26/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FothelloGame.h"

@protocol DismissDelegate <NSObject>
- (void)dismissed:(BOOL)cancel playerKind:(PlayerKindSelection)playerKind difficulty:(Difficulty)difficulty;
@end

@interface NewGameViewController : NSViewController
@property (nonatomic, weak) id<DismissDelegate> delegate;
@end
