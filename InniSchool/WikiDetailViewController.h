//
//  WikiDetailViewController.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 15..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WikiDetailViewController : GAITrackedViewController
@property (nonatomic, assign) BOOL isAlreadyComment;
@property (nonatomic, strong) NSString *str_ResponesYn;
@property (nonatomic, strong) NSString *str_Idx;
@end
