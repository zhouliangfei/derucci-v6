//
//  NavigateView.h
//  derucci-v6
//
//  Created by mac on 13-8-8.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigateController : UIView{
    UIImageView *background;
    NSMutableArray *children;
}
+(id)shareInstanceInView:(UIView*)view;
@end

//
@interface NavigateView : UIView
@property(nonatomic,readonly) UIView *background;
+(id)shareInstanceInView:(UIView*)view;
@end
