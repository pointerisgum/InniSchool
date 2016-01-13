//
//  MainTubeItem.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 20..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTubeItem : UIView
@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb;
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Play;
@end
