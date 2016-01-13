//
//  OnePxImageView.m
//  SongSong
//
//  Created by KimYoung-Min on 2014. 8. 30..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import "OnePxImageView.h"

@implementation OnePxImageView

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self setLine];
    
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setLine];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setLine];
}

- (void)setLine
{
    if( self.frame.size.width == 1.0f )
    {
        CGRect frame = self.frame;
        frame.size.width = 0.5f;
        self.frame = frame;
    }
    
    if( self.frame.size.height == 1.0f )
    {
        CGRect frame = self.frame;
        frame.size.height = 0.5f;
        self.frame = frame;
    }
    
    self.backgroundColor = k1PxLineColor;

//    if( [self.backgroundColor isEqual:[UIColor clearColor]] )
//    {
//        self.backgroundColor = k1PxLineColor;
//    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
