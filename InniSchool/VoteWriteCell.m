//
//  VoteWriteCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 14..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "VoteWriteCell.h"

@implementation VoteWriteCell

- (void)awakeFromNib {
    // Initialization code
    
    self.tf_Question.layer.cornerRadius = 5.0f;
    self.tf_Question.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tf_Question.layer.borderWidth = 0.5f;
    
    [self.tf_Question setLeftViewMode:UITextFieldViewModeAlways];
    self.tf_Question.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, self.tf_Question.frame.size.height)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
