//
//  FeedMovieCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 8..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "FeedMovieCell.h"

@implementation FeedMovieCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.btn_Movie.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
