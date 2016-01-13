//
//  FeedTextCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 8..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "FeedTextCell.h"

@implementation FeedTextCell

- (void)awakeFromNib
{
    self.iv_User.layer.masksToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width/2;
    self.iv_User.contentMode = UIViewContentModeScaleAspectFill;
    
    self.lb_Category.transform = CGAffineTransformMakeRotation(degreesToRadian(45));
    
    self.lb_Category.center = self.iv_Type.center;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
