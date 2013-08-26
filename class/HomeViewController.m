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
    UIImageView *iconView;
    int iconIndex;
    NSMutableArray *iconImage;
    CGSize initSize;
}
@property(nonatomic,readonly) UIView *backgroundView;
-(void)setActive:(BOOL)active;
@end

@implementation HomeViewCell
@synthesize backgroundView;
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        initSize = frame.size;
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        //
        backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        [backgroundView setUserInteractionEnabled:NO];
        [backgroundView setAlpha:0];
        [self addSubview:backgroundView];
        //
        iconImage = [[NSMutableArray array] retain];
        iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [iconView setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:iconView];
    }
    return self;
}
-(void)setImages:(NSArray*)images{
    [iconImage removeAllObjects];
    if (images) {
        for (id val in images) {
            [iconImage addObject:[UIImage imageWithDocument:[val objectForKey:@"photo"]]];
        }
        //
        iconIndex = 0;
        [self setIconSize:self.frame.size];
        [self nextImage:nil];
    }
}
-(void)nextImage:(id)sender{
    [iconView setImage:[iconImage objectAtIndex:iconIndex]];
    [self.layer addAnimation:[CATransition animation] forKey:nil];
    [self performSelector:@selector(nextImage:) withObject:nil afterDelay:5];
    //
    iconIndex++;
    iconIndex %= iconImage.count;
}
-(void)setActive:(BOOL)active{
    [UIView beginAnimations:nil context:nil];
    if (active) {
        self.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        self.layer.cornerRadius = 0.0;
        self.layer.zPosition = INT_MAX;
        self.backgroundView.alpha = 1.0;
        iconView.alpha = 0.0;
    }else {
        self.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0);
        self.layer.cornerRadius = 10.0;
        self.layer.zPosition = 0;
        self.backgroundView.alpha = 0.0;
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
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self setIconSize:frame.size];
    [backgroundView setFrame:self.bounds];
}
-(void)setIconSize:(CGSize)size{
    if (iconImage.count>0) {
        if (size.width > size.height) {
            [iconView setFrame:CGRectMake(0, 0, 243.0*size.width/initSize.width, size.height)];
        }else {
            [iconView setFrame:CGRectMake(0, 0, size.width, 276.0*size.height/initSize.height)];
        }
    }
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
                  [NSValue valueWithCGRect:CGRectMake(513, 153, 240, 240)],
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
        [cell setBackgroundImage:[self blurWithImage:[UIImage imageNamed:path]] forState:UIControlStateNormal];
        if (i==0) {
            [cell setImages:[Access getPhotoWithModel:[NSNumber numberWithInt:1]]];
        }
        if (i==5) {
            [cell setImages:[Access getPhotoWithModel:[NSNumber numberWithInt:2]]];
        }
        [self.view addSubview:cell];
        [cell setTag:i+1];
        [cell release];
        
        [UIView animateWithDuration:0.6 delay:0.15 * i options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [cell setFrame:rect];
        } completion:^(BOOL finished) {
            [cell setBackgroundImage:[UIImage imageNamed:path] forState:UIControlStateNormal];
            [cell.backgroundView setBackgroundColor:[UIColor colorWithHex:curCol]];
        }];
    }
    //
    if ([Utils extendsWindow]) {
        UIView *view = [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
		[[Utils extendsWindow] addSubview:view];
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
    [self performSelector:@selector(resetCurrentCell:) withObject:nil afterDelay:0.4];
}
-(void)resetCurrentCell:(id)sender{
    if (currentCell) {
        CGRect rect = [[cellFrame objectAtIndex:currentCell.tag-1] CGRectValue];
        [currentCell setActive:NO];
        [UIView animateWithDuration:0.4 animations:^{
            currentCell.frame = rect;
        }];
    }
    currentCell = nil;
}

//.............................................................
-(void)cellTouch:(HomeViewCell*)sender{
    currentCell = sender;
    [currentCell setActive:YES];
    [self.view addSubview:currentCell];
    
    [UIView animateWithDuration:0.4 animations:^{
        currentCell.frame = CGRectMake(0, 0, 1024, 768);
    } completion:^(BOOL finished) {
        switch (currentCell.tag) {
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
    }];
}
-(UIImage*)blurWithImage:(UIImage*)image {
    float weight[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};
    // Blur horizontally
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[0]];
    for (int x = 1; x < 5; ++x) {
        [image drawInRect:CGRectMake(x, 0, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[x]];
        [image drawInRect:CGRectMake(-x, 0, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[x]];
    }
    UIImage *horizBlurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Blur vertically
    UIGraphicsBeginImageContext(image.size);
    [horizBlurredImage drawInRect:CGRectMake(0, 0, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[0]];
    for (int y = 1; y < 5; ++y) {
        [horizBlurredImage drawInRect:CGRectMake(0, y, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[y]];
        [horizBlurredImage drawInRect:CGRectMake(0, -y, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[y]];
    }
    UIImage *blurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //
    return blurredImage;
}
@end
