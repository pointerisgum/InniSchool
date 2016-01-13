//
//  VoteQeustionGraphCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 12..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "VoteQeustionGraphCell.h"

@implementation VoteQeustionGraphCell

- (void)awakeFromNib {
    // Initialization code
    
    CGRect frame = self.iv_UnderLine.frame;
    frame.size.height = .5f;
    self.iv_UnderLine.frame = frame;
    
    self.iv_Graph.layer.cornerRadius = 2.f;
    self.iv_GraphBg.layer.cornerRadius = 2.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
