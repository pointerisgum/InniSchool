//
//  TogetherListCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 18..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "TogetherListCell.h"

@implementation TogetherListCell

- (void)awakeFromNib {
    // Initialization code
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 5.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
