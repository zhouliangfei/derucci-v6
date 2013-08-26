//
//  DIYViewController.h
//  derucci-v6
//
//  Created by mac on 13-8-21.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFlipView.h"
#import "UIPerspectView.h"

@interface DIYViewController : UIViewController<UIFlipViewDataSource,UIFlipViewDelegate,UIPerspectViewDelegate,UIPerspectViewDataSource>{
    int selected[5];
}
@end
