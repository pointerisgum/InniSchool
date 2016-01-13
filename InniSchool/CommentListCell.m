//
//  CommentListCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 4..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "CommentListCell.h"

@implementation CommentListCell
- (void)awakeFromNib
{
    self.iv_User.layer.masksToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width/2;
    self.iv_User.contentMode = UIViewContentModeScaleAspectFill;
}
- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
    
    self.lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Contents.frame);
}
@end
