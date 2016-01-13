//
//  AddTagViewController.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 13..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddTagViewController : GAITrackedViewController
@property (nonatomic, assign) BOOL isModifyMode;
@property (nonatomic, strong) NSArray *ar_TagList;  //태그 수정일 경우 기존 태그 배열을 넘긴다
@end
