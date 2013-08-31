//
//  HomeViewController.m
//  derucci-v6
//
//  Created by mac on 13-8-6.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "Access.h"
#import "NavigateView.h"
#import "HomeViewController.h"

//..................................................
@interface HomeViewCell:UIButton{
    int iconIndex;
    UIImageView *iconView;
    NSMutableArray *iconImage;
    CGPoint initPosition;
}
@property(nonatomic,readonly) UIView *backgroundView;
@property(nonatomic,readonly) BOOL active;
-(void)setContentFrame:(CGRect)frame;
@end

@implementation HomeViewCell
@synthesize backgroundView;
@synthesize active;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        //
        backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        [backgroundView setUserInteractionEnabled:NO];
        [backgroundView setAlpha:0];
        [self addSubview:backgroundView];
        //
        iconImage = [[NSMutableArray array] retain];
        iconView = [[UIImageView alloc] initWithFrame:self.bounds];
        [iconView setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:iconView];
    }
    return self;
}
-(void)setImages:(NSArray*)images{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [iconImage removeAllObjects];
    if (images) {
        for (id val in images) {
            [iconImage addObject:[UIImage imageWithDocument:[val objectForKey:@"photo"]]];
        }
        //
        iconIndex = 0;
        [self nextImage:nil];
    }
}
-(void)nextImage:(id)sender{
    [iconView setImage:[iconImage objectAtIndex:iconIndex]];
    [self.layer addAnimation:[CATransition animation] forKey:nil];
    if (iconImage.count > 1) {
        [self performSelector:@selector(nextImage:) withObject:nil afterDelay:5];
        
        iconIndex++;
        iconIndex%=iconImage.count;
    }
}
-(void)setActive:(BOOL)value{
    active = value;
    if (self.superview) {
        if (active) {
            CGFloat max = 0.f;
            for (UIView *view in self.superview.subviews) {
                max = MAX(view.layer.zPosition, max);
            }
            initPosition = self.center;
            self.layer.zPosition = max+512.0;
            [self.superview bringSubviewToFront:self];
        }
        //
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDidStopSelector:@selector(activeAnimationDid)];
        [UIView setAnimationDelegate:self];
        if (active) {
            backgroundView.alpha = 1.0;
            iconView.alpha = 0.0;
        }else {
            [UIView setAnimationDuration:0.4];
            self.layer.transform = CATransform3DIdentity;
            self.center=initPosition;
        }
        [UIView commitAnimations];
    }
}
-(void)activeAnimationDid{
    [UIView beginAnimations:nil context:nil];
    if (active) {
        [UIView setAnimationDuration:0.4];
        self.layer.transform = CATransform3DScale(CATransform3DMakeRotation(M_PI, 0, 1, 0),self.superview.frame.size.width/self.frame.size.width,self.superview.frame.size.height/self.frame.size.height,1);
        self.center=self.superview.center;
        self.layer.cornerRadius = 0;
    }else {
        self.layer.cornerRadius = 10;
        backgroundView.alpha = 0.0;
        iconView.alpha = 1.0;
    }
    [UIView commitAnimations];
}
-(void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [backgroundView release];
    [iconView startAnimating];
    [iconImage release];
    [iconView release];
    [super dealloc];
}
-(void)setContentFrame:(CGRect)frame{
    [iconView setFrame:frame];
}
@end

//..................................................
@interface HomeViewController (){
    HomeViewCell *currentCell;
    NSArray *cellFrame;
}
@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    cellFrame = [[NSArray arrayWithObjects:
                  [NSValue valueWithCGRect:CGRectMake(25 , 153, 484, 240)],
                  [NSValue valueWithCGRect:CGRectMake(513, 152, 240, 241)],
                  [NSValue valueWithCGRect:CGRectMake(25 , 396, 240, 241)],
                  [NSValue valueWithCGRect:CGRectMake(269, 396, 240, 241)],
                  [NSValue valueWithCGRect:CGRectMake(513, 396, 240, 241)],
                  [NSValue valueWithCGRect:CGRectMake(757, 153, 240, 484)],nil] retain];
    //
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
    [GUI imageWithFrame:CGRectMake(429, 36, 161, 88) parent:self.view source:@"source/login_logo.png" ];
    
    uint color[] = {0xf94c00ff,0x6db7d4ff,0xc66621ff,0xc734d4ff,0x40afd4ff,0xff7f00ff};
    for (int i=0; i<cellFrame.count; i++) {
        uint curCol = color[i];
        CGRect rect = [[cellFrame objectAtIndex:i] CGRectValue];
        NSString *path = [NSString stringWithFormat:@"source/home_icon%d.png",i+1];
        
        HomeViewCell *cell = [[HomeViewCell alloc] initWithFrame:CGRectOffset(rect, 1024, (i%2==0 ? -50 : 50))];
        [cell addTarget:self action:@selector(cellTouch:) forControlEvents:UIControlEventTouchUpInside];
        [cell setBackgroundImage:[self blurWithImage:[UIImage imageWithResource:path]] forState:UIControlStateNormal];
        if (i==0) {
            [cell setContentFrame:CGRectMake(0, 0, 243.0, rect.size.height)];
            [cell setImages:[Access getPhotoWithModel:[NSNumber numberWithInt:1]]];
        }
        if (i==5) {
            [cell setContentFrame:CGRectMake(0, 0, rect.size.width, 277.0)];
            [cell setImages:[Access getPhotoWithModel:[NSNumber numberWithInt:2]]];
        }
        [self.view addSubview:cell];
        [cell setTag:i+1];
        [cell release];
        
        [UIView animateWithDuration:0.6 delay:0.15 * i options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [cell setFrame:rect];
        } completion:^(BOOL finished) {
            [cell setBackgroundImage:[UIImage imageWithResource:path] forState:UIControlStateNormal];
            [cell.backgroundView setBackgroundColor:[UIColor colorWithHex:curCol]];
        }];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);;
}

-(void)viewDidAppear:(BOOL)animated{
    [NavigateController shareInstanceInView:self.view];
    if ([GUIExt extendsView]) {
        [GUIExt extendsView].animationImages=[Access ExtendsImages];
    }
    //
    if (currentCell) {
        [self performSelector:@selector(viewDidAppearDid:) withObject:currentCell afterDelay:0.4];
        currentCell = nil;
    }
}
-(void)viewDidAppearDid:(id)sender{
    [sender setActive:NO];
}

//.............................................................
-(void)cellTouch:(HomeViewCell*)sender{
    if (sender.tag==6) return;
    currentCell = sender;
    //
    [sender setActive:YES];
    [self performSelector:@selector(cellTouchDid:) withObject:sender afterDelay:0.4];
}
-(void)cellTouchDid:(UIView*)sender{
    switch (sender.tag) {
        case 1:
            [Utils gotoWithName:@"AboutViewController" animated:UITransitionStyleDissolve];
            break;
        case 2:
            [Utils gotoWithName:@"RoomsViewController" animated:UITransitionStyleDissolve];
            break;
        case 3:
            [Utils gotoWithName:@"ProductsViewController" animated:UITransitionStyleDissolve];
            break;
        case 4:
            [Utils gotoWithName:@"FeaturesViewController" animated:UITransitionStyleDissolve];
            break;
        case 5:
            [Utils gotoWithName:@"VirtualViewController" animated:UITransitionStyleDissolve];
            break;
        case 6:
            [Utils gotoWithName:@"DIYViewController" animated:UITransitionStyleDissolve];
            break;
        default:
            break;
    }
}
-(UIImage*)blurWithImage:(UIImage*)image {
    float weight[5] = {0.1270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};
    // Blur horizontally
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:weight[0]];
    for (int x = 1; x < 5; ++x) {
        [image drawInRect:CGRectMake(x, 0, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:weight[x]];
        [image drawInRect:CGRectMake(-x, 0, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:weight[x]];
    }
    UIImage *horizBlurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Blur vertically
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [horizBlurredImage drawInRect:CGRectMake(0, 0, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:weight[0]];
    for (int y = 1; y < 5; ++y) {
        [horizBlurredImage drawInRect:CGRectMake(0, y, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:weight[y]];
        [horizBlurredImage drawInRect:CGRectMake(0, -y, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:weight[y]];
    }
    UIImage *blurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //
    return blurredImage;
}
@end
