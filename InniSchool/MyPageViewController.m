//
//  MyPageViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 11..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "MyPageViewController.h"
#import "BSImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CKCalendarView.h"

@interface CalCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@end

@implementation CalCell

@end


@interface MyPageViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CKCalendarDelegate, UISearchBarDelegate>
{
    NSInteger nYear;
    NSInteger nMonth;
}
@property (nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, weak) CKCalendarView *calendar;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSMutableArray *arM_Photo;
@property (nonatomic, strong) BSImagePickerController *imagePicker;
@property (nonatomic, strong) NSArray *ar_List;
@property (nonatomic, strong) NSMutableArray *arM_SelectList;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Cal;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bg;
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UIView *v_Cal;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation MyPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.screenName = @"마이 페이지";
    
    self.iv_User.layer.masksToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width/2;
    self.iv_User.contentMode = UIViewContentModeScaleAspectFill;

    self.arM_Photo = [NSMutableArray array];

    [self creadCalendarView];
    
    [self updateUserInfo];
    
    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initNavi];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////네비게이션 서치바 오버라이드
//- (void)searchMenuPress:(id)sender
//{
//    self.searchBar = [[UISearchBar alloc]init];
//    [self.searchBar sizeToFit];
//    self.navigationItem.titleView = self.searchBar;
//    self.searchBar.delegate = self;
//    [self performSelector:@selector(onShowKeyboard) withObject:nil afterDelay:0.1f];
//    
//    self.navigationItem.leftBarButtonItem = [self leftCancelButton];
//    self.navigationItem.rightBarButtonItem = [self rightSearchButton];
//}
//
//- (void)onShowKeyboard
//{
//    [self.searchBar becomeFirstResponder];
//}
//
//- (void)cancelButtonPress:(id)sender
//{
//    //취소버튼 눌렀을때
//    [self initNavi];
//}
//
//- (void)searchButtonPress:(id)sender
//{
//    //검색버튼 눌렀을때
//    [self showSearchResultView];
//}
//
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    [self showSearchResultView];
//}
//
//- (void)showSearchResultView
//{
//    if( self.searchBar.text.length > 0 )
//    {
////        KnowInSearchViewController *vc = [[KnowInSearchViewController alloc]initWithNibName:@"KnowInSearchViewController" bundle:nil];
////        vc.str_Keyword = self.searchBar.text;
////        [self.navigationController pushViewController:vc animated:YES];
//    }
//}

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
    lb_Title.text = @"My Page";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItemWithWhiteColor:YES];
//    self.navigationItem.rightBarButtonItem = [self rightSearchIcon];
}

- (void)creadCalendarView
{
    CKCalendarView *calendar = [[CKCalendarView alloc] initWithStartDay:startSunday];
    self.calendar = calendar;
    calendar.delegate = self;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd/MM/yyyy"];
    //    self.minimumDate = [self.dateFormatter dateFromString:@"20/09/2012"];
    
    //    self.calendar.backgroundColor = [UIColor redColor];
    //        self.disabledDates = @[
    //                [self.dateFormatter dateFromString:@"05/01/2013"],
    //                [self.dateFormatter dateFromString:@"06/01/2013"],
    //                [self.dateFormatter dateFromString:@"07/01/2013"]
    //        ];
    
    calendar.onlyShowCurrentMonth = NO;
    calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    
    calendar.frame = CGRectMake(0, 0, self.v_Cal.frame.size.width, self.v_Cal.frame.size.height);
    [self.v_Cal addSubview:calendar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange) name:NSCurrentLocaleDidChangeNotification object:nil];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    nYear = [components year];
    nMonth = [components month];
}

- (void)localeDidChange
{
    [self.calendar setLocale:[NSLocale currentLocale]];
}

- (void)updateList
{
    //http://127.0.0.1:7080/api/mypage/selectMonthlyScheduleList.do?comBraRIdx=10001&userIdx=1004&month=5
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nYear] forKey:@"year"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nMonth] forKey:@"month"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"mypage/selectMonthlyScheduleList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        self.ar_List = nil;
                                        self.calendar.ar_List = nil;

                                        if( resulte )
                                        {
                                            /*
                                             DailyList =             (
                                             {
                                             Contents = "5\Uc6d4 \Uccab\Uc9f8\Ub0a0";
                                             MemoDT = 20150501;
                                             MemoDay = 1;
                                             MemoIdx = 10;
                                             Sort = 1;
                                             }
                                             );
                                             ScheduleDay = 1;
                                             */
                                            
                                            self.ar_List = [NSArray arrayWithArray:[resulte objectForKey:@"MonthlyList"]];
                                            self.calendar.ar_List = [NSArray arrayWithArray:self.ar_List];
                                            
                                            [self.calendar reloadData];
                                            NSLog(@"calendarContainer : %f", self.calendar.calendarContainer.frame.size.height + TOP_HEIGHT);
                                            
                                            self.sv_Cal.contentSize = CGSizeMake(0, self.calendar.calendarContainer.frame.size.height + TOP_HEIGHT);

                                            CGRect frame = self.tbv_List.frame;
                                            frame.origin.y = self.calendar.calendarContainer.frame.size.height + TOP_HEIGHT;
                                            frame.size.height = 0;
                                            self.tbv_List.frame = frame;
                                        }
                                    }];
}

- (void)updateUserInfo
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"member/selectUserInfo.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSDictionary *dic = [resulte objectForKey:@"UserInfo"];
                                            
                                            NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
                                            [self.iv_User setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"thumbnail_big.png") usingCache:NO];
                                        }
                                    }];
    
    [self updateBg];
}

- (void)updateBg
{
    //http://127.0.0.1:7080/api/mypage/selectProfileBackground.do
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"mypage/selectProfileBackground.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [GMDCircleLoader hide];

                                        if( resulte )
                                        {
                                            NSDictionary *dic = [resulte objectForKey:@"ProfileBackgroundInfo"];
                                            
                                            NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
                                            [self.iv_Bg setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"") usingCache:NO];
                                        }
                                    }];
}


#pragma mark - IBAction
- (IBAction)goInfo:(id)sender
{
    
}

- (IBAction)goPoint:(id)sender
{
    
}

- (IBAction)goBadge:(id)sender
{
    
}

- (IBAction)goPicture:(id)sender
{
    [self.view endEditing:YES];

    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:@[@"사진촬영", @"앨범에서 선택"]
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
             imagePickerController.delegate = self;
             imagePickerController.allowsEditing = YES;
             
             if(IS_IOS8_OR_ABOVE)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self presentViewController:imagePickerController animated:YES completion:nil];
             }
         }
         else if( buttonIndex == 1 )
         {
             self.imagePicker = [[BSImagePickerController alloc] init];
             self.imagePicker.maximumNumberOfImages = 1;
             
             [self presentImagePickerController:self.imagePicker
                                       animated:YES
                                     completion:nil
                                         toggle:^(ALAsset *asset, BOOL select) {
                                             if(select)
                                             {
                                                 NSLog(@"Image selected");
                                             }
                                             else
                                             {
                                                 NSLog(@"Image deselected");
                                             }
                                         }
                                         cancel:^(NSArray *assets) {
                                             NSLog(@"User canceled...!");
                                             [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
                                         }
                                         finish:^(NSArray *assets) {
                                             NSLog(@"User finished :)!");
                                             [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
                                             
                                             for( NSInteger i = 0; i < assets.count; i++ )
                                             {
                                                 ALAsset *asset = assets[i];
                                                 
                                                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                                                 CGImageRef iref = [rep fullScreenImage];
                                                 if (iref)
                                                 {
                                                     UIImage *image = [UIImage imageWithCGImage:iref];
                                                     NSData *imageData = UIImageJPEGRepresentation(image, 1);
                                                     self.iv_User.image = image;// [UIImage imageWithData:imageData];
//                                                     [self.arM_Photo addObject:imageData];
                                                     [self updatePicture];
                                                 }
                                             }
                                         }];
         }
     }];
    
}

#pragma mark - ImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage] ? [info objectForKey:UIImagePickerControllerEditedImage] : [info objectForKey:UIImagePickerControllerOriginalImage];

    self.iv_User.image = outputImage;
    [self updatePicture];

//    NSData *imageData = UIImageJPEGRepresentation(outputImage, 1);
//    [self.arM_Photo addObject:imageData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updatePicture
{
    //http://127.0.0.1:7080/api/mypage/updateUserPofileImage.do?comBraRIdx=10001&userIdx=1004
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];

    NSMutableDictionary *dicM_Image = [NSMutableDictionary dictionaryWithCapacity:1];
    NSData *imageData = UIImageJPEGRepresentation(self.iv_User.image, 1);
    [dicM_Image setObject:imageData forKey:@"attachFiles"];

    [[WebAPI sharedData] imageUpload:@"mypage/updateUserPofileImage.do"
                               param:dicM_Params
                          withImages:dicM_Image
                           withBlock:^(id resulte, NSError *error) {
                               
                               if( resulte )
                               {
                                   NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                   switch (nCode) {
                                       case 1:
//                                           [self.navigationController.view makeToast:@"이미지 등록 성공"];
                                           break;
                                           
                                       default:
                                           [self.navigationController.view makeToast:@"이미지 업로드 오류"];
                                           break;
                                   }
                               }
                               
                               [self updateUserInfo];
                           }];
}


#pragma mark - CKCalendarViewDelegate
- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSLog(@"%ld", [components month]);

    nYear = [components year];
    nMonth = [components month];

    [self updateList];
    
    return YES;
//    if ([date laterDate:self.minimumDate] == date)
//    {
//        self.calendar.backgroundColor = [UIColor blueColor];
//        return YES;
//    }
//    else
//    {
//        self.calendar.backgroundColor = [UIColor redColor];
//        return NO;
//    }
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date
{
    [self.arM_SelectList removeAllObjects];

    if( date == nil )
    {
        [self.tbv_List reloadData];
        return;
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger nSelectedDay = [components day];
    
    for( NSInteger i = 0; i < self.ar_List.count; i++ )
    {
        NSDictionary *dic = self.ar_List[i];
        NSInteger nDay = [[dic objectForKey_YM:@"ScheduleDay"] integerValue];
        if( nDay == nSelectedDay )
        {
            self.arM_SelectList = [NSMutableArray arrayWithArray:[dic objectForKey:@"DailyList"]];
        }
    }
    
    [self.tbv_List reloadData];
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CGRect frame = self.tbv_List.frame;
    frame.origin.y = self.calendar.calendarContainer.frame.size.height + TOP_HEIGHT;
    frame.size.height = self.arM_SelectList.count * 37;
    self.tbv_List.frame = frame;

    self.sv_Cal.contentSize = CGSizeMake(0, self.calendar.calendarContainer.frame.size.height + TOP_HEIGHT + (self.tbv_List.frame.size.height));
    
    if( self.arM_SelectList.count > 0 )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{

                             self.sv_Cal.contentOffset = CGPointMake(self.sv_Cal.contentOffset.x, self.sv_Cal.contentSize.height - self.sv_Cal.frame.size.height);

                         } completion:^(BOOL finished) {
                             
                         }];
    }
    
    return self.arM_SelectList.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CalCell";
    CalCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    NSDictionary *dic = self.arM_SelectList[indexPath.row];
    
    cell.lb_Title.text = [dic objectForKey_YM:@"Contents"];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
