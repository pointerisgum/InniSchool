//
//  WikiCommentViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 15..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "WikiCommentViewController.h"
#import "WikiCommentCell.h"
#import "SubTagUIImageView.h"
#import "MWPhotoBrowser.h"

static NSInteger snEmptyTag = 90;

@interface WikiCommentViewController () <MWPhotoBrowserDelegate>
@property (nonatomic, strong) NSArray *ar_List;
@property (nonatomic, strong) NSMutableArray *ar_Photo;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation WikiCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"그린위키 댓글";
    
    [self initNavi];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    lb_Title.text = @"응답하기";
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
                                        
                                        UIView *view = (UIView *)[self.tbv_List viewWithTag:snEmptyTag];
                                        [view removeFromSuperview];

                                        if( resulte )
                                        {
                                            self.ar_List = [NSArray arrayWithArray:[resulte objectForKey:@"SurveyCommentList"]];
                                        }
                                        
                                        [self.tbv_List reloadData];

                                        if( self.ar_List == nil || self.ar_List.count <= 0 )
                                        {
                                            [self showEmptyView];
                                        }
                                    }];
}

- (void)showEmptyView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"CommentEmpty" owner:self options:nil];
    UIView *view = [topLevelObjects objectAtIndex:0];
    view.tag = snEmptyTag;
    view.center = self.tbv_List.center;
    [self.tbv_List addSubview:view];
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ar_List.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WikiCommentCell";
    WikiCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    /*
     AttachFileList =             (
     {
     AttachFileFullURL = "http://52.68.160.225:80/api/file_upload/test_4.jpg";
     AttachFileURL = "/file_upload/test_4.jpg";
     CommentAttachIdx = 2;
     }
     );
     ComNM = "\Uc774\Ub2c8\Uc2a4\Ud504\Ub9ac \Ubcf8\Uc0ac";
     DeletableYN = Y;
     DeptName = "\Ubd80\Uc11c2";
     DutiesPositionParentIdx = 100;
     EditableYN = Y;
     FavoriteCnt = 0;
     FavoriteYN = N;
     FullImgURL = "http://52.68.160.225:80/api/UPLOAD/MEMBER/AAA.JPG";
     ImgURL = "/UPLOAD/MEMBER/AAA.JPG";
     NameKR = "\Uc774\Uc5e0\Uce90\Uc2a4\Ud2b8";
     RegDate = "2015.05.13";
     RegUserIdx = 1004;
     ReportedYN = N;
     SurveyCommentIdx = 20;
     SurveyDeployIdx = 1;
     UserComments = "<null>";
     */

    cell.tag = cell.sv_Thumb.tag = cell.btn_Delete.tag = cell.btn_Modify.tag = cell.btn_Report.tag = cell.btn_Heart.tag = indexPath.row;
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    //유저 이미지
    NSString *str_UserProfileUrl = [dic objectForKey_YM:@"FullImgURL"];
    [cell.iv_User setImageWithString:str_UserProfileUrl placeholderImage:BundleImage(@"thumbnail_small.png") usingCache:NO];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTap:)];
    [tap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:tap];
    cell.iv_User.userInteractionEnabled = YES;
    
    
    //작성자명
    cell.lb_Writer.text = [dic objectForKey_YM:@"NameKR"];
    
    
    //매장명
//    cell.lb_SubTitle.text = [NSString stringWithFormat:@"%@ | %@", [dic objectForKey_YM:@"ComNM"], [dic objectForKey_YM:@"RegDate"]];
    cell.lb_SubTitle.text = [NSString stringWithFormat:@"%@ | %@", [dic objectForKey_YM:@"ComNM"], [Util makeDate:[dic objectForKey_YM:@"RegDate"]]];

    
    //내용
    cell.lb_Contents.numberOfLines = 0;
    cell.lb_Contents.text = [dic objectForKey_YM:@"UserComments"];

    
    //이미지 스크롤 뷰
    NSArray *ar_ImageList = [dic objectForKey:@"AttachFileList"];
    if( ar_ImageList.count > 0 )
    {
        cell.sv_Thumb.hidden = NO;
    }
    else
    {
        cell.sv_Thumb.hidden = YES;
    }
    
    for( UIView *subView in cell.sv_Thumb.subviews )
    {
        if( subView.tag > 0 )
        {
            [subView removeFromSuperview];
        }
    }
    
    for( NSInteger i = 0; i < ar_ImageList.count; i++ )
    {
        NSDictionary *dic_Image = ar_ImageList[i];
        
        SubTagUIImageView *iv = [[SubTagUIImageView alloc]initWithFrame:CGRectMake(i * (cell.sv_Thumb.frame.size.width), 0,
                                                                                   cell.sv_Thumb.frame.size.width - 4, cell.sv_Thumb.frame.size.height)];
        iv.tag = i + 1;
        iv.userInteractionEnabled = YES;
        iv.nSubTag = indexPath.row;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        
        NSString *str_ImageUrl = [dic_Image objectForKey_YM:@"AttachFileFullURL"];
        [iv setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"no_thumbnail.png") usingCache:NO];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
        [singleTap setNumberOfTapsRequired:1];
        [iv addGestureRecognizer:singleTap];
        
        [cell.sv_Thumb addSubview:iv];
    }
    
    cell.sv_Thumb.contentSize = CGSizeMake(cell.sv_Thumb.frame.size.width * ar_ImageList.count, 0);
    

    //하트
    NSString *str_LikeYn = [dic objectForKey_YM:@"FavoriteYN"];
    if( [str_LikeYn isEqualToString:@"Y"] )
    {
        cell.btn_Heart.selected = YES;
    }
    else
    {
        cell.btn_Heart.selected = NO;
    }
    
    [cell.btn_Heart setTitle:[NSString stringWithFormat:@" %ld", [[dic objectForKey_YM:@"FavoriteCnt"] integerValue]] forState:UIControlStateNormal];
    [cell.btn_Heart addTarget:self action:@selector(onLike:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //댓글 칼라변경 및 함수포인터 설정
    NSString *str_IsMyContents = [dic objectForKey_YM:@"EditableYN"];
    if( [str_IsMyContents isEqualToString:@"Y"] )
    {
        //내가 쓴 댓글이면
        cell.btn_Report.hidden = YES;
        cell.btn_Delete.hidden = NO;
        [cell.btn_Delete addTarget:self action:@selector(onDeleteComment:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.btn_Modify addTarget:self action:@selector(onModify:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        //다른사람이 쓴 댓글이면
        cell.btn_Report.hidden = NO;
        cell.btn_Delete.hidden = YES;
        [cell.btn_Report addTarget:self action:@selector(onReport:) forControlEvents:UIControlEventTouchUpInside];
    }

    
    CGRect frame = cell.lb_Contents.frame;
    frame.size.height = [Util getTextSize:cell.lb_Contents].height + 10;
    cell.lb_Contents.frame = frame;
    
    CGFloat fLastY = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 10;

    if( ar_ImageList.count > 0 )
    {
        frame = cell.sv_Thumb.frame;
        frame.origin.y = fLastY;
        cell.sv_Thumb.frame = frame;
        
        fLastY = cell.sv_Thumb.frame.origin.y + cell.sv_Thumb.frame.size.height + 15;
    }
    
    frame = cell.btn_Heart.frame;
    frame.origin.y = fLastY;
    cell.btn_Heart.frame = frame;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.ar_List[indexPath.row];
    WikiCommentCell *cell = (WikiCommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.lb_Contents.text = [dic objectForKey_YM:@"UserComments"];
    
    CGRect frame = cell.lb_Contents.frame;
    frame.size.height = [Util getTextSize:cell.lb_Contents].height + 10;
    cell.lb_Contents.frame = frame;
    
    CGFloat fLastY = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 10;
    
    NSArray *ar_ImageList = [dic objectForKey:@"AttachFileList"];
    if( ar_ImageList.count > 0 )
    {
        frame = cell.sv_Thumb.frame;
        frame.origin.y = fLastY;
        cell.sv_Thumb.frame = frame;
        
        fLastY = cell.sv_Thumb.frame.origin.y + cell.sv_Thumb.frame.size.height + 15;
    }
    
    frame = cell.btn_Heart.frame;
    frame.origin.y = fLastY;
    cell.btn_Heart.frame = frame;
    
    fLastY = cell.btn_Heart.frame.origin.y + cell.btn_Heart.frame.size.height + 15;

    return fLastY;
}


#pragma mark - UIGesture
- (void)profileTap:(UIGestureRecognizer *)gesture
{
    NSDictionary *dic = self.ar_List[gesture.view.tag];
    
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"ShowUserInfo" owner:self options:nil];
    ShowUserInfo *view = [topLevelObjects objectAtIndex:0];
    view.str_Idx = [dic objectForKey_YM:@"RegUserIdx"];
    [view updateList];
    
    view.alpha = NO;
    
    view.v_Container.center = self.navigationController.view.center;
    
    [self.navigationController.view addSubview:view];
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         view.alpha = YES;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)imageTap:(UIGestureRecognizer *)gestureRecognizer
{
    //nSubTag는 index.section값
    //tag는 이미지 순서값
    SubTagUIImageView *iv = (SubTagUIImageView *)gestureRecognizer.view;
    
    self.ar_Photo = [NSMutableArray array];
    self.thumbs = [NSMutableArray array];
    
    NSDictionary *dic = self.ar_List[iv.nSubTag];

    NSArray *ar_Thumbs = [dic objectForKey:@"AttachFileList"];
    
    NSMutableArray *arM_Url = [NSMutableArray array];
    for( NSInteger i = 0; i < ar_Thumbs.count; i++ )
    {
        NSDictionary *dic = ar_Thumbs[i];
        NSString *str_Url = [dic objectForKey_YM:@"AttachFileFullURL"];
        if( [str_Url hasSuffix:@"api"] == NO )
        {
            [arM_Url addObject:dic];
        }
    }
    
    NSInteger nImageCnt = arM_Url.count;
    for( NSInteger i = 0; i < nImageCnt; i++ )
    {
        NSDictionary *dic_ImageInfo = arM_Url[i];
        [self.thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[dic_ImageInfo valueForKey:@"AttachFileFullURL"]]]];
        [self.ar_Photo addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[dic_ImageInfo valueForKey:@"AttachFileFullURL"]]]];
    }
    
    BOOL displayActionButton = NO;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = YES;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:iv.tag - 1];
    
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
    
    // Release
    
    // Test reloading of data after delay
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
    });
}


#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _ar_Photo.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _ar_Photo.count)
        return [_ar_Photo objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    if (index < _thumbs.count)
    {
        return [_thumbs objectAtIndex:index];
    }
    return nil;
}


#pragma mark - IBAction
- (void)onLike:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];
    
    //http://127.0.0.1:7080/api/survey/insertSurveyCommentFavorite.do?comBraRIdx=10001&userIdx=1004&surveyCommentIdx=19&surveyDeployIdx=1
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SurveyCommentIdx"] integerValue]] forKey:@"surveyCommentIdx"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SurveyDeployIdx"] integerValue]] forKey:@"surveyDeployIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/insertSurveyCommentFavorite.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            /*
                                             0 : 좋아요 실패
                                             1 : 좋아요 성공
                                             2 : 좋아요 취소 실패
                                             3 : 좋아요 취소 성공처리결과
                                             */
                                            NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                            switch (nCode)
                                            {
                                                case 1:
                                                    [self.navigationController.view makeToast:@"좋아요"];
                                                    break;
                                                    
                                                case 3:
                                                    [self.navigationController.view makeToast:@"좋아요 취소"];
                                                    break;
                                                    
                                                default:
                                                    [self.navigationController.view makeToast:@"오류"];
                                                    break;
                                            }
                                            
                                            [self updateList];
                                        }
                                    }];
}

- (void)onDeleteComment:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];
    
    //http://127.0.0.1:7080/api/survey/deleteSurveyComment.do?comBraRIdx=10001&userIdx=1004&surveyCommentIdx=19
    UIAlertView *alert = CREATE_ALERT(nil, @"삭제하시겠습니까?", @"예", @"아니요");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if( buttonIndex == 0 )
        {
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SurveyCommentIdx"] integerValue]] forKey:@"surveyCommentIdx"];
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SurveyDeployIdx"] integerValue]] forKey:@"surveyDeployIdx"];
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/deleteSurveyComment.do"
                                                param:dicM_Params
                                            withBlock:^(id resulte, NSError *error) {
                                                
                                                [GMDCircleLoader hide];
                                                
                                                if( resulte )
                                                {
                                                    NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                                    switch (nCode)
                                                    {
                                                        case 1:
                                                            [self.navigationController.view makeToast:@"삭제 되었습니다"];
                                                            break;
                                                            
                                                        default:
                                                            [self.navigationController.view makeToast:@"오류"];
                                                            break;
                                                    }
                                                    
                                                    [self updateList];
                                                }
                                            }];
        }
    }];
}

- (void)onReport:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];
    
    UIAlertView *alert = CREATE_ALERT(nil, @"신고하시겠습니까?", @"예", @"아니요");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if( buttonIndex == 0 )
        {
            //http://127.0.0.1:7080/api/survey/insertSurveyCommentReport.do?comBraRIdx=10001&userIdx=1004&surveyCommentIdx=19&surveyDeployIdx=1
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SurveyCommentIdx"] integerValue]] forKey:@"surveyCommentIdx"];
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SurveyDeployIdx"] integerValue]] forKey:@"surveyDeployIdx"];
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/insertSurveyCommentReport.do"
                                                param:dicM_Params
                                            withBlock:^(id resulte, NSError *error) {
                                                
                                                [GMDCircleLoader hide];
                                                
                                                if( resulte )
                                                {
                                                    NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                                    switch (nCode)
                                                    {
                                                        case 1:
                                                            [self.navigationController.view makeToast:@"신고 되었습니다"];
                                                            break;
                                                            
                                                        case 2:
                                                            [self.navigationController.view makeToast:@"이미 신고한 컨텐츠 입니다"];
                                                            break;
                                                            
                                                        default:
                                                            [self.navigationController.view makeToast:@"오류"];
                                                            break;
                                                    }
                                                }
                                            }];
        }
    }];
}

@end
