//
//  SearchResultViewController.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 6..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultViewController : GAITrackedViewController
@property (nonatomic, assign) BOOL isLibSearch;
@property (nonatomic, strong) NSString *str_Keyword;
@property (nonatomic, strong) NSString *str_Depth;
@end
