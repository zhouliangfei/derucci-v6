//
//  GUI.m
//  newstar
//
//  Created by mac on 13-7-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "GUI.h"
//UIColor
@implementation UIColor(UIColorGUI)
+(UIColor*)colorWithHex:(uint)value{
    float rc = (float)((value & 0xFF000000) >> 24);
    float gc = (float)((value & 0xFF0000) >> 16);
    float bc = (float)((value & 0xFF00) >> 8);
    float ac = (float)((value & 0xFF));
    return [UIColor colorWithRed:rc/255.0 green:gc/255.0 blue:bc/255.0 alpha:ac/255.0];
}
@end
//UIView
@implementation UIView(UIViewGUI)
+(id)viewWithFrame:(CGRect)frame{
    UIView *temp = [[UIView alloc] initWithFrame:frame];
    return [temp autorelease];
}
@end
//UIImage
@implementation UIImage(UIImageGUI)
+(id)imageWithDocument:(NSString*)path{
    return [UIImage imageWithContentsOfFile:[Utils pathForDocument:path]];
}
@end
//UIImageView
@implementation UIImageView(UIImageViewGUI)
+(id)imageViewWithFrame:(CGRect)frame{
    UIImageView *temp = [[UIImageView alloc] initWithFrame:frame];
    [temp setContentMode:UIViewContentModeScaleAspectFit];
    return [temp autorelease];
}
-(void)dealloc{
    [self setImage:nil];
    [super dealloc];
}
@end
//UIButton
@implementation UIButton(UIButtonGUI)
+(id)buttonWithFrame:(CGRect)frame{
    UIButton *temp = [[UIButton alloc] initWithFrame:frame];
    return [temp autorelease];
}
@end
//UILable
@implementation UILabel(UILabelGUI)
+(id)labelWithFrame:(CGRect)frame{
    UILabel *temp = [[UILabel alloc] initWithFrame:frame];
    [temp setBackgroundColor:[UIColor clearColor]];
    return [temp autorelease];
}
@end
//UITextField
@implementation UITextField(UITextFieldGUI)
+(id)textFieldWithFrame:(CGRect)frame{
    UITextField *temp = [[UITextField alloc] initWithFrame:frame];
    [temp setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [temp setBackgroundColor:[UIColor clearColor]];
    return [temp autorelease];
}
@end
//UITextView
@implementation UITextView(UITextViewGUI)
+(id)textViewWithFrame:(CGRect)frame{
    UITextView *temp = [[UITextView alloc] initWithFrame:frame];
    [temp setBackgroundColor:[UIColor clearColor]];
    return [temp autorelease];
}
@end
//UIScrollView
@implementation UIScrollView(UIScrollViewGUI)
+(id)scrollViewWithFrame:(CGRect)frame{
    UIScrollView *temp = [[UIScrollView alloc] initWithFrame:frame];
    return [temp autorelease];
}
@end
//UITableView
@implementation UITableView(UITableViewGUI)
+(id)tableViewWithFrame:(CGRect)frame{
    UITableView *temp = [[UITableView alloc] initWithFrame:frame];
    [temp setBackgroundColor:[UIColor clearColor]];
    return [temp autorelease];
}
@end
/*
 gui
 */

@implementation GUI
+(UIWindow*)extendsWindow{
    static UIWindow *ExtendsWindowGUI;
    @synchronized(self){
        if (nil == ExtendsWindowGUI){
            UIScreen *extendsScreen = [[UIScreen screens] lastObject];
            if (extendsScreen != [UIScreen mainScreen]) {
                ExtendsWindowGUI = [[UIWindow alloc] initWithFrame:[extendsScreen bounds]];
                [ExtendsWindowGUI setScreen:extendsScreen];
                [ExtendsWindowGUI makeKeyAndVisible];
            }
        }
    }
    return ExtendsWindowGUI;
}

+(id)loadingForView:(UIView*)view visible:(BOOL)visible{
    static UIActivityIndicatorView *loadingViewGUI;
    @synchronized(self){
        if (nil == loadingViewGUI){
            loadingViewGUI = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [loadingViewGUI setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
            [loadingViewGUI setContentMode:UIViewContentModeCenter];
            [loadingViewGUI setFrame:CGRectMake(0, 0, 120, 120)];
            [loadingViewGUI setUserInteractionEnabled:NO];
            [loadingViewGUI.layer setMasksToBounds:YES];
            [loadingViewGUI.layer setCornerRadius:6];
            [loadingViewGUI setAlpha:0];
        }
        if (visible) {
            [UIView beginAnimations:nil context:nil];
            [loadingViewGUI setAlpha:1];
            [UIView commitAnimations];
            [loadingViewGUI startAnimating];
            [view setUserInteractionEnabled:NO];
            //
            if (loadingViewGUI.superview!=view) {
                [loadingViewGUI setCenter:view.center];
                [view addSubview:loadingViewGUI];
            }
        }else {
            [UIView beginAnimations:nil context:nil];
            [loadingViewGUI setAlpha:0];
            [UIView commitAnimations];
            [loadingViewGUI stopAnimating];
            [view setUserInteractionEnabled:YES];
        }
    }
    return loadingViewGUI;
}

+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent{
    UIView *temp = [UIView viewWithFrame:frame];
    [parent addSubview:temp];
    return temp;
}

+(id)tableViewWithFrame:(CGRect)frame parent:(UIView*)parent{
    UITableView *temp = [UITableView tableViewWithFrame:frame];
    [parent addSubview:temp];
    return temp;
}

+(id)scrollViewWithFrame:(CGRect)frame parent:(UIView*)parent{
    UIScrollView *temp = [UIScrollView scrollViewWithFrame:frame];
    [parent addSubview:temp];
    return temp;
}

+(id)lableWithFrame:(CGRect)frame  parent:(UIView*)parent{
    UILabel *temp = [UILabel labelWithFrame:frame];
    [parent addSubview:temp];
    return temp;
}
+(id)lableWithFrame:(CGRect)frame  parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(uint)align{
    UILabel *temp = [GUI lableWithFrame:frame parent:parent];
    [temp setTextAlignment:align];
    [temp setTextColor:color];
    [temp setFont:font];
    if (text) {
        [temp setText:text];
    }
    return temp;
}

+(id)textFieldWithFrame:(CGRect)frame parent:(UIView*)parent{
    UITextField *temp = [UITextField textFieldWithFrame:frame];
    [parent addSubview:temp];
    return temp;
}
+(id)textFieldWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(uint)align{
    UITextField *temp = [GUI textFieldWithFrame:frame parent:parent];
    [temp setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [temp setTextAlignment:align];
    [temp setTextColor:color];
    [temp setFont:font];
    if (text) {
        [temp setText:text];
    }
    return temp;
}
+(id)textFieldWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(uint)align panding:(uint)panding{
    UITextField *temp = [GUI textFieldWithFrame:frame parent:parent text:text font:font color:color align:align];

    UIView *rig = [UIView viewWithFrame:CGRectMake(0, 0, panding, frame.size.height)];
    [temp setRightViewMode:UITextFieldViewModeAlways];
    [temp setRightView:rig];
    
    UIView *lef = [UIView viewWithFrame:CGRectMake(0, 0, panding, frame.size.height)];
    [temp setLeftViewMode:UITextFieldViewModeAlways];
    [temp setLeftView:lef];
    
    return temp;
}

+(id)textViewWithFrame:(CGRect)frame parent:(UIView*)parent{
    UITextView *temp = [UITextView textViewWithFrame:CGRectInset(frame, -8, -8)];
    [temp setEditable:NO];
    [parent addSubview:temp];
    return temp;
}
+(id)textViewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(uint)align{
    UITextView *temp = [GUI textViewWithFrame:frame parent:parent];
    [temp setTextAlignment:align];
    [temp setTextColor:color];
    [temp setFont:font];
    if (text) {
        [temp setText:text];
    }
    return temp;
}

+(id)imageWithFrame:(CGRect)frame parent:(UIView*)parent{
    UIImageView *temp = [UIImageView imageViewWithFrame:frame];
    [parent addSubview:temp];
    return temp;
}
+(id)imageWithFrame:(CGRect)frame parent:(UIView*)parent source:(NSString*)source{
    UIImageView *temp = [GUI imageWithFrame:frame parent:parent];
    [temp setImage:[UIImage imageNamed:source]];
    return temp;
}
+(id)imageWithFrame:(CGRect)frame parent:(UIView*)parent document:(NSString*)document{
    UIImageView *temp = [GUI imageWithFrame:frame parent:parent];
    [temp setImage:[UIImage imageWithDocument:document]];
    return temp;
}

+(id)buttonWithFrame:(CGRect)frame parent:(UIView*)parent{
    UIButton *temp = [UIButton buttonWithFrame:frame];
    [parent addSubview:temp];
    return temp;
}
+(id)buttonWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal target:(id)target event:(SEL)event{
    UIButton *temp = [GUI buttonWithFrame:frame parent:parent];
    if (normal) {
        [temp setBackgroundImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    }
    if (target && event) {
        [temp addTarget:target action:event forControlEvents:UIControlEventTouchUpInside];
    }
    return temp;
}
+(id)buttonWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal active:(NSString*)active target:(id)target event:(SEL)event{
    UIButton *temp = [GUI buttonWithFrame:frame parent:parent normal:normal target:target event:event];
    if (active) {
        [temp setBackgroundImage:[UIImage imageNamed:active] forState:UIControlStateSelected];
    }
    return temp;
}
@end
