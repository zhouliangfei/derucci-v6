//
//  VirtualViewController.h
//  derucci-v6
//
//  Created by mac on 13-8-16.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "PLView.h"
#import "UIFlipView.h"
#import <UIKit/UIKit.h>

@interface VirtualViewController : UIViewController<PLViewDelegate,UIFlipViewDataSource,UIFlipViewDelegate>

@end
