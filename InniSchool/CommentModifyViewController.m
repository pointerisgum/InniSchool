//
//  CommentModifyViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 4..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "CommentModifyViewController.h"

@interface CommentModifyViewController ()
@property (nonatomic, weak) IBOutlet UITextView *tv_Contents;
@end

@implementation CommentModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"댓글 수정";
    
    [self initNavi];
    
    if( self.isGreenTube )
    {
        self.tv_Contents.text = [self.dic_Info objectForKey_YM:@"Contents"];
    }
    else
    {
        self.tv_Contents.text = [self.dic_Info objectForKey_YM:@"UserComments"];
    }
    
    [self.tv_Contents becomeFirstResponder];
    
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
    lb_Title.text = @"댓글 수정";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
    self.navigationItem.rightBarButtonItem = [self rightDoneMenu];
}


#pragma mark - Override
- (void)rightDoneMenuPressed:(UIButton *)btn
{
    if( self.tv_Contents.text.length <= 0 )
    {
        return;
    }
    
    NSString *str_Url = @"";
    //http://211.232.113.65:7080/api/learn/updateIntegrationCourseComment.do?integrationCourseIdx=1&courseCommentIdx=44&userIdx=1004&userComments=new update test comments
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    
    if( self.isGreenTube )
    {
        str_Url = @"sns/updateSnsComment.do";
        //http://127.0.0.1:7080/api/sns/updateSnsComment.do?userIdx=1004&comBraRIdx=10001&snsFeedIdx=1&snsCommentIdx=21&contents=댓글입력테스트_2&snsCommentAttachIdxList=1
        [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"SNSCommentIdx"] forKey:@"snsCommentIdx"];
        [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] forKey:@"snsFeedIdx"];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
        [dicM_Params setObject:self.tv_Contents.text forKey:@"contents"];
        
        [[WebAPI sharedData] imageUpload:str_Url
                                   param:dicM_Params
                              withImages:nil
                               withBlock:^(id resulte, NSError *error) {

                                   if( resulte )
                                   {
                                       NSDictionary *dic = [resulte objectForKey:@"ResultInfo"];
                                       NSInteger nCode = [[dic objectForKey_YM:@"ResultCode"] integerValue];
                                       if( nCode == 1 )
                                       {
                                           [self.navigationController popViewControllerAnimated:YES];
                                       }
                                       else
                                       {
                                           [self.navigationController.view makeToast:@"오류"];
                                       }
                                   }
                               }];
    }
    else
    {
        str_Url = @"learn/updateIntegrationCourseComment.do";

        [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"IntegrationCourseIdx"] forKey:@"integrationCourseIdx"];
        [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"CourseCommentIdx"] forKey:@"courseCommentIdx"];
        [dicM_Params setObject:self.tv_Contents.text forKey:@"userComments"];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:str_Url
                                            param:dicM_Params
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                NSDictionary *dic = [resulte objectForKey:@"ResultInfo"];
                                                NSInteger nCode = [[dic objectForKey_YM:@"ResultCode"] integerValue];
                                                if( nCode == 1 )
                                                {
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }
                                                else
                                                {
                                                    [self.navigationController.view makeToast:@"오류"];
                                                }
                                            }
                                        }];
    }
}


#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString: @"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

@end
