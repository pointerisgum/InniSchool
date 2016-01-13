//
//  UIViewController+YM.m
//  EmAritaum
//
//  Created by Kim Young-Min on 2014. 3. 19..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import "UIViewController+YM.h"
#import "MFSideMenuContainerViewController.h"
#import "TWTSideMenuViewController.h"

@implementation UIViewController (YM)

- (void)viewWillAppear:(BOOL)animated
{
    [GMDCircleLoader hide];
}

- (UIBarButtonItem *)homeMenuButtonItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 40, 40);
    [btn_BarItem addTarget:self action:@selector(goHome:) forControlEvents:UIControlEventTouchUpInside];
    
    [btn_BarItem setImage:BundleImage(@"home_n.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)blackNaviBackButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    [btn_BarItem setImage:BundleImage(@"back_b.png") forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(leftBackSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
//    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 50, 0, 0);
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)whiteNaviBackButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    [btn_BarItem setImage:BundleImage(@"icon_top_back.png") forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(leftBackSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)modalCloseBarButtonItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 40, 40);
    [btn_BarItem setTitle:@"닫기" forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(goModalBack:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)writeNaviButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 26, 40);
    [btn_BarItem setImage:BundleImage(@"writeicon.png") forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(goWrite:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)blackWriteNaviButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 26, 40);
    [btn_BarItem setImage:BundleImage(@"private_write.png") forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(goWrite:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)modalCancelButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 40, 40);
    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem setTitle:@"취소" forState:0];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    [btn_BarItem addTarget:self action:@selector(goModalBack:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)modalConfirmButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 40, 40);
    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem setTitle:@"확인" forState:0];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    [btn_BarItem addTarget:self action:@selector(goDone:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)modalCloseBarButtonItemBlack
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 40, 40);
    [btn_BarItem setImage:BundleImage(@"chat_add.png") forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(goModalBack:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)EmptyleftBackMenuBarButtonItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 26, 40);
    [btn_BarItem setImage:BundleImage(@"") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightMenuBarButtonItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 48, 38);
    [btn_BarItem addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    [btn_BarItem setImage:BundleImage(@"global_n.png") forState:UIControlStateNormal];

//    if( IS_IOS7_LATER )
//    {
//        btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
//        [btn_BarItem setImage:BundleImage(@"globalicon_s.png") forState:UIControlStateNormal];
//    }
//    else
//    {
//        [btn_BarItem setImage:BundleImage(@"global_n@2x.png") forState:UIControlStateNormal];
//    }
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightDoneMenu
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 40, 25);
    [btn_BarItem addTarget:self action:@selector(rightDoneMenuPressed:) forControlEvents:UIControlEventTouchUpInside];
    btn_BarItem.layer.cornerRadius = 5.0f;
    btn_BarItem.layer.borderColor = [UIColor whiteColor].CGColor;
    btn_BarItem.layer.borderWidth = 1.0f;
    
    [btn_BarItem setTitle:@"완료" forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
//    [btn_BarItem setImage:BundleImage(@"global_n.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (void)rightDoneMenuPressed:(UIButton *)btn
{
    
}

- (UIBarButtonItem *)leftMenuBarButtonItemWithWhiteColor:(BOOL)isWhite
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    [btn_BarItem addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);

    if( isWhite )
    {
        [btn_BarItem setImage:BundleImage(@"icon_top_menu.png") forState:UIControlStateNormal];
        [btn_BarItem setImage:BundleImage(@"icon_top_menu_p.png") forState:UIControlStateHighlighted];
    }
    else
    {
        [btn_BarItem setImage:BundleImage(@"list_b.png") forState:UIControlStateNormal];
    }
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightSearchIcon
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    [btn_BarItem addTarget:self action:@selector(searchMenuPress:) forControlEvents:UIControlEventTouchUpInside];
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -35);
    
    [btn_BarItem setImage:BundleImage(@"icon_top_search.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightSearchButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    [btn_BarItem addTarget:self action:@selector(searchButtonPress:) forControlEvents:UIControlEventTouchUpInside];
//    btn_BarItem.layer.cornerRadius = 5.0f;
//    btn_BarItem.layer.borderColor = [UIColor whiteColor].CGColor;
//    btn_BarItem.layer.borderWidth = 1.0f;
    
    [btn_BarItem setTitle:@"검색" forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    
//    btn_BarItem.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    //    [btn_BarItem setImage:BundleImage(@"global_n.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightWriteButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    [btn_BarItem addTarget:self action:@selector(writeMenuPress:) forControlEvents:UIControlEventTouchUpInside];
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -35);
    
    [btn_BarItem setImage:BundleImage(@"icon_top_write.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)leftCancelButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    [btn_BarItem addTarget:self action:@selector(cancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    //    btn_BarItem.layer.cornerRadius = 5.0f;
    //    btn_BarItem.layer.borderColor = [UIColor whiteColor].CGColor;
    //    btn_BarItem.layer.borderWidth = 1.0f;
    
    [btn_BarItem setTitle:@"취소" forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    
//    btn_BarItem.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    //    [btn_BarItem setImage:BundleImage(@"global_n.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightDoneButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    [btn_BarItem addTarget:self action:@selector(doneButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    //    btn_BarItem.layer.cornerRadius = 5.0f;
    //    btn_BarItem.layer.borderColor = [UIColor whiteColor].CGColor;
    //    btn_BarItem.layer.borderWidth = 1.0f;
    
    [btn_BarItem setTitle:@"등록" forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    
    //    btn_BarItem.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    //    [btn_BarItem setImage:BundleImage(@"global_n.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightCloseButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    [btn_BarItem addTarget:self action:@selector(closeButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    //    btn_BarItem.layer.cornerRadius = 5.0f;
    //    btn_BarItem.layer.borderColor = [UIColor whiteColor].CGColor;
    //    btn_BarItem.layer.borderWidth = 1.0f;
    
    [btn_BarItem setTitle:@"닫기" forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    
    //    btn_BarItem.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    //    [btn_BarItem setImage:BundleImage(@"global_n.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (void)closeButtonPress:(UIButton *)btn
{
    
}

- (void)doneButtonPress:(UIButton *)btn
{
    
}

- (NSArray *)rightMenuAndWriteBarButtonItem
{
    UIButton *btn_BarItem1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem1.frame = CGRectMake(0, 0, 50, 40);
    [btn_BarItem1 addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    btn_BarItem1.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    [btn_BarItem1 setImage:BundleImage(@"global_n.png") forState:UIControlStateNormal];

    UIButton *btn_BarItem2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem2.frame = CGRectMake(0, 0, 50, 40);
    [btn_BarItem2 addTarget:self action:@selector(goWritePage:) forControlEvents:UIControlEventTouchUpInside];
    btn_BarItem2.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, -20);
    [btn_BarItem2 setImage:BundleImage(@"pen.png") forState:UIControlStateNormal];

    UIBarButtonItem *barItem1 = [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem1];
    UIBarButtonItem *barItem2 = [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem2];
    
    NSArray *ar = @[barItem1, barItem2];
    
    return ar;
}

- (MFSideMenuContainerViewController *)menuContainerViewController
{
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)rightSideMenuButtonPressed:(id)sender
{
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{
        
    }];
}

- (IBAction)leftSideMenuButtonPressed:(id)sender
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];

//    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
//        
//    }];
}

- (void)searchMenuPress:(id)sender
{
    
}

- (void)searchButtonPress:(id)sender
{
    
}

- (void)writeMenuPress:(id)sender
{
    
}

- (void)cancelButtonPress:(id)sender
{
    
}

- (IBAction)goHome:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"MainNavi"];
    [Util setMainNaviBar:navi.navigationBar];
    
    UIViewController *vc = [navi.viewControllers objectAtIndex:0];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    MFSideMenuContainerViewController *rootViewController = (MFSideMenuContainerViewController *)window.rootViewController;
    UINavigationController *navigationController = rootViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:vc];
    navigationController.viewControllers = controllers;
    [rootViewController setMenuState:MFSideMenuStateClosed];
}

- (void)leftBackSideMenuButtonPressed:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goTab:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)goBack:(id)sender
{
    [self leftBackSideMenuButtonPressed:sender];
}

- (IBAction)goModalBack:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

- (void)goWritePage:(UIButton *)btn
{
    
}

- (void)goWrite:(UIButton *)btn
{
    
}

- (void)goDone:(UIButton *)btn
{
    
}

@end
