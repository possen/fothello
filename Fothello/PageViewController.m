//
//  PageViewController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 3/2/14.
//  Copyright (c) 2014 Paul Ossenbruggen. All rights reserved.
//

#import "PageViewController.h"
#import "MatchViewController.h"
#import "FothelloGame.h"
#import "NSArray+Holes.h"

@interface PageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic) NSMutableArray<MatchViewController *> *activeControllers;

@end

@implementation PageViewController

- (UIViewController *)viewControllerForPageIndex:(NSInteger)index
{
    UIViewController *vc = [self.activeControllers objectAtCheckedIndex:index + 1];
    
    if (vc && vc != (id) [NSNull null])
        return vc;
    
    if (index == -1)
    {
        MatchViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"gameViewController"];
        
        [self.activeControllers setObject:vc atCheckedIndex:index + 1];
        return vc;
    }

    NSArray<NSString *> *matchOrder = [[FothelloGame sharedInstance] matchOrder];
    NSDictionary<NSString *, Match *> *matches = [[FothelloGame sharedInstance] matches];

    BOOL inRange = index >= 0 && index < [matches count];
    
    if (inRange)
    {
        MatchViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"boardViewController"];
 
        [self.activeControllers setObject:vc atCheckedIndex:index +  1];
        NSString *matchName = matchOrder[index];
        vc.match = matches[matchName];
        return vc;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(MatchViewController *)viewController
{
    NSUInteger index = viewController.pageIndex;
    return [self viewControllerForPageIndex:(index + 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(MatchViewController *)viewController
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
    
    UIViewController *page = [self viewControllerForPageIndex:0];
    if (page != nil)
    {
        [self setViewControllers:@[page]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
