//
//  featuresViewController.m
//  derucci-v6
//
//  Created by mac on 13-8-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "Access.h"
#import "NavigateView.h"
#import "FeatureViewController.h"
#import "FeaturesViewController.h"

@interface FeaturesViewController (){
    NSArray *source;
}
@end

@implementation FeaturesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSString *string = [NSString stringWithContentsOfFile:[Utils pathForDocument:@"feature/data.json"] encoding:NSUTF8StringEncoding error:nil];
    source = [[string JSONValue] retain];
    //
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
    
    NSArray *frame = [NSArray arrayWithObjects:
                      [NSValue valueWithCGRect:CGRectMake(27 , 121, 316, 527)],
                      [NSValue valueWithCGRect:CGRectMake(351, 176, 316, 528)],
                      [NSValue valueWithCGRect:CGRectMake(674 , 153, 317, 527)],nil];
    for (int i=0; i<frame.count; i++) {
        NSString *path = [NSString stringWithFormat:@"source/feature_icon%d.png",i+1];
        CGRect curFrame = [[frame objectAtIndex:i] CGRectValue];
        
        UIButton *cell = [GUI buttonWithFrame:CGRectOffset(curFrame, 0, (i%2==0 ? -768 : 768)) parent:self.view normal:path target:self event:@selector(cellTouch:)];
        [self.view addSubview:cell];
        [cell setTag:i+1];
        [cell setAlpha:0];
        
        [UIView animateWithDuration:0.6 delay:0.15 * i options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [cell setFrame:curFrame];
            [cell setAlpha:1];
        } completion:nil];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [source release],source=nil;
}

-(void)dealloc{
    [source release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)viewDidAppear:(BOOL)animated{
    NavigateView *nav = [NavigateView shareInstanceInView:self.view];
    [nav.background setHidden:YES];
    //
    if ([GUIExt extendsView]) {
        [GUIExt extendsView].animationImages=[Access ExtendsImages];
    }
}

//
-(void)cellTouch:(UIButton*)sender{
    if (sender.tag>1) {
        return;
    }
    FeatureViewController *feature = (FeatureViewController*)[Utils gotoWithName:@"FeatureViewController" animated:UITransitionStyleCoverHorizontal];
    feature.source = [source objectAtIndex:sender.tag-1];
}
@end
