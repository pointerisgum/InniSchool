//
//  Common.h
//  Pari
//
//  Created by KimYoung-Min on 2014. 12. 27..
//  Copyright (c) 2014년 KimYoung-Min. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

+ (Common *)sharedData;

+ (void)setCntButton:(NSString *)aString withObj:(UIButton *)btn;

//로그인 후 유저정보 저장
+ (void)saveUserInfo:(NSDictionary *)dic;

//로그아웃 후 유저정보 삭제
+ (void)removeUserInfo;

+ (void)studyViewCountUp:(NSString *)aIdx;

+ (void)greenTubeViewCountUp:(NSString *)aIdx;

+ (void)greenWikiViewCountUp:(NSString *)aIdx;

@end