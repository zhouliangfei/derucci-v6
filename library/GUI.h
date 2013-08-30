//
//  GUI.h
//  newstar
//
//  Created by mac on 13-7-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>
//UIColor
@interface UIColor(UIColorGUI)
+(UIColor*)colorWithHex:(uint)value;
@end
//UIView
@interface UIView(UIViewGUI)
+(id)viewWithFrame:(CGRect)frame;
@end
//UIImage
@interface UIImage(UIImageGUI)
+(id)imageWithDocument:(NSString*)path;
@end
//UIImageView
@interface UIImageView(UIImageViewGUI)
+(id)imageViewWithFrame:(CGRect)frame;
@end
//UIButton
@interface UIButton(UIButtonGUI)
+(id)buttonWithFrame:(CGRect)frame;
@end
//UILable
@interface UILabel(UILabelGUI)
+(id)labelWithFrame:(CGRect)frame;
@end
//UITextField
@interface UITextField(UITextFieldGUI)
+(id)textFieldWithFrame:(CGRect)frame;
@end
//UITextView
@interface UITextView(UITextViewGUI)
+(id)textViewWithFrame:(CGRect)frame;
@end
//UIScrollView
@interface UIScrollView(UIScrollViewGUI)
+(id)scrollViewWithFrame:(CGRect)frame;
@end
//UITableView
@interface UITableView(UITableViewGUI)
+(id)tableViewWithFrame:(CGRect)frame;
@end

/*
 gui
 */
@interface GUI : NSObject
+(UIWindow*)extendsWindow;

+(id)loadingForView:(UIView*)view visible:(BOOL)visible;

+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent;

+(id)tableViewWithFrame:(CGRect)frame parent:(UIView*)parent;

+(id)scrollViewWithFrame:(CGRect)frame parent:(UIView*)parent;

+(id)lableWithFrame:(CGRect)frame  parent:(UIView*)parent;
+(id)lableWithFrame:(CGRect)frame  parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(uint)align;

+(id)textFieldWithFrame:(CGRect)frame parent:(UIView*)parent;
+(id)textFieldWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(uint)align;
+(id)textFieldWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(uint)align panding:(uint)panding;

+(id)textViewWithFrame:(CGRect)frame parent:(UIView*)parent;
+(id)textViewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(uint)align;

+(id)imageWithFrame:(CGRect)frame parent:(UIView*)parent;
+(id)imageWithFrame:(CGRect)frame parent:(UIView*)parent source:(NSString*)source;
+(id)imageWithFrame:(CGRect)frame parent:(UIView*)parent document:(NSString*)document;

+(id)buttonWithFrame:(CGRect)frame parent:(UIView*)parent;
+(id)buttonWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal target:(id)target event:(SEL)event;
+(id)buttonWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal active:(NSString*)active target:(id)target event:(SEL)event;
@end
