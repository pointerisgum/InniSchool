//
//  GreenTubeViewController.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 7..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GreenTubeViewController : GAITrackedViewController
@property (nonatomic, strong) NSString *str_DetailIdx;  //상세로 바로 진입하기 위해 넘기는 값 (이 값이 안오면 일반적인 형태로 들어오는것임)
@end
