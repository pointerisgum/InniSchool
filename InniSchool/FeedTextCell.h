//
//  FeedTextCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 8..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KILabel.h"

@interface FeedTextCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Writer;
@property (nonatomic, weak) IBOutlet UILabel *lb_WriterDesc;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Type;
@property (nonatomic, weak) IBOutlet UILabel *lb_Category;
@property (nonatomic, weak) IBOutlet UIButton *btn_Menu;
@property (nonatomic, weak) IBOutlet KILabel *lb_Contents;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
@property (nonatomic, weak) IBOutlet UIButton *btn_ViewCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_CmtCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_LikeCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_KakaoShare;
@property (nonatomic, weak) IBOutlet UIView *v_BottomMenu;  //태그, 카운트들을 묶은 뷰 (프레임 조정을 편하게 하기 위해 묶음)
@property (nonatomic, weak) IBOutlet UIView *v_Contents;
@property (nonatomic, weak) IBOutlet UIImageView *iv_TopLine;
@end
