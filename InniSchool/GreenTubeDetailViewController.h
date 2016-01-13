//
//  GreenTubeDetailViewController.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 10..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GreenTubeDetailViewController : GAITrackedViewController
@property (nonatomic, assign) BOOL isMoviePlay; //동영상 플레이 버튼을 누르고 왔을시 바로 재생 시키기 위해 선언한 변수
@property (nonatomic, assign) NSInteger nIntoMode;
@property (nonatomic, strong) NSString *str_Row;
@property (nonatomic, strong) NSDictionary *dic_Info;
@end
