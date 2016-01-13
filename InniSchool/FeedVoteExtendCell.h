//
//  FeedVoteExtendCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 11..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedVoteCell.h"

@interface FeedVoteExtendCell : FeedVoteCell
@property (nonatomic, assign) NSInteger nSelectRow;
@property (nonatomic, assign) BOOL isSecret;
@property (nonatomic, assign) BOOL isVote;
@property (nonatomic, strong) NSArray *ar_List;
@property (nonatomic, strong) NSArray *ar_Number;
@property (nonatomic, strong) NSArray *ar_GraphColor;
@property (nonatomic, weak) IBOutlet UIView *v_VoteTop;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIButton *btn_Vote;
@end
