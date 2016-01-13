//
//  VoteQeustionGraphCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 12..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteQeustionGraphCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Number;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Graph;
@property (nonatomic, weak) IBOutlet UIImageView *iv_GraphBg;
@property (nonatomic, weak) IBOutlet UILabel *lb_VoteCnt;
@property (nonatomic, weak) IBOutlet UIImageView *iv_UnderLine;
@end
