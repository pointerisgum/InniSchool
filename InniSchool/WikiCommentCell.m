//
//  WikiCommentCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 15..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "WikiCommentCell.h"

@implementation WikiCommentCell

- (void)awakeFromNib {
    // Initialization code
    
    self.iv_User.layer.masksToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width/2;
    self.iv_User.contentMode = UIViewContentModeScaleAspectFill;
    
    self.btn_Heart.layer.masksToBounds = YES;
    self.btn_Heart.layer.borderWidth = 0.5f;
    self.btn_Heart.layer.borderColor = k1PxLineColor.CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
