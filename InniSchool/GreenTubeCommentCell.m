//
//  GreenTubeCommentCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 12..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "GreenTubeCommentCell.h"

@implementation GreenTubeCommentCell

- (void)awakeFromNib {
    // Initialization code
    
    self.iv_User.layer.masksToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width/2;
    self.iv_User.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
