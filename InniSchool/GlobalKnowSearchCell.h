//
//  GlobalKnowSearchCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 26..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobalKnowSearchCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIView *v_Tag;
@property (nonatomic, weak) IBOutlet UIView *v_Bottom;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
@property (nonatomic, weak) IBOutlet UIButton *btn_Modify;
@property (nonatomic, weak) IBOutlet UILabel *lb_Contents;
@property (nonatomic, weak) IBOutlet UIButton *btn_StudyCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_SihumCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_MsgCnt;
@property (nonatomic, weak) IBOutlet UIView *v_Bg;
@end
