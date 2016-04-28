//
//  NewGameViewController.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/26/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DismissDelegate <NSObject>
- (void)dismissed;
@end

@interface NewGameViewController : NSViewController
@property (nonatomic, weak) id<DismissDelegate> delegate;
@end
