//
//  WikiDetailViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 15..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "WikiDetailViewController.h"
#import "WikiWriteViewController.h"
#import "WikiCommentViewController.h"

@interface WikiDetailViewController () <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIButton *btn_Comment;
@end

@implementation WikiDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"그린위키 상세";
    
    [self initNavi];
    
    self.webView.delegate = self;
    
    /*
     # 설문응답진입 url
     http://52.68.160.225/front/webview/wvSurveyApply.do
     # 파라미터
     userIdx (회원 일련번호)
     surveyDeployIdx (배포설문지 일련번호)
     
     # 설문결과진입 url
     http://52.68.160.225/front/webview/
     # 파라미터
     userIdx (회원 일련번호)
     surveyDeployIdx (배포설문지 일련번호)
     */
    
    NSString *str_Url = @"";
    //응답 여부
    if( [self.str_ResponesYn isEqualToString:@"Y"] )
    {
        str_Url = [NSString stringWithFormat:@"%@/front/webview/wvSurveyResult.do?userIdx=%@&surveyDeployIdx=%@",
                   kBaseUrl,
                   [[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"], self.str_Idx];
    }
    else
    {
        str_Url = [NSString stringWithFormat:@"%@/front/webview/wvSurveyApply.do?userIdx=%@&surveyDeployIdx=%@",
                   kBaseUrl,
                   [[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"], self.str_Idx];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:str_Url]];
    [self.webView loadRequest:request];
    
    if( self.isAlreadyComment )
    {
        self.btn_Comment.selected = YES;
    }
    else
    {
        self.btn_Comment.selected = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notiUpdateCommentStatus:)
                                                 name:@"notiUpdateCommentStatus"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //댓글 카운트 하나 갱신해 주기 위해서 이 API를 호출함.. 이게 뭐하는 짓인지...
    [self updateList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initNavi
{
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    UILabel *lb_Title = [[UILabel alloc]initWithFrame:self.navigationItem.titleView.frame];
    lb_Title.font = [UIFont fontWithName:@"Helvetica" size:16];
    lb_Title.textColor = [UIColor whiteColor];
    lb_Title.text = @"그린위키";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
//    self.navigationItem.rightBarButtonItem = [self rightSearchIcon];
}

- (void)updateList
{
    //http://127.0.0.1:7080/api/survey/selectSurveyCommentList.do?comBraRIdx=10001&userIdx=1004&surveyDeployIdx=1
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:self.str_Idx forKey:@"surveyDeployIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/selectSurveyCommentList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSArray *ar = [NSArray arrayWithArray:[resulte objectForKey:@"SurveyCommentList"]];
                                            [self.btn_Comment setTitle:[NSString stringWithFormat:@" %ld", ar.count] forState:UIControlStateNormal];
                                        }
                                    }];
}

- (void)notiUpdateCommentStatus:(NSNotification *)noti
{
    self.btn_Comment.selected = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if( [[[request URL] absoluteString] hasPrefix:@"toapp://"] )
    {
        NSString *jsData = [[request URL] absoluteString];
        NSArray *ar_Cert = [jsData componentsSeparatedByString:@"toapp://cmd?status=certi&"];
        if( ar_Cert.count > 1 )
        {
            NSString *str = [[ar_Cert objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSArray *ar_Sep = [str componentsSeparatedByString:@"&"];
            NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithCapacity:ar_Sep.count];
            for( NSString *str in ar_Sep )
            {
                NSArray *ar = [str componentsSeparatedByString:@"="];
                [dicM setValue:[ar objectAtIndex:1] forKey:[ar objectAtIndex:0]];
            }
            
            [self.navigationController popViewControllerAnimated:NO];
            
            //            if( [self.delegate respondsToSelector:@selector(webViewCancel)] )
            //            {
            //                [self.navigationController popViewControllerAnimated:NO];
            //                return YES;
            //            }
        }
        
        
        NSArray *jsDataArray = [jsData componentsSeparatedByString:@"toapp://"];
        
        //        //1보다크면 무조건 팝!!
        //        if( [jsDataArray count] > 1 )
        //        {
        //            [self.navigationController popViewControllerAnimated:YES];
        //            return YES;
        //        }
        
        NSString *jsString = [jsDataArray objectAtIndex:1]; //jsString == @"call objective-c from javascript"
        
        NSRange range = [jsString rangeOfString:@"CLOSE"];
        if (range.location != NSNotFound)
        {
            [self.navigationController popViewControllerAnimated:YES];
            return YES;
        }
        
        NSLog(@"%@", jsString);
        
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"자바스크립트 연동" message:jsString delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        //        [alert show];
        
        //        [self callJavaScriptFromObjectiveC];
        //        return NO;
        
    }
    
    return YES;
}


#pragma mark - IBAction
- (IBAction)goAddComment:(id)sender
{
    WikiWriteViewController *vc = [[WikiWriteViewController alloc]initWithNibName:@"WikiWriteViewController" bundle:nil];
    vc.str_Idx = self.str_Idx;
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (IBAction)goShowComment:(id)sender
{
    WikiCommentViewController *vc = [[WikiCommentViewController alloc]initWithNibName:@"WikiCommentViewController" bundle:nil];
    vc.str_Idx = self.str_Idx;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
