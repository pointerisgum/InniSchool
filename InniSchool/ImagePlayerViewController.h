//
//  ImagePlayerViewController.h
//  EmAritaum
//
//  Created by Kim Young-Min on 2014. 4. 7..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagePlayerViewControllerDelegate;

@interface ImagePlayerViewController : GAITrackedViewController <UIScrollViewDelegate>
@property (nonatomic, strong) id <ImagePlayerViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isStudy;
@property (nonatomic, strong) NSDictionary *dic_Info;
@end

@protocol ImagePlayerViewControllerDelegate <NSObject>
- (void)slideFinished:(NSString *)aString;
@end