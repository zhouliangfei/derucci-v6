//
//  ProductViewController.h
//  derucci-v6
//
//  Created by mac on 13-8-14.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFlipView.h"

@interface ProductViewController : UIViewController<UIFlipViewDataSource,UIFlipViewDelegate>
@property(nonatomic,retain) NSArray *source;
@property(nonatomic,assign) int currentIndex;
@property(nonatomic,assign) int style;
@end
