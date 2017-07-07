//
//  PageViewController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 3/2/14.
//  Copyright (c) 2014 Paul Ossenbruggen. All rights reserved.
//

#import "PageViewController.h"
#import "MatchViewControllerIOS.h"
#import "FothelloGame.h"
#import "NSArray+Holes.h"
#import "EngineStrong.h"

@interface PageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic) NSMutableArray<MatchViewControllerIOS *> *activeControllers;

@end

@implementation PageViewController

- (UIViewController *)viewControllerForPageIndex:(NSInteger)index
{
    UIViewController *vc = [self.activeControllers objectAtCheckedIndex:index + 1];
    
    if (vc && vc != (id) [NSNull null]) { return vc; }

    if (index == -1) { return nil; }

    FothelloGame *game = [FothelloGame sharedInstance];
    NSArray<NSString *> *matchOrder = [game matchOrder];
    NSDictionary<NSString *, Match *> *matches = [game matches];
    
    BOOL inRange = index >= 0 && index < [matches count];
    
    if (inRange)
    {
        MatchViewControllerIOS *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"boardViewController"];
 
        [self.activeControllers setObject:vc atCheckedIndex:index +  1];
        NSString *matchName = matchOrder[index];
        vc.match = matches[matchName];
        return vc;
    }
    return nil;
}
    
- (void)createDefaultSetup
{
    FothelloGame *game = [FothelloGame sharedInstance];
    game.engine = [EngineStrongIOS engine];
    
    NSMutableDictionary<NSString *, Match *> *matches = [game matches];
    if (matches.count == 0)
    {
        game.matchOrder = [@[@"game"] mutableCopy];
        game.matches = [@{@"game": [game createMatchFromKind:PlayerKindSelectionHumanVComputer difficulty:DifficultyEasy]} mutableCopy];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(MatchViewControllerIOS *)viewController
{
    NSUInteger index = viewController.pageIndex;
    return [self viewControllerForPageIndex:(index + 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(MatchViewControllerIOS *)viewController
{
    NSUInteger index = viewController.pageIndex;
    return [self viewControllerForPageIndex:(index - 1)];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _activeControllers = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataSource = self;
    
    [self createDefaultSetup];
    
    UIViewController *page = [self viewControllerForPageIndex:0];
    if (page != nil)
    {
        [self setViewControllers:@[page]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
    }
}

@end
