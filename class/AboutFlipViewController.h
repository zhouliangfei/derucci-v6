//
//  AboutFlipViewController.h
//  derucci-v6
//
//  Created by mac on 13-8-7.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFlipView.h"

@interface AboutFlipViewController : UIViewController<UIFlipViewDataSource,UIFlipViewDelegate>
@property(nonatomic,retain) NSArray *source;
@end
