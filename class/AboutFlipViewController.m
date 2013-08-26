//
//  AboutFlipViewController.m
//  derucci-v6
//
//  Created by mac on 13-8-7.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "NavigateView.h"
#import "AboutFlipViewController.h"

//..................................................
@interface AboutFlipViewController (){
    int page;
    UIFlipView *bookView;
    UIFlipView *thumbView;
}
@end

@implementation AboutFlipViewController
@synthesize source;

- (void)viewDidLoad
{
    [super viewDidLoad];
    page = 0;
    
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
    [GUI imageWithFrame:CGRectMake(0, 116, 1024, 479) parent:self.view source:@"source/about_bookBase.png"];
    [GUI imageWithFrame:CGRectMake(0, 595, 1024, 85) parent:self.view source:@"source/about_thumbBase.png"];
    
    bookView = [[UIFlipView alloc] initWithFrame:CGRectMake(0, 140, 1024, 455)];
    [bookView setPagingEnabled:YES];
    [bookView setDataSource:self];
    [bookView setDelegate:self];
    [self.view addSubview:bookView];
    
    thumbView = [[UIFlipView alloc] initWithFrame:CGRectMake(21, 580, 982, 87)];
    [thumbView setContentInset:UIEdgeInsetsMake(28, 0, 0, 0)];
    [thumbView setClearance:12.f];
    [thumbView setDataSource:self];
    [thumbView setDelegate:self];
    [self.view addSubview:thumbView];
}

- (void)viewDidUnload
{
    [self setSource:nil];
    [bookView release],bookView=nil;
    [thumbView release],thumbView=nil;
    [super viewDidUnload];
}

-(void)dealloc{
    [source release];
    [bookView release];
    [thumbView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)viewDidAppear:(BOOL)animated{
    [NavigateView shareInstanceInView:self.view];
}

//
-(void)thumbTouch:(GUIFlipBeatCell*)sender{
    if (NO == sender.selected) {
        for (UIView *view in thumbView.subviews) {
            if ([view isKindOfClass:GUIFlipBeatCell.class]) {
                [(UIControl*)view setSelected:sender==view];
            }
        }
        //
        int value = [thumbView indexForCell:sender];
        [bookView scrollRectToVisible:CGRectMake(value*1024, 0, 1024, 455) animated:YES];
    }
}
//代理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == bookView){
        int value = floor((bookView.contentOffset.x + bookView.frame.size.width * 0.5) / bookView.frame.size.width); 
        if (value != page){
            page = value;
            [thumbView scrollRectToVisible:CGRectMake(value*142, 0, 130, 59) animated:YES];
            //
            for (GUIFlipBeatCell *item in thumbView.subviews) {
                if ([item isKindOfClass:[GUIFlipBeatCell class]]){
                    item.selected = (item.tag-1==page);
                }
            }
        }
    }
}
-(NSInteger)numberOfCellInFlipView:(UIFlipView *)flipView{
    return [source count];
}
-(UIFlipViewCell *)flipView:(UIFlipView *)flipView cellAtIndex:(NSInteger)index{
    static NSString *simpleFlipIdentifier = @"aboutFlipIdentifier";
    
    if (flipView==bookView) {
        GUIFlipCell *cell = (GUIFlipCell*)[flipView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
        if (cell == nil){
            cell = [[[GUIFlipCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
        }
        
        NSString *filePath = [[source objectAtIndex:index] objectForKey:@"photo"];
        [cell setImage:[UIImage imageWithDocument:filePath]];
        return cell;
    }
    //thumbView
    GUIFlipBeatCell *cell = (GUIFlipBeatCell*)[flipView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
    if (cell == nil){
        cell = [[[GUIFlipBeatCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
    }
    NSString *filePath = [[source objectAtIndex:index] objectForKey:@"smallPhoto"];
    [cell addTarget:self action:@selector(thumbTouch:) forControlEvents:UIControlEventTouchUpInside];
    [cell setImage:[UIImage imageWithDocument:filePath]];
    [cell setSelected:index==page];
    [cell setTag:index+1];
    return cell;
}
-(CGFloat)flipView:(UIFlipView *)flipView sizeAtIndex:(NSInteger)index{
    if (flipView==bookView) {
        return 1024;
    }
    return 130;
}
@end
