//
//  VoteQeustionCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 12..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteQeustionCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Number;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIButton *btn_Check;
@property (nonatomic, weak) IBOutlet UIImageView *iv_UnderLine;
@property (nonatomic, weak) IBOutlet UIButton *btn_Choise;  //테이블뷰 셀렉트 델리게이트가 호출이 안됨.. 그래서 이 변수를 선언함 도대체 왜 안되지.... 흐미
@end
