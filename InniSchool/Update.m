//
//  Update.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 4. 28..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "Update.h"

@implementation Update

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)goUpdate:(id)sender
{
    NSURL *appStoreURL = [NSURL URLWithString:kAppStoreURL];
    [[UIApplication sharedApplication] openURL:appStoreURL];
    
    exit(0);
}

@end
