//
//  GlobalStudySearchCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 26..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "GlobalStudySearchCell.h"

@implementation GlobalStudySearchCell

- (void)awakeFromNib {
    // Initialization code
    
    self.btn_Filsu.hidden = self.btn_Sihum.hidden = YES;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.v_Bg.backgroundColor = [UIColor whiteColor];
    self.v_Bg.layer.cornerRadius = 5.0f;
    
    CGRect frame = self.v_Bg.frame;
    frame.origin.x = 5;
    self.v_Bg.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
