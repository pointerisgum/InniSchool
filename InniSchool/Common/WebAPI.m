//
//  WebAPI.m
//  Kizzl
//
//  Created by Kim Young-Min on 13. 6. 3..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import "WebAPI.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "SBJson.h"

static WebAPI *shared = nil;
static AFHTTPClient *client = nil;
static AFHTTPClient *clientHttps = nil;
static AFHTTPClient *appStoreclient = nil;

typedef void (^WebSuccessBlock)(id resulte, NSError *error);

@implementation WebAPI

+ (void)initialize
{
    NSAssert(self == [WebAPI class], @"Singleton is not designed to be subclassed.");
    shared = [WebAPI new];
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    clientHttps = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrlHttps]];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [clientHttps registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    appStoreclient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://itunes.apple.com"]];
    [appStoreclient registerHTTPOperationClass:[AFJSONRequestOperation class]];
}

+ (WebAPI *)sharedData
{
    [Util isNetworkCheckAlert];
    return shared;
  
//    return [Util isNetworkCheckAlert] ? shared : nil;
}

- (void)addDefaultParams:(NSMutableDictionary *)params
{
    NSString *str_Param_C = [params objectForKey:@"c"];
    NSString *str_Param_M = [params objectForKey:@"m"];
    if( [str_Param_C isEqualToString:@"pa_member"] && [str_Param_M isEqualToString:@"addMember"] )
    {
        
    }

//    NSString *str_UserNum = [[UserInfo sharedData] str_UserNum];
    NSString *str_UserNum = @"42";
    
    [params setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] forKey:@"app_ver"];
    [params setObject:@"I" forKey:@"os"];
    [params setObject:[[UIDevice currentDevice] systemVersion] forKey:@"os_ver"];
    if( str_UserNum != nil )
    {
        [params setObject:str_UserNum forKey:@"user_num"];
    }
}

- (NSURL *)getWebViewUrl:(NSMutableDictionary *)params
{
    [self addDefaultParams:params];
    
    NSMutableString *strM_Url = [NSMutableString stringWithString:kBaseUrl];
    [strM_Url appendString:@"/api"];
    
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Value = @"";
        if( [[params objectForKey:str_Key] isKindOfClass:[NSString class]] )
        {
            str_Value = [params objectForKey:str_Key];
        }
        else if( [[params objectForKey:str_Key] isKindOfClass:[NSNumber class]] )
        {
            int nValue = [[params objectForKey:str_Key] intValue];
            str_Value = [NSString stringWithFormat:@"%d", nValue];
        }
        [strM_Url appendString:str_Key];
        [strM_Url appendString:@"="];
        [strM_Url appendString:str_Value];
        [strM_Url appendString:@"&"];
    }
    
    return [NSURL URLWithString:strM_Url];
}

- (NSString *)getWebViewUrlString
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"contents", @"c",
                                   @"linkStore", @"m", nil];
    
    [self addDefaultParams:params];
    
    NSMutableString *strM_Url = [NSMutableString stringWithString:kBaseUrl];
    [strM_Url appendString:@"/cont?"];
    
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Value = @"";
        if( [[params objectForKey:str_Key] isKindOfClass:[NSString class]] )
        {
            str_Value = [params objectForKey:str_Key];
        }
        else if( [[params objectForKey:str_Key] isKindOfClass:[NSNumber class]] )
        {
            int nValue = [[params objectForKey:str_Key] intValue];
            str_Value = [NSString stringWithFormat:@"%d", nValue];
        }
        [strM_Url appendString:str_Key];
        [strM_Url appendString:@"="];
        [strM_Url appendString:str_Value];
        [strM_Url appendString:@"&"];
    }
    
    return strM_Url;
}

- (void)openStore
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"contents", @"c",
                                        @"linkStore", @"m", nil];
    
    [self addDefaultParams:params];
    
    NSMutableString *strM_Url = [NSMutableString stringWithString:kBaseUrl];
    [strM_Url appendString:@"/cont?"];
    
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Value = @"";
        if( [[params objectForKey:str_Key] isKindOfClass:[NSString class]] )
        {
            str_Value = [params objectForKey:str_Key];
        }
        else if( [[params objectForKey:str_Key] isKindOfClass:[NSNumber class]] )
        {
            int nValue = [[params objectForKey:str_Key] intValue];
            str_Value = [NSString stringWithFormat:@"%d", nValue];
        }
        [strM_Url appendString:str_Key];
        [strM_Url appendString:@"="];
        [strM_Url appendString:str_Value];
        [strM_Url appendString:@"&"];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strM_Url]];
}

- (void)imageUpload:(NSString *)path param:(NSMutableDictionary *)dataParams withImages:(NSDictionary *)imageParams withBlock:(void(^)(id resulte, NSError *error))completion
{
    [GMDCircleLoader show];
    
    NSMutableDictionary *defaultParams = [NSMutableDictionary dictionary];
//    [self addDefaultParams:defaultParams];
    
    [client setParameterEncoding:AFFormURLParameterEncoding];

    NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];

    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:str_PostPath parameters:defaultParams constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
        NSArray *ar_DataKeys = [dataParams allKeys];
        for( int i = 0; i < [ar_DataKeys count]; i++ )
        {
            NSString *str_Value = [NSString stringWithFormat:@"%@", [dataParams objectForKey:[ar_DataKeys objectAtIndex:i]]];
            [formData appendPartWithFormData:[str_Value dataUsingEncoding:NSUTF8StringEncoding] name:[ar_DataKeys objectAtIndex:i]];
        }

        NSArray *ar_FileKeys = [imageParams allKeys];
        for( int i = 0; i < [ar_FileKeys count]; i++ )
        {
            NSString *str_Key = [ar_FileKeys objectAtIndex:i];
            NSData *imageData = [imageParams objectForKey:str_Key];
            
            NSDate *date = [NSDate date];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
            NSInteger nYear = [components year];
            NSInteger nMonth = [components month];
            NSInteger nDay = [components day];
            NSInteger nHour = [components hour];
            NSInteger nMinute = [components minute];
            NSInteger nSecond = [components second];
            double CurrentTime = CACurrentMediaTime();
            NSString *str_MillSec = @"";
            NSString *str_MillSecTmp = [NSString stringWithFormat:@"%f", CurrentTime];
            NSArray *ar_Tmp = [str_MillSecTmp componentsSeparatedByString:@"."];
            if( [ar_Tmp count] > 0 )
            {
                str_MillSec = [ar_Tmp objectAtIndex:1];
            }
            
            if( [str_Key isEqualToString:@"audioFile"] )
            {
                NSString *str_FileName = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld.ma4", (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond];
                NSLog(@"%@", str_FileName);
                
                [formData appendPartWithFileData:imageData name:@"files" fileName:str_FileName mimeType:@"audio/ma4"];
            }
            else
            {
                NSString *str_FileName = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld.%@.jpg", (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond, str_MillSec];
                NSLog(@"%@", str_FileName);
                
                if( [path isEqualToString:@"Community_write_image.asp"] )
                {
                    [formData appendPartWithFileData:imageData name:@"ImgFile" fileName:str_FileName mimeType:@"image/jpg"];
                }
                else
                {
                    [formData appendPartWithFileData:imageData name:@"attachFiles" fileName:str_FileName mimeType:@"image/jpg"];
                }
            }
        }
    }];

    [request setTimeoutInterval:10];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        //        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //            float fPercent = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
            //            [TWStatus setProgressBarFrame:CGRectMake(0, 0, 320 * fPercent, 20)];
            //            NSLog(@"%f", fPercent);
        });
    }];
    
    
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id  responseObject) {
        
        [GMDCircleLoader hide];

        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        id dicM_Result = [jsonParser objectWithString:dataString];
        
        completion(dicM_Result, nil);
        
        NSLog(@"이미지 업로드 결과 : %@", dicM_Result);
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [GMDCircleLoader hide];
         
         ALERT(nil, @"네트워크에 접속할 수 없습니다.\n3G 및 Wifi 연결상태를\n확인해주세요.", nil, @"확인", nil);
         
         NSLog(@"===============================");
         NSLog(@"error : %@", error);
         NSLog(@"===============================");
         NSLog(@"params : %@", dataParams);
         NSLog(@"===============================");
         
         NSLog(@"error: %@",  operation.responseString);
         completion(nil, nil);
     }];
    
    
    [operation start];
}


- (void)fileUpload:(NSString *)path param:(NSMutableDictionary *)dataParams withFileUrl:(NSURL *)url withBlock:(void(^)(id resulte, NSError *error))completion
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSData *videoData = [NSData dataWithContentsOfURL:url];
    
    [client setParameterEncoding:AFFormURLParameterEncoding];
    
//    NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"http://video.emcast.com:8080/rest/file/upload/8416f34a-f3ac-4081-9102-4b2d17dc9da8;weight=1;promptly=1" parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData>formData){

        NSArray *ar_DataKeys = [dataParams allKeys];
        for( int i = 0; i < [ar_DataKeys count]; i++ )
        {
            NSString *str_Value = [dataParams objectForKey:[ar_DataKeys objectAtIndex:i]];
            [formData appendPartWithFormData:[str_Value dataUsingEncoding:NSUTF8StringEncoding] name:[ar_DataKeys objectAtIndex:i]];
        }
        
        NSDate *date = [NSDate date];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
        NSInteger nYear = [components year];
        NSInteger nMonth = [components month];
        NSInteger nDay = [components day];
        NSInteger nHour = [components hour];
        NSInteger nMinute = [components minute];
        NSInteger nSecond = [components second];
        double CurrentTime = CACurrentMediaTime();
        NSString *str_MillSec = @"";
        NSString *str_MillSecTmp = [NSString stringWithFormat:@"%f", CurrentTime];
        NSArray *ar_Tmp = [str_MillSecTmp componentsSeparatedByString:@"."];
        if( [ar_Tmp count] > 0 )
        {
            str_MillSec = [ar_Tmp objectAtIndex:1];
        }
        NSString *str_FileName = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld.%@.mov", (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond, str_MillSec];
        NSLog(@"%@", str_FileName);

        [formData appendPartWithFileData:videoData name:@"file" fileName:str_FileName mimeType:@"video/quicktime"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        //        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //            float fPercent = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
            //            [TWStatus setProgressBarFrame:CGRectMake(0, 0, 320 * fPercent, 20)];
            //            NSLog(@"%f", fPercent);
        });
    }];
    
    
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id  responseObject) {
        
        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

        NSString *str_VideoId = @"";
        NSArray *ar_Sep1 = [dataString componentsSeparatedByString:@"<id>"];
        if( [ar_Sep1 count] > 1 )
        {
            NSString *str_Sep = [ar_Sep1 objectAtIndex:1];
            NSArray *ar_Sep2 = [str_Sep componentsSeparatedByString:@"</id>"];
            if( [ar_Sep2 count] > 1 )
            {
                str_VideoId = [ar_Sep2 objectAtIndex:0];
            }
        }
        
        completion(str_VideoId, nil);

    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         ALERT(nil, @"네트워크에 접속할 수 없습니다.\n3G 및 Wifi 연결상태를\n확인해주세요.", nil, @"확인", nil);
         
         NSLog(@"error: %@",  operation.responseString);
         completion(nil, nil);
     }];
    
    
    [operation start];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
     
- (void)showErrorMSG:(int)errorCode withData:(NSDictionary *)dic
{
    UIAlertView *alert = CREATE_ALERT(nil, [dic objectForKey:@"ResultMsg"], @"확인", nil);
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}


- (NSURL *)getWebViewUrl:(NSMutableDictionary *)params withUrl:(NSString *)aUrlString
{
    NSMutableString *strM_Url = [NSMutableString stringWithFormat:@"%@/%@?", @"http://switter.theskinfood.com/front", aUrlString];
//    NSMutableString *strM_Url = [NSMutableString stringWithFormat:@"/api/%@", aUrlString];
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Value = @"";
        if( [[params objectForKey:str_Key] isKindOfClass:[NSString class]] )
        {
            str_Value = [params objectForKey:str_Key];
        }
        else if( [[params objectForKey:str_Key] isKindOfClass:[NSNumber class]] )
        {
            int nValue = [[params objectForKey:str_Key] intValue];
            str_Value = [NSString stringWithFormat:@"%d", nValue];
        }
        [strM_Url appendString:str_Key];
        [strM_Url appendString:@"="];
        [strM_Url appendString:str_Value];
        [strM_Url appendString:@"&"];
    }
    
    return [NSURL URLWithString:strM_Url];
}

//파리바게뜨 가맹대표 로그인
- (void)callOwnerLoginWebAPIBlock:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion
{
    //http://school.paris.co.kr:8181/API/Code_Select.asp?UpCodeCd=C0000710

    NSString *str_Url = [NSString stringWithFormat:@"http://school.paris.co.kr:8181/API/Code_Select.asp?UpCodeCd=%@&UserId=%@&UserPw=%@&PhoneType=%@",
                         [params objectForKey:@"UpCodeCd"],
                         [params objectForKey:@"userId"],
                         [params objectForKey:@"UserPw"],
                         [params objectForKey:@"PhoneType"]
                         ];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:str_Url]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    
    if( error )
    {
        completion(nil, error);
    }
    else
    {
        // Parse data here
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSMutableDictionary *dicM_Result = (NSMutableDictionary *)[jsonParser objectWithString:dataString];

        int nRep = [[dicM_Result objectForKey:@"ResultCd"] intValue];
        if( nRep == 1 )
        {
            //BrandChange
            completion(dicM_Result, nil);
        }
        else
        {
            //error
            if( [[dicM_Result objectForKey:@"ResultMsg"] length] > 0 )
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:[dicM_Result objectForKey:@"ResultMsg"] withPosition:kPositionCenter];
            }
            
            completion(nil, nil);
        }
    }
}


//이상한 문자가 들어와서 json 파싱이 에러날때를 대비해서 사용 함
- (NSString *)removeUnescapedCharacter:(NSString *)inputStr
{
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    
    NSRange range = [inputStr rangeOfCharacterFromSet:controlChars];
    
    if (range.location != NSNotFound)
    {
        NSMutableString *mutable = [NSMutableString stringWithString:inputStr];
        
        while (range.location != NSNotFound)
        {
            [mutable deleteCharactersInRange:range];
            
            range = [mutable rangeOfCharacterFromSet:controlChars];
        }
        
        return mutable;
    }
    
    return inputStr;
}

- (void)callAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion
{
    //    [self addDefaultParams:params];
    
    [GMDCircleLoader show];

    NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];

    if( [path isEqualToString:@"member/selectLoginCheck.do"] )
    {
        static NSInteger nRetryCnt = 1;

        [clientHttps postPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            nRetryCnt = 1;

            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            
            dataString = [self removeUnescapedCharacter:dataString];
            
            
            
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSError *error;
            id dicM_Result = [jsonParser objectWithString:dataString error:&error];
            
            if( error )
            {
                NSLog(@"%@", error);
            }
            
            completion(dicM_Result, nil);
            
            [GMDCircleLoader hide];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [GMDCircleLoader hide];
            
            if( nRetryCnt <= 3 )
            {
                NSLog(@"리트라이 카운트 : %ld", nRetryCnt);
                
                nRetryCnt ++;
                [self callAsyncWebAPIBlock:path param:params withBlock:(void(^)(id resulte, NSError *error))completion];
                return;
            }
            else
            {
                nRetryCnt = 1;
            }
            
            
            NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
            NSArray *ar_AllKeys = [params allKeys];
            for( int i = 0; i < [ar_AllKeys count]; i++ )
            {
                NSString *str_Key = [ar_AllKeys objectAtIndex:i];
                NSString *str_Val = [params objectForKey:str_Key];
                [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
            }
            
            if( [strM_CallUrl hasSuffix:@"&"] )
            {
                [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
            }
            
            NSLog(@"%@", strM_CallUrl);
            
            [GMDCircleLoader hide];
            
            //중복된 팝업을 방지하기 위한 코드
            static BOOL isNowShowPopup = NO;
            
            if( !isNowShowPopup )
            {
                [GMDCircleLoader hide];
                
                if( [path isEqualToString:@"mypage/selectProfileBackground.do"] == NO )
                {
                    isNowShowPopup = YES;
                    
                    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                    [window makeToast:@"NetworkError" withPosition:kPositionCenter];
                    isNowShowPopup = NO;

//                    UIAlertView *alert = CREATE_ALERT(nil, @"NetworkError", @"확인", nil);
//                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        if( buttonIndex == 0 )
//                        {
//                            isNowShowPopup = NO;
//                        }
//                    }];
                }
            }
            
            completion(nil, error);
            
            [GMDCircleLoader hide];
        }];
    }
    else
    {
        static NSInteger nRetryCnt = 1;

        [client postPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            nRetryCnt = 1;

            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            
            dataString = [self removeUnescapedCharacter:dataString];
            
            
            
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSError *error;
            id dicM_Result = [jsonParser objectWithString:dataString error:&error];
            
            if( error )
            {
                NSLog(@"%@", error);
            }
            
            completion(dicM_Result, nil);
            
            [GMDCircleLoader hide];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [GMDCircleLoader hide];
            
            if( nRetryCnt <= 3 )
            {
                NSLog(@"리트라이 카운트 : %ld", nRetryCnt);
                
                nRetryCnt ++;
                [self callAsyncWebAPIBlock:path param:params withBlock:(void(^)(id resulte, NSError *error))completion];
                return;
            }
            else
            {
                nRetryCnt = 1;
            }

            NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
            NSArray *ar_AllKeys = [params allKeys];
            for( int i = 0; i < [ar_AllKeys count]; i++ )
            {
                NSString *str_Key = [ar_AllKeys objectAtIndex:i];
                NSString *str_Val = [params objectForKey:str_Key];
                [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
            }
            
            if( [strM_CallUrl hasSuffix:@"&"] )
            {
                [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
            }
            
            NSLog(@"%@", strM_CallUrl);
            
            [GMDCircleLoader hide];
            
            //중복된 팝업을 방지하기 위한 코드
            static BOOL isNowShowPopup = NO;
            
            if( !isNowShowPopup )
            {
                [GMDCircleLoader hide];
                
                if( [path isEqualToString:@"mypage/selectProfileBackground.do"] == NO )
                {
                    isNowShowPopup = YES;
                    
                    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                    [window makeToast:@"NetworkError" withPosition:kPositionCenter];
                    isNowShowPopup = NO;

//                    UIAlertView *alert = CREATE_ALERT(nil, @"NetworkError", @"확인", nil);
//                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        if( buttonIndex == 0 )
//                        {
//                            isNowShowPopup = NO;
//                        }
//                    }];
                }
            }
            
            completion(nil, error);
            
            [GMDCircleLoader hide];
        }];
    }
    
    NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Val = [params objectForKey:str_Key];
        [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
    }
    
    if( [strM_CallUrl hasSuffix:@"&"] )
    {
        [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
    }

    NSLog(@"%@", strM_CallUrl);
}

- (void)callSyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion
{
    [GMDCircleLoader show];

    __block BOOL isFinish = NO;
    __block BOOL isSuccess = NO;
    __block NSMutableDictionary *dicM_Result = nil;
    __block NSError *err = nil;
    
    NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];
    
    if( [path isEqualToString:@"member/selectLoginCheck.do"] )
    {
        [clientHttps postPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [GMDCircleLoader hide];
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            dicM_Result = (NSMutableDictionary *)[jsonParser objectWithString:dataString];
            
            isSuccess = YES;
            isFinish = YES;
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [GMDCircleLoader hide];
            
            err = error;
            isFinish = YES;
            
        }];
    }
    else
    {
        [client postPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [GMDCircleLoader hide];
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            dicM_Result = (NSMutableDictionary *)[jsonParser objectWithString:dataString];
            
            isSuccess = YES;
            isFinish = YES;
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [GMDCircleLoader hide];
            
            err = error;
            isFinish = YES;
            
        }];
    }
    
    NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Val = [params objectForKey:str_Key];
        [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
    }
    
    if( [strM_CallUrl hasSuffix:@"&"] )
    {
        [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
    }
    
    NSLog(@"%@", strM_CallUrl);
    
    
    
    while (!isFinish && [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
    {
        NSLog(@"Wait");
    }
    
    if( isSuccess )
    {
        completion(dicM_Result, nil);
    }
    else
    {
        completion(nil, err);
    }
}

- (void)getAppStoreInfo:(void(^)(id resulte, NSError *error))completion
{
    [GMDCircleLoader show];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:kAppStoreId forKey:@"id"];

    [appStoreclient postPath:@"lookup" parameters:dicM_Params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        id dicM_Result = [jsonParser objectWithString:dataString];
        
        completion(dicM_Result, nil);
        
        [GMDCircleLoader hide];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [GMDCircleLoader hide];
        
        //중복된 팝업을 방지하기 위한 코드
        static BOOL isNowShowPopup = NO;
        
        if( !isNowShowPopup )
        {
            isNowShowPopup = YES;

            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            [window makeToast:@"NetworkError" withPosition:kPositionCenter];
            isNowShowPopup = NO;

//            UIAlertView *alert = CREATE_ALERT(nil, @"NetworkError", @"확인", nil);
//            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                if( buttonIndex == 0 )
//                {
//                    isNowShowPopup = NO;
//                }
//            }];
        }
        
        completion(nil, error);
    }];
    
//    NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
//    NSArray *ar_AllKeys = [params allKeys];
//    for( int i = 0; i < [ar_AllKeys count]; i++ )
//    {
//        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
//        NSString *str_Val = [params objectForKey:str_Key];
//        [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
//    }
//    
//    if( [strM_CallUrl hasSuffix:@"&"] )
//    {
//        [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
//    }
//    
//    NSLog(@"%@", strM_CallUrl);
}





@end
