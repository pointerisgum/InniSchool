//
//  AppDelegate.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 4. 27..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "TWTSideMenuViewController.h"
//야호
@interface AppDelegate : UIResponder <UIApplicationDelegate, TWTSideMenuViewControllerDelegate>
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong) id<GAITracker> tracker;
@property (nonatomic, strong) TWTSideMenuViewController *sideMenuViewController;
- (void)initViewControllers;
- (void)showMainView;
- (void)showOnlyMainView;
- (void)showLoginView;
@end

/*
 innitest1
 1q2w3e4r
 */

/*
 com.innisfree.innischool
 ver : 2.5
 */
