//
//  FeedVoteCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 8..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedTextCell.h"

@interface FeedVoteCell : FeedTextCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Qeustion;
@property (nonatomic, weak) IBOutlet UILabel *lb_QeustionInPeople;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Line;
@property (nonatomic, weak) IBOutlet UIView *v_QeustionBg;
@end
