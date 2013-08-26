//
//  LoginViewController.h
//  derucci-v6
//
//  Created by mac on 13-8-5.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UILockView;
@protocol UILockViewDelegate <NSObject>
-(void)cancelled:(UILockView*)target;
@end

@interface LoginViewController : UIViewController<UILockViewDelegate>
@end
