//
//  GlobalKnowSearchCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 26..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "GlobalKnowSearchCell.h"

@implementation GlobalKnowSearchCell

- (void)awakeFromNib {
    // Initialization code
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.v_Bg.backgroundColor = [UIColor whiteColor];
    self.v_Bg.layer.cornerRadius = 5.0f;
    
    self.v_Tag.layer.cornerRadius = 5.0f;
    self.v_Tag.backgroundColor = [UIColor colorWithHexString:@"1EADEB"];
    
    CGRect frame = self.v_Bg.frame;
    frame.origin.x = 5;
    self.v_Bg.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
