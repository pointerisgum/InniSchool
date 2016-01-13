//
//  StudyDetailViewController.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 4. 29..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudyDetailViewController : GAITrackedViewController
@property (nonatomic, strong) NSDictionary *dic_Info;
@property (nonatomic, strong) NSString *str_Idx;
@property (nonatomic, assign) BOOL isLibMode;
@end
