//
//  LoginViewController.m
//  derucci-v6
//
//  Created by mac on 13-8-5.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "Access.h"
#import "LoginViewController.h"

//.................UILockView.................
@interface UILockDotView : UIImageView
@property(nonatomic,assign) float speed;
@end
@implementation UILockDotView
@synthesize speed;
-(id)initWithImage:(UIImage *)image{
    self = [super initWithImage:image];
    if (self) {
        speed = 0.025;
    }
    return self;
}
@end;

@interface UILockView : UIView{
    NSTimer *animation;
    UISlider *slider;
    UIView *dotView;
}
@property(nonatomic,assign) id<UILockViewDelegate> delegate;
@end

@implementation UILockView
@synthesize delegate;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        dotView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:dotView];
        //
        slider = [[UISlider alloc] initWithFrame:self.bounds];
        [slider addTarget:self action:@selector(sliderUp:) forControlEvents:UIControlEventTouchUpInside];
        [slider addTarget:self action:@selector(sliderDown:) forControlEvents:UIControlEventTouchDown];
        [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [slider setThumbImage:[UIImage imageNamed:@"source/login_touch.png"] forState:UIControlStateNormal];
        [slider setMinimumTrackImage:[UIImage imageNamed:@"source/transparent.png"] forState:UIControlStateNormal];
        [slider setMaximumTrackImage:[UIImage imageNamed:@"source/transparent.png"] forState:UIControlStateNormal];
        [self addSubview:slider];
        //
        int len = (frame.size.width-frame.size.height-13.f) / 13.f;
        for (int i=0; i<len; i++) {
            UILockDotView *dot = nil;
            if (i==0) {
                dot = [[UILockDotView alloc] initWithImage:[UIImage imageNamed:@"source/login_docTips.png"]];
            }else {
                dot = [[UILockDotView alloc] initWithImage:[UIImage imageNamed:@"source/login_doc.png"]];
            }
            [dot setCenter:CGPointMake(frame.size.width-i*13.f, dotView.center.y)];
            [dot setAlpha:(float)i/(float)len];
            [dotView addSubview:dot];
            [dot release];
        }
        //
        [self playAnimation];
    }
    return self;
}
-(void)dealloc{
    [self stopAnimation];
    [dotView release];
    [slider release];
    [super dealloc];
}

-(void)sliderUp:(UISlider *)sender{
	if (slider.value == 1.0){
        [delegate cancelled:self];
    }else {
        [UIView beginAnimations:nil context:nil];
        [dotView setAlpha:1.f];
        [UIView commitAnimations];
        [slider setValue: 0 animated: YES];
        [self playAnimation];
    }
}
-(void)sliderDown: (UISlider *)sender{
	[self stopAnimation];
}
-(void)sliderChanged: (UISlider *)sender{
	if (slider.value == 1.0) {
        [delegate cancelled:self];
	}else {
        [dotView setAlpha:1.0-(slider.value*0.6+0.4)];
    }
}

-(void)playAnimation{
    if (nil == animation) {
        animation = [[NSTimer scheduledTimerWithTimeInterval:0.024 target:self selector:@selector(enterFrame:) userInfo:nil repeats:YES] retain];
    }
}
-(void)stopAnimation{
    if (animation) {
        [animation invalidate];
        [animation release],animation = nil;
    }
}
- (void)enterFrame:(NSTimer*)timer {
    //NSLog(@">>>>>>");
    int len = dotView.subviews.count;
    for (int i=0; i<len; i++) {
        UILockDotView *dot = [dotView.subviews objectAtIndex:i];
        float ta = dot.alpha + dot.speed;
        if (ta >= 1.f || ta <= 0.f) {
            dot.speed *= -1.0;
        }
        [dot setAlpha:ta];
    }
}
@end

//.................LoginViewController.................
@interface LoginViewController (){
    UITextField *nameView;
    UITextField *passView;
    UIView *inputView;
}
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	//
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/login_base.png" ];
    [GUI imageWithFrame:CGRectMake(429, 36, 161, 88) parent:self.view source:@"source/login_logo.png" ];
    //
    inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [self.view addSubview:inputView];
    //
    [GUI buttonWithFrame:CGRectMake(982, 729, 25, 25) parent:inputView normal:@"source/login_icon_i.png" target:self event:nil];
    //
    UILockView *lock = [[UILockView alloc] initWithFrame:CGRectMake(147, 558, 147*2, 147)];
    [lock setDelegate:self];
    [inputView addSubview:lock];
    [lock release];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [inputView release],inputView=nil;
    [super viewDidUnload];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [inputView release],inputView=nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
-(void)viewWillAppear:(BOOL)animated{
    if ([GUIExt extendsView]) {
        [GUIExt extendsView].animationImages=[Access ExtendsImages];
    }
}

//....................................................................
-(void)cancelled:(UILockView*)target{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //
    id userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"charUser"];
    id passWord = [[NSUserDefaults standardUserDefaults] objectForKey:@"charPass"];
    //
    [self.view.layer addAnimation:[CATransition animation] forKey:nil];
    [target removeFromSuperview];
    
    nameView = [GUI textFieldWithFrame:CGRectMake(489, 448, 211, 46) parent:inputView text:userName font:[UIFont systemFontOfSize:16] color:[UIColor whiteColor] align:0 panding:5];
    [nameView setBackground:[UIImage imageNamed:@"source/login_inputBase.png"]];
    [nameView setPlaceholder:@"USERNAME"];
    
    passView = [GUI textFieldWithFrame:CGRectMake(703, 448, 211, 46) parent:inputView text:passWord font:[UIFont systemFontOfSize:16] color:[UIColor whiteColor] align:0 panding:5];
    [passView setBackground:[UIImage imageNamed:@"source/login_inputBase.png"]];
    [passView setPlaceholder:@"PASSWORD"];
    [passView setSecureTextEntry:YES];
    
    [GUI buttonWithFrame:CGRectMake(929, 447, 67, 48) parent:inputView normal:@"source/login_btn_go.png" target:self event:@selector(loginTouch:)];
}
-(void)loginTouch:(UIButton*)sender{
    if (nameView.text.length>0 && passView.text.length>0) {
        id temp = [Access loginWithUserName:nameView.text passWord:passView.text];
        if (temp) {
            if ([temp isKindOfClass:[NSError class]]){
                [self showError:((NSError*)temp).localizedDescription];
            } else{
                [[NSUserDefaults standardUserDefaults] setObject:nameView.text forKey:@"charUser"];
                [[NSUserDefaults standardUserDefaults] setObject:passView.text forKey:@"charPass"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //
                [Utils gotoWithName:@"HomeViewController" animated:UITransitionStyleCoverHorizontal];
            }
        }else {
            [self showError:@"未知错误！"];
        }
    }else {
        [self showError:@"用户名和密码不能为空！"];
    }
}
//键盘显示隐藏事件
-(void)keyboardWillShow:(NSNotification *)sender{
    [UIView beginAnimations:nil context:nil];
    inputView.frame = CGRectMake(0, -120, 1024, 768);
    [UIView commitAnimations];
}
-(void)keyboardWillHide:(NSNotification *)sender{
    [UIView beginAnimations:nil context:nil];
    inputView.frame = CGRectMake(0, 0, 1024, 768);
    [UIView commitAnimations];
}
//
-(void)showError:(NSString*)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登陆失败！" message:error delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [alert release];
}
@end
