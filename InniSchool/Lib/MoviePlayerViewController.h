//
//  MoviePlayerViewController.h
//  EmAritaum
//
//  Created by Kim Young-Min on 2014. 4. 7..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@protocol MoviePlayerViewControllerDelegate;

@interface MoviePlayerViewController : MPMoviePlayerViewController
@property (nonatomic, strong) id <MoviePlayerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *str_CursCd;
@property (nonatomic, strong) NSString *str_CCode;
@property (nonatomic, strong) NSString *str_EdateYn;    //종료여부
@property (nonatomic, assign) float fProgTime;          //기존에 시청한 초
@property (nonatomic, assign) float fCtlTime;           //총 영상시간

//여기서부터가 스킨푸드에서 쓰이는것
@property (nonatomic, assign) BOOL isStudyMode;
@property (nonatomic, strong) NSDictionary *dic_InfoMap;
@property (nonatomic, strong) NSDictionary *dic_ContentsList;

//여기서부터는 이니스쿨
@property (nonatomic, assign) BOOL isSave;
@property (nonatomic, strong) NSDictionary *dic_Info;
@end


@protocol MoviePlayerViewControllerDelegate <NSObject>
- (void)videoFinished:(NSString *)aString;
@end