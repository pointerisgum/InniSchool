//
//  ShowUserInfo.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 6..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "ShowUserInfo.h"

@interface ShowUserInfo ()
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bg;
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_Desc;
@end

@implementation ShowUserInfo
- (void)awakeFromNib
{
    self.v_Container.center = CGPointMake(self.v_Container.center.x, [[UIScreen mainScreen] bounds].size.height / 2);

    self.iv_User.layer.masksToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width/2;
    self.iv_User.contentMode = UIViewContentModeScaleAspectFill;
    
    self.v_Container.layer.masksToBounds = YES;
    self.v_Container.layer.cornerRadius = 5.0f;
    self.v_Container.contentMode = UIViewContentModeScaleAspectFill;

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateList
{
//    http://211.232.113.65:7080/api/member/selectUserInfo.do?userIdx=1004
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:self.str_Idx forKey:@"userIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"member/selectUserInfo.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSDictionary *dic = [resulte objectForKey:@"UserInfo"];
                                            
                                            NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
                                            [self.iv_User setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"thumbnail_big.png") usingCache:NO];

                                            self.lb_Name.text = [dic objectForKey_YM:@"NameKR"];
                                            
                                            //본사의 경우 부서명을 찍어준다
                                            NSInteger nDutiesPositionParentIdx = [[dic objectForKey_YM:@"DutiesPositionParentIdx"] integerValue];
                                            if( nDutiesPositionParentIdx == 1000 )
                                            {
                                                NSString *str_Dept = [dic objectForKey_YM:@"DeptName"];
                                                if( str_Dept == nil )
                                                {
                                                    str_Dept = [dic objectForKey_YM:@"DeptNM"];
                                                }
                                                
                                                if( str_Dept.length > 0 )
                                                {
                                                    self.lb_Desc.text = str_Dept;
                                                }
                                                else
                                                {
                                                    self.lb_Desc.text = @"본사";
                                                }
                                            }
                                            else
                                            {
                                                self.lb_Desc.text = [dic objectForKey_YM:@"ComNM"];
                                            }
                                        }
                                    }];
    
    [self updateBg];
}

- (void)updateBg
{
    //http://127.0.0.1:7080/api/mypage/selectProfileBackground.do
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:self.str_Idx forKey:@"userIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"mypage/selectProfileBackground.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            //    ComBraRIdx = 10001;
                                            //    UserIdx = 13623;

                                            NSDictionary *dic = [resulte objectForKey:@"ProfileBackgroundInfo"];
                                            
                                            NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
                                            [self.iv_Bg setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"") usingCache:NO];
                                        }
                                    }];
}

- (IBAction)goClose:(id)sender
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         self.alpha = NO;
                         
                     } completion:^(BOOL finished) {
                        
                         [self removeFromSuperview];
                     }];
}

@end
