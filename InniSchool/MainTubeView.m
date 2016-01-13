//
//  MainTubeView.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 20..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "MainTubeView.h"
#import "MainTubeItem.h"
#import "GreenTubeViewController.h"
#import "AppDelegate.h"
#import "GreenTubeDetailViewController.h"

@implementation MainTubeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateNotiView
{
    for( NSInteger i = 0; i < self.ar_List.count; i++ )
    {
        /*
         CateCodeIdx = 2000;
         CateName = "\Uc9c0\Uc2dd\Uacf5\Uc720";
         ComNM = "\Uc774\Ub2c8\Uc2a4\Ud504\Ub9ac \Ubcf8\Uc0ac";
         ContentType = 1001;
         DeletableYN = Y;
         DeptName = "\Ubd80\Uc11c2";
         DiffTime = 101;
         DutiesPositionParentIdx = 100;
         EditDate = 20150520000835;
         EditableYN = Y;
         FullImgURL = "http://52.68.160.225:80/api/file_upload/test_1(15).jpg";
         ImgURL = "/file_upload/test_1(15).jpg";
         NameKR = "\Uc774\Uc5e0\Uce90\Uc2a4\Ud2b8";
         PollExistYN = N;
         PollParticipantCNT = 0;
         PolledYN = N;
         RegDate = 20150519053552;
         RegUserIDX = 1004;
         ResultViewYN = 504;
         SNSArchivingYN = N;
         SNSAttachList =             (
         );
         SNSCommentCNT = 0;
         SNSContent = "wwwwwwab\nghnffy";
         SNSFavoriteCNT = 0;
         SNSFavoriteYN = N;
         SNSFeedIdx = 123;
         SNSPollList =             (
         );
         SNSReportedYN = N;
         */
        
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"MainTubeItem" owner:self options:nil];
        MainTubeItem *item = [topLevelObjects objectAtIndex:0];
        item.tag = i;

        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [singleTap setNumberOfTapsRequired:1];
        [item addGestureRecognizer:singleTap];

        
        NSDictionary *dic = self.ar_List[i];
        
        NSInteger nContentType = [[dic objectForKey_YM:@"ContentType"] integerValue];

        NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
        [item.iv_User setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"thumbnail_middle2.png") usingCache:NO];

        //작성자 이름
        item.lb_Name.text = [dic objectForKey_YM:@"NameKR"];

        NSInteger nWriteTime = [[dic objectForKey_YM:@"DiffTime"] integerValue];
        NSString *str_WriteTime = @"";
        if( nWriteTime > (60 * 60 * 24) )
        {
            //하루 보다 클 경우엔 날짜 풀로 표시
            str_WriteTime = [dic objectForKey_YM:@"RegDate"];
        }
        else
        {
            if( nWriteTime <= 0 )
            {
                str_WriteTime = @"1초전";
            }
            else if( nWriteTime < 60 )
            {
                //1분보다 작을 경우
                str_WriteTime = [NSString stringWithFormat:@"%ld초전", nWriteTime];
            }
            else if( nWriteTime < (60 * 60) )
            {
                //1시간보다 작을 경우
                str_WriteTime = [NSString stringWithFormat:@"%ld분전", nWriteTime / 60];
            }
            else
            {
                str_WriteTime = [NSString stringWithFormat:@"%ld시간전", ((nWriteTime / 60) / 60)];
            }
        }
        
        item.lb_Date.text = str_WriteTime;
        
        
        item.iv_Play.hidden = YES;
        
        if( nContentType == 1001 )
        {
            //글
            item.iv_Thumb.image = BundleImage(@"main_default_img_01.png");
        }
        else if( nContentType == 1002 )
        {
            //이미지
            NSArray *ar_ImageList = [dic objectForKey:@"SNSAttachList"];
            if( ar_ImageList.count > 0 )
            {
                NSDictionary *dic_MovieInfo = [ar_ImageList firstObject];
                NSString *str_ImageUrl = [dic_MovieInfo objectForKey_YM:@"AttachFileFullURL_I"];
                [item.iv_Thumb setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"no_thumbnail.png") usingCache:NO];
            }
        }
        else if( nContentType == 1003 )
        {
            //동영상
            NSArray *ar_ImageList = [dic objectForKey:@"SNSAttachList"];
            if( ar_ImageList.count > 0 )
            {
                item.iv_Play.hidden = NO;
                
                NSDictionary *dic_MovieInfo = [ar_ImageList firstObject];
                NSString *str_ImageUrl = [dic_MovieInfo objectForKey_YM:@"VODThumnailURL"];
                [item.iv_Thumb setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"no_thumbnail.png") usingCache:NO];
            }
        }
        else if( nContentType == 1004 )
        {
            //투표
            item.iv_Thumb.image = BundleImage(@"main_default_img_02.png");
        }

        item.frame = CGRectMake(((i % 3) * item.frame.size.width) + 10 + ((i % 3) * 9) , ((i / 3) * item.frame.size.height) + ((i / 3) * 10) + 5, item.frame.size.width, item.frame.size.height);
        
        [self addSubview:item];
    }
}

#pragma mark - UIGesture
- (void)tap:(UIGestureRecognizer *)gestureRecognizer
{
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    UIView *view = (UIView *)gestureRecognizer.view;
//    NSDictionary *dic = self.ar_List[view.tag];
//    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"GreenTubeNavi"];
//    GreenTubeViewController *vc = (GreenTubeViewController *)[navi.viewControllers firstObject];
//    vc.str_DetailIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue]];
//    [appDelegate.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
    
    
    UIView *view = (UIView *)gestureRecognizer.view;
    NSDictionary *dic = self.ar_List[view.tag];

    GreenTubeDetailViewController *vc = [[GreenTubeDetailViewController alloc]initWithNibName:@"GreenTubeDetailViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    [self.vc_Parent.navigationController pushViewController:vc animated:YES];
}

@end
