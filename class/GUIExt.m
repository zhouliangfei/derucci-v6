//
//  GUIExt.m
//  derucci-v6
//
//  Created by mac on 13-8-14.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "GUIExt.h"

//
@implementation GUIFlipCell
@dynamic image;
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        imagetView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [imagetView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:imagetView];
    }
    return self;
}
-(void)dealloc{
    [imagetView release];
    [super dealloc];
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [imagetView setFrame:self.bounds];
}
-(void)setImage:(UIImage *)image{
    [imagetView setImage:image];
}
-(UIImage *)image{
    return [imagetView image];
}
@end
//
@implementation GUIFlipBorderCell
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        [self.layer setBorderColor:[[UIColor orangeColor] CGColor]];
        self.layer.borderWidth = 5.f;
    }else {
        [self.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        self.layer.borderWidth = 5.f;
    }
}
@end
//
@implementation GUIFlipBeatCell
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self addTarget:self action:@selector(onTouch:) forControlEvents:UIControlEventTouchUpInside];
        [self.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [self setSelected:NO];
    }
    return self;
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    //
    ground = self.center.y;
    gravity = 1.0;
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        self.layer.borderWidth = 2.f;
    }else {
        self.layer.borderWidth = 1.f;
    }
}
//
-(void)onTouch:(id)sender{
    [self playAnimation];
}
-(void)playAnimation{
    if (nil == animation) {
        speed = 0.25;
        potential = -5;
        animation = [[NSTimer scheduledTimerWithTimeInterval:0.024 target:self selector:@selector(enterFrame:) userInfo:nil repeats:YES] retain];
    }
}
-(void)stopAnimation{
    if (animation) {
        [animation invalidate];
        [animation release],animation = nil;
    }
}
-(void)enterFrame:(NSTimer *)timer{
    if (self.superview) {
        potential = (potential + speed) * 0.93;
        float scy = self.center.y + potential;
        //
        if (scy < ground) {
            if (potential <= gravity) {
                speed = fabsf(speed);
            }
        }else {
            if (potential > 1.0) {
                speed = -fabsf(speed);
                potential = -fabsf(potential);
            }else {
                scy = ground;
                [self stopAnimation];
            }
        }
        [self setCenter:CGPointMake(self.center.x, scy)];
    }else {
        [self stopAnimation];
    }
}
@end
//
@implementation GUIRoomBorderCell
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        [self.layer setBorderColor:[[UIColor orangeColor] CGColor]];
        self.layer.borderWidth = 1.f;
    }else {
        [self.layer setBorderColor:[[UIColor grayColor] CGColor]];
        self.layer.borderWidth = 1.f;
    }
}
@end

//
@implementation LeftAttributeButton
@dynamic subTitle;
@dynamic title;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:iconView];
        
        titleView = [GUI lableWithFrame:CGRectZero parent:self text:nil font:[UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:17] color:[UIColor whiteColor] align:0];
        subTitleView = [GUI lableWithFrame:CGRectZero parent:self text:nil font:[UIFont boldSystemFontOfSize:10] color:[UIColor colorWithHex:0x000000aa] align:0];
        
        [titleView.layer setMasksToBounds:NO];
        [titleView.layer setShadowOffset:CGSizeMake(1, 1)];
        [titleView.layer setShadowRadius:0];
        [titleView.layer setShadowOpacity:0.4];
        [titleView.layer setShadowColor:[[UIColor blackColor] CGColor]];

        [self sortChild:frame.size];
        [self setSelected:NO];
    }
    return self;
}
-(void)dealloc{
    [iconView release];
    [super dealloc];
}
-(void)setTitle:(NSString *)title{
    [titleView setText:title];
}
-(void)setSubTitle:(NSString *)subTitle{
    [subTitleView setText:subTitle];
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        [self setBackgroundColor:[UIColor colorWithHex:0xcb0f0f30]];
        [iconView setImage:[UIImage imageNamed:@"source/btn_x.png"]];
    }else {
        [self setBackgroundColor:[UIColor clearColor]];
        [iconView setImage:[UIImage imageNamed:@"source/btn_+.png"]];
    }
}
-(void)sortChild:(CGSize)size{
    float scy = size.height / 2.0;
    [iconView setFrame:CGRectMake(21, scy-12.0, 24, 24)];
    [titleView setFrame:CGRectMake(59, scy-16, size.width-66, 24)];
    [subTitleView setFrame:CGRectMake(59, scy+4, size.width-66, 12)];
}
@end
@implementation RightAttributeButton
-(void)sortChild:(CGSize)size{
    float scy = size.height / 2.0;
    [iconView setFrame:CGRectMake(size.width-45, scy-12.0, 24, 24)];
    [titleView setFrame:CGRectMake(21, scy-16, size.width-66, 24)];
    [subTitleView setFrame:CGRectMake(21, scy+4, size.width-66, 12)];
}
@end
//
@implementation GUIExt
//动画
static NSTimer *tweenAnimation;
static UIView *tweenObject;
static float tweenVelocity;
static float tweenValue;

+(void)enterFrame:(NSTimer *)timer{
    CGRect frame = tweenObject.frame;
    
    float length = tweenValue-frame.origin.x;
    if(abs(length) < 0.1) {
        frame.origin.x = tweenValue;
        if (tweenAnimation) {
            [tweenAnimation invalidate];
            [tweenAnimation release],tweenAnimation = nil;
        }
    } else { 
        tweenVelocity += length * 0.2;
        tweenVelocity *= 0.8;
        frame.origin.x += tweenVelocity;
    }
    [tweenObject setFrame:frame];
}
+(void)tweenTo:(float)value object:(id)object{
    tweenValue = value;
    tweenObject = object;
    if (nil == tweenAnimation) {
        tweenAnimation = [[NSTimer scheduledTimerWithTimeInterval:0.024 target:self selector:@selector(enterFrame:) userInfo:nil repeats:YES] retain];
    }
}
//
+(id)LeftAttributeWithFrame:(CGRect)frame parent:(UIView*)parent title:(NSString*)title subTitle:(NSString*)subTitle target:(id)target event:(SEL)event{
    LeftAttributeButton *temp = [[LeftAttributeButton alloc] initWithFrame:frame];
    [temp setSubTitle:subTitle];
    [temp setTitle:title];
    [parent addSubview:temp];
    if (target && event) {
        [temp addTarget:target action:event forControlEvents:UIControlEventTouchUpInside];
    }
    return [temp autorelease];
}
+(id)RightAttributeWithFrame:(CGRect)frame parent:(UIView*)parent title:(NSString*)title subTitle:(NSString*)subTitle target:(id)target event:(SEL)event{
    RightAttributeButton *temp = [[RightAttributeButton alloc] initWithFrame:frame];
    [temp setSubTitle:subTitle];
    [temp setTitle:title];
    [parent addSubview:temp];
    if (target && event) {
        [temp addTarget:target action:event forControlEvents:UIControlEventTouchUpInside];
    }
    return [temp autorelease];
}
//
+(id)buttonWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal icon:(NSString*)icon title:(NSString*)title target:(id)target event:(SEL)event{
    UIButton *temp = [GUI buttonWithFrame:frame parent:parent normal:normal target:target event:event];
    [temp setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [temp setTitle:title forState:UIControlStateNormal];
    return temp;
}
@end
