//
//  GreenTubeWriteViewController.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 10..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WriteMode){
    kText,
    kMovie,
    kImage,
    kVote
};

@interface GreenTubeWriteViewController : GAITrackedViewController
@property (nonatomic, assign) WriteMode writeMode;
@end
