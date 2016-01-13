//
//  MainTubeView.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 20..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTubeView : UIView
@property (nonatomic, weak) UIViewController *vc_Parent;
@property (nonatomic, strong) NSArray *ar_List;
- (void)updateNotiView;
@end
