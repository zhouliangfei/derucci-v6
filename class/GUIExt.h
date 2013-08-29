//
//  GUIExt.h
//  derucci-v6
//
//  Created by mac on 13-8-14.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "GUI.h"
#import "UIFlipView.h"

//UIFlipViewCell+图片
@interface GUIFlipCell : UIFlipViewCell{
    UIImageView *imagetView;
}
@property(nonatomic,assign) UIImage *image;
@end

//UIFlipViewCell+图片+边框
@interface GUIFlipBorderCell : GUIFlipCell
@end

//UIFlipViewCell+图片+跳动
@interface GUIFlipBeatCell : GUIFlipCell{
    float speed;
    float gravity;
    float potential;
    float ground;
    //
    NSTimer *animation;
}
@end

//UIFlipViewCell+图片+边框
@interface GUIRoomBorderCell : GUIFlipCell
@end

//产品中心和样板间
@interface LeftAttributeButton : UIControl{
    UILabel *titleView;
    UILabel *subTitleView;
    UIImageView *iconView;
}
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *subTitle;
-(void)sortChild:(CGSize)size;
@end
@interface RightAttributeButton : LeftAttributeButton
@end
//
@interface GUIExt : GUI
+(UIImageView*)extendsView;
//
+(void)tweenTo:(float)value object:(id)object;
//
+(id)LeftAttributeWithFrame:(CGRect)frame parent:(UIView*)parent title:(NSString*)title subTitle:(NSString*)subTitle target:(id)target event:(SEL)event;
+(id)RightAttributeWithFrame:(CGRect)frame parent:(UIView*)parent title:(NSString*)title subTitle:(NSString*)subTitle target:(id)target event:(SEL)event;
//
+(id)buttonWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal icon:(NSString*)icon title:(NSString*)title target:(id)target event:(SEL)event;
@end
