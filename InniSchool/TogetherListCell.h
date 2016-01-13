//
//  TogetherListCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 18..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TogetherListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIButton *btn_Point;
@property (nonatomic, weak) IBOutlet UIButton *btn_PeopleCnt;
@property (nonatomic, weak) IBOutlet UILabel *lb_Contents;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UIButton *btn_IsVote;
@end
