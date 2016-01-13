//
//  UIViewController+YM.h
//  EmAritaum
//
//  Created by Kim Young-Min on 2014. 3. 19..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (YM)
- (UIBarButtonItem *)homeMenuButtonItem;
- (UIBarButtonItem *)leftBackMenuBarButtonItem;
- (UIBarButtonItem *)rightMenuBarButtonItem;
- (UIBarButtonItem *)blackNaviBackButton;
- (UIBarButtonItem *)whiteNaviBackButton;
- (UIBarButtonItem *)EmptyleftBackMenuBarButtonItem;
- (UIBarButtonItem *)modalCloseBarButtonItem;
- (UIBarButtonItem *)modalCloseBarButtonItemBlack;
- (UIBarButtonItem *)writeNaviButton;
- (UIBarButtonItem *)blackWriteNaviButton;
- (NSArray *)rightMenuAndWriteBarButtonItem;
- (void)leftBackSideMenuButtonPressed:(UIButton *)btn;
- (IBAction)goHome:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)goModalBack:(id)sender;
- (void)goWritePage:(UIButton *)btn;

- (UIBarButtonItem *)leftMenuBarButtonItemWithWhiteColor:(BOOL)isWhite;

- (UIBarButtonItem *)modalCancelButton;
- (UIBarButtonItem *)modalConfirmButton;

- (UIBarButtonItem *)rightSearchIcon;
- (UIBarButtonItem *)rightSearchButton;
- (UIBarButtonItem *)rightDoneMenu;
- (UIBarButtonItem *)leftCancelButton;
- (UIBarButtonItem *)rightDoneButton;
- (UIBarButtonItem *)rightCloseButton;
- (UIBarButtonItem *)rightWriteButton;

@end
