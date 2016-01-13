//
//  Common.m
//  Pari
//
//  Created by KimYoung-Min on 2014. 12. 27..
//  Copyright (c) 2014년 KimYoung-Min. All rights reserved.
//

#import "Common.h"

static Common *shared = nil;

@implementation Common

+ (void)initialize
{
    NSAssert(self == [Common class], @"Singleton is not designed to be subclassed.");
    shared = [Common new];
}

+ (Common *)sharedData
{
    return shared;
}

+ (void)saveUserInfo:(NSDictionary *)dic
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [dic valueForKey:@"brandIdx"]] forKey:@"brandIdx"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [dic valueForKey:@"comIdx"]] forKey:@"comIdx"];
    [[NSUserDefaults standardUserDefaults] setObject:[dic valueForKey:@"comName"] forKey:@"comName"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [dic valueForKey:@"deptCdIdx"]] forKey:@"deptCdIdx"];
    [[NSUserDefaults standardUserDefaults] setObject:[dic valueForKey:@"deptName"] forKey:@"deptName"];
    [[NSUserDefaults standardUserDefaults] setObject:[dic valueForKey:@"dutiesPositionIdx"] forKey:@"dutiesPositionIdx"];
    [[NSUserDefaults standardUserDefaults] setObject:[dic valueForKey:@"dutiesPositionNm"] forKey:@"dutiesPositionNm"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [dic valueForKey:@"userAuth"]] forKey:@"userAuth"];
    [[NSUserDefaults standardUserDefaults] setObject:[dic valueForKey:@"userId"] forKey:@"userId"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [dic valueForKey:@"userIdx"]] forKey:@"userIdx"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [dic valueForKey:@"userIp"]] forKey:@"userIp"];
    [[NSUserDefaults standardUserDefaults] setObject:[dic valueForKey:@"userName"] forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] setObject:[dic valueForKey:@"DutiesPositionParentNm"] forKey:@"DutiesPositionParentNm"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeUserInfo
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"brandIdx"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"comIdx"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"comName"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"deptCdIdx"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"deptName"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"dutiesPositionIdx"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"dutiesPositionNm"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"userAuth"];
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"userId"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"userIdx"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"userIp"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"DutiesPositionParentNm"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setCntButton:(NSString *)aString withObj:(UIButton *)btn
{
    NSInteger cnt = [aString integerValue];
    
    if( cnt > 0 )
    {
        btn.hidden = NO;
        [btn setTitle:[NSString stringWithFormat:@"%ld", (long)cnt] forState:UIControlStateNormal];
    }
    else
    {
        btn.hidden = YES;
    }
}

+ (void)studyViewCountUp:(NSString *)aIdx
{
    //http://127.0.0.1:7080/api/learn/insertIntegrationCourseClickCnt.do?comBraRIdx=10001&userIdx=1004&integrationCourseIdx=1
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:aIdx forKey:@"integrationCourseIdx"];
    
    [[WebAPI sharedData] callSyncWebAPIBlock:@"learn/insertIntegrationCourseClickCnt.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {

                                        }
                                    }];
}

+ (void)greenTubeViewCountUp:(NSString *)aIdx
{
    //http://127.0.0.1:7080/api/sns/updateSnsViewCnt.do?comBraRIdx=10001&userIdx=1004&snsFeedIdx=13
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:aIdx forKey:@"snsFeedIdx"];
    
    [[WebAPI sharedData] callSyncWebAPIBlock:@"sns/updateSnsViewCnt.do"
                                       param:dicM_Params
                                   withBlock:^(id resulte, NSError *error) {
                                       
                                       if( resulte )
                                       {
                                           
                                       }
                                   }];
}

+ (void)greenWikiViewCountUp:(NSString *)aIdx
{
    
}

@end
