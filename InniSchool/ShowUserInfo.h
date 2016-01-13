//
//  ShowUserInfo.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 6..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowUserInfo : UIView

@property (nonatomic, strong) NSString *str_Idx;
@property (nonatomic, weak) IBOutlet UIView *v_Container;

- (void)updateList;

@end
