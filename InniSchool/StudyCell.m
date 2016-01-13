//
//  StudyCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 7..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "StudyCell.h"

@implementation StudyCell

- (void)awakeFromNib
{
    self.btn_Filsu.hidden = self.btn_Sihum.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
