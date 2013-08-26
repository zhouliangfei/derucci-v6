//
//  NavigateView.m
//  derucci-v6
//
//  Created by mac on 13-8-8.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "NavigateView.h"

@implementation NavigateController
+(id)shareInstanceInView:(UIView*)view{
    static NavigateController *instance;
    @synchronized(self){
        if (nil == instance){
            instance = [[NavigateController alloc] initWithFrame:CGRectMake(900, 0, 124, 102)];
        }
    }
    [view addSubview:instance];
    return instance;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        background = [GUI imageWithFrame:CGRectMake(13, 0, 111, 102) parent:self source:@"source/top_back.png"];
        
        children = [[NSMutableArray alloc] init];
        [children addObject:[GUI buttonWithFrame:CGRectMake(0 ,  9, 31, 31) parent:self normal:@"source/top_icon_diy.png" target:self event:@selector(btnTouch:)]];
        [children addObject:[GUI buttonWithFrame:CGRectMake(5 , 48, 32, 31) parent:self normal:@"source/top_icon_fav.png" target:self event:@selector(btnTouch:)]];
        [children addObject:[GUI buttonWithFrame:CGRectMake(37, 78, 31, 31) parent:self normal:@"source/top_icon_use.png" target:self event:@selector(btnTouch:)]];
        [children addObject:[GUI buttonWithFrame:CGRectMake(81, 80, 31, 32) parent:self normal:@"source/top_icon_sys.png" target:self event:@selector(sysTouch:)]];
        
        [GUI buttonWithFrame:CGRectMake(62, 22, 32, 32) parent:self normal:@"source/top_icon_o.png" active:@"source/top_icon_x.png" target:self event:@selector(switchTouch:)];
        [self hiddenChild:NO];
    }
    return self;
}
-(void)dealloc{
    [children release];
    [super dealloc];
}
-(void)switchTouch:(UIButton*)sender{
    sender.selected = !sender.selected;
    //
    [UIView beginAnimations:nil context:nil];
    if (sender.selected) {
        [self showChild:YES];
    }else {
        [self hiddenChild:YES];
    }
    [UIView commitAnimations]; 
}
-(void)btnTouch:(UIButton*)sender{
    NSLog(@"%@",sender);
}
-(void)sysTouch:(UIButton*)sender{
    [Utils gotoWithName:@"UpData" animated:UITransitionStyleCoverHorizontal];
}
-(void)showChild:(BOOL)animation{
    if (animation) {
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            background.alpha = 1.0;
        } completion:^(BOOL finished) {
            for (int i=0; i<children.count; i++) {
                UIButton *temp = [children objectAtIndex:i];
                [UIView animateWithDuration:0.2 delay:i*0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    temp.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    temp.alpha = 1.f;
                } completion:^(BOOL finished) {
                }];
            }
        }];
    }else {
        background.alpha = 1.0;
        for (int i=0; i<children.count; i++) {
            UIButton *temp = [children objectAtIndex:i];
            temp.transform = CGAffineTransformMakeScale(1.0, 1.0);
            temp.alpha = 0.f;
        }
    }
}
-(void)hiddenChild:(BOOL)animation{
    if (animation) {
        for (int i=0; i<children.count; i++) {
            UIButton *temp = [children objectAtIndex:i];
            [UIView animateWithDuration:0.2 delay:(children.count-1-i)*0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                temp.alpha = 0.0;
                temp.transform = CGAffineTransformMakeScale(0.1, 0.1);
            } completion:^(BOOL finished) {
                if (i==0) {
                    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        background.alpha = 0.0;
                    } completion:^(BOOL finished) {
                    }];
                }
            }];
        }
    }else {
        background.alpha = 0.0;
        for (int i=0; i<children.count; i++) {
            UIButton *temp = [children objectAtIndex:i];
            temp.transform = CGAffineTransformMakeScale(0.1, 0.1);
            temp.alpha = 0.f;
        }
    }
}
@end

//..................................................
@implementation NavigateView
@synthesize background;

+(id)shareInstanceInView:(UIView*)view{
    static NavigateView *instance;
    @synchronized(self){
        if (nil == instance){
            instance = [[NavigateView alloc] initWithFrame:CGRectMake(0, 0, 1024, 75)];
        }
    }
    [instance.background setHidden:NO];
    [view addSubview:instance];
    [NavigateController shareInstanceInView:view];
    return instance;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        background = [GUI viewWithFrame:self.bounds parent:self];
        [GUI imageWithFrame:CGRectMake(0, 0, 1024, 75) parent:background source:@"source/top_base.png"];
        [GUI imageWithFrame:CGRectMake(500, 44, 22, 15) parent:background source:@"source/top_icon_doc.png"];
        [GUI lableWithFrame:CGRectMake(256, 24, 512, 12) parent:background text:@"向下滑动返回上一级" font:[UIFont boldSystemFontOfSize:12] color:[UIColor whiteColor] align:1];
        //手势
        UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        swipeGestureDown.direction = UISwipeGestureRecognizerDirectionDown;
        swipeGestureDown.numberOfTouchesRequired = 1;
        [background addGestureRecognizer:swipeGestureDown];
        [swipeGestureDown release];
        //
        [GUI imageWithFrame:CGRectMake(27, 14, 111, 43) parent:self source:@"source/top_logo.png"];
        [GUI buttonWithFrame:CGRectMake(162, 22, 31, 32) parent:self normal:@"source/top_icon_home.png" target:self event:@selector(homeTouch:)];
    }
    return self;
}
-(void)homeTouch:(UIButton*)sender{
    [Utils gotoWithName:@"HomeViewController" animated:YES];
}
-(void)handleGesture:(UISwipeGestureRecognizer*)gestureRecognizer{  
    [Utils back];
}
@end
