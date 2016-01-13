//
//  FeedMovieCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 8..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedTextCell.h"

@interface FeedMovieCell : FeedTextCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_MovieThumb;
@property (nonatomic, weak) IBOutlet UIButton *btn_Movie;
@end
