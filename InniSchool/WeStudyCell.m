//
//  WeStudyCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 19..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "WeStudyCell.h"

@implementation WeStudyCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 5.0f;
    
    CGRect frame = self.iv_Line.frame;
    frame.size.height = 0.5f;
    self.iv_Line.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
