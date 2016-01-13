//
//  GreenTubeModifyViewController.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 15..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GreenTubeModifyViewController : GAITrackedViewController
@property (nonatomic, strong) NSString *str_Row;    //리스트에서 들어왔을시 해당 리스트의 idx (노티로 새로 고침 해주기 위함)
@property (nonatomic, strong) NSString *str_Idx;
@end
