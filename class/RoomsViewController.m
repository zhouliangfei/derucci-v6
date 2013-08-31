//
//  RoomsViewController.m
//  derucci-v6
//
//  Created by mac on 13-8-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "Access.h"
#import "NavigateView.h"
#import "RoomViewController.h"
#import "RoomsViewController.h"

@interface RoomsViewController ()

@end

@implementation RoomsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
    
    NSArray *frame = [NSArray arrayWithObjects:
                      [NSValue valueWithCGRect:CGRectMake(10 , 130, 168, 515)],
                      [NSValue valueWithCGRect:CGRectMake(178, 195, 167, 512)],
                      [NSValue valueWithCGRect:CGRectMake(344 , 93, 168, 515)],
                      [NSValue valueWithCGRect:CGRectMake(512 , 142, 168, 515)],
                      [NSValue valueWithCGRect:CGRectMake(679 , 207, 167, 512)],
                      [NSValue valueWithCGRect:CGRectMake(846 , 114, 168, 515)],nil];
    for (int i=0; i<frame.count; i++) {
        NSString *path = [NSString stringWithFormat:@"source/room_icon%d.png",i+1];
        CGRect curFrame = [[frame objectAtIndex:i] CGRectValue];
        
        UIButton *cell = [GUI buttonWithFrame:CGRectOffset(curFrame, 0, (i%2==0 ? -768 : 768)) parent:self.view normal:path target:self event:@selector(cellTouch:)];
        [cell addTarget:self action:@selector(cellTouch:) forControlEvents:UIControlEventTouchUpInside];
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
    // Release any retained subviews of the main view.
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
    id val = [Access getRoomsWithId:[NSNumber numberWithInt:sender.tag]];
    if (val) {
        RoomViewController *room = (RoomViewController*)[Utils gotoWithName:@"RoomViewController" animated:UITransitionStyleCoverHorizontal];
        room.source = [val lastObject];
    }
}
@end
