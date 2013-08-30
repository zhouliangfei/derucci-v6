//
//  AboutViewController.m
//  derucci-v6
//
//  Created by mac on 13-8-6.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "Access.h"
#import "NavigateView.h"
#import "AboutViewController.h"
#import "AboutFlipViewController.h"
#import "MediaPlayer/MediaPlayer.h"

//..................................................
@interface AboutViewCell : UIControl{
    UIImageView *shadowView;
    UIButton *imagetView;
}
@property(nonatomic,assign) UIImage *image;
@end

@implementation AboutViewCell
@dynamic image;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        shadowView = [[GUI imageWithFrame:CGRectMake(241, 2, 58, 212) parent:self source:@"source/about_shadown.png"] retain];
        
        imagetView = [[UIButton buttonWithFrame:CGRectMake(0, 0, 241, 214)] retain];
        [imagetView setContentMode:UIViewContentModeScaleAspectFit];
        [imagetView setUserInteractionEnabled:NO];
        [self addSubview:imagetView];
    }
    return self;
}
-(void)dealloc{
    [shadowView release];
    [imagetView release];
    [super dealloc];
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [imagetView setFrame:CGRectMake(0, 1, 241, 214)];
    [shadowView setFrame:CGRectMake(241, 0, 49, 216)];
}
-(void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
    [imagetView setHighlighted:highlighted];
}
-(void)setImage:(UIImage *)image{
    [imagetView setImage:image forState:UIControlStateNormal];
}
@end

//..................................................
@interface AboutViewController (){
    NSArray *source;
    UITableView *bookView;
}
@property(nonatomic,retain) MPMoviePlayerController *moviePlayer;
@end

@implementation AboutViewController
@synthesize moviePlayer;

- (void)viewDidLoad
{
    [super viewDidLoad];

    source = [[Access getBrandstoryWithCategory:[NSNumber numberWithInt:0]] retain];
	
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
    bookView = [[UITableView alloc] initWithFrame:CGRectMake(0, 132, 1024, 636)];
    [bookView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [bookView setBackgroundColor:[UIColor clearColor]];
    [bookView setDataSource:self];
    [bookView setDelegate:self];
    [self.view addSubview:bookView];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [bookView release],bookView=nil;
    [source release],source=nil;
    [self setMoviePlayer:nil];
    [super viewDidUnload];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [moviePlayer release];
    [bookView release];
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

//tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ceilf((float)source.count/3.f);
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 358;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"aboutTableIdentifier"; 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        //
        [GUI imageWithFrame:CGRectMake(67, 21, 957, 308) parent:cell source:@"source/about_cellBase.png"];
    }
    //清空旧数据
    for (UIView *tmp in cell.subviews){
        if ([tmp isKindOfClass:[AboutViewCell class]]) {
            [tmp removeFromSuperview];
        }
    }
    //新数据
    uint b = indexPath.row * 3;
    uint e = fmin(b + 3, [source count]);
    for (uint i=b; i<e; i++){
        NSString *filePath = [[source objectAtIndex:i] objectForKey:@"photo"];
        
        AboutViewCell *item = [[AboutViewCell alloc] initWithFrame:CGRectMake(97+i%3*291, 0, 290, 214)];
        [item addTarget:self action:@selector(cellTouch:) forControlEvents:UIControlEventTouchUpInside];
        [item setImage:[UIImage imageWithDocument:filePath]];
        [item setTag:i+1];
        [cell addSubview:item];
        [item release];
    }
    
    return cell;
}

-(void)cellTouch:(AboutViewCell*)sender{
    id cur = [source objectAtIndex:sender.tag-1];
    if ([[cur objectForKey:@"fileType"] intValue]==0) {
        AboutFlipViewController *book = (AboutFlipViewController*)[Utils gotoWithName:@"AboutFlipViewController" animated:UITransitionStyleCoverHorizontal];
        book.source = [Access getBrandstoryPictureWithId:[cur objectForKey:@"id"]];
    }else {
        [self showVideoWithPath:[Utils pathForDocument:[cur objectForKey:@"file"]]];
    }
}
//
-(void)showVideoWithPath:(NSString*)path{
    NSURL *url = [NSURL fileURLWithPath:path];
    if (url && nil==moviePlayer) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        
        self.moviePlayer = [[[MPMoviePlayerController alloc] init] autorelease];
        [moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
        [moviePlayer.view setFrame:CGRectMake(0, 0, 1024, 768)];
        [moviePlayer setContentURL:url];
        [moviePlayer play];
        [self.view addSubview:moviePlayer.view];
        [self.view.layer addAnimation:[CATransition animation] forKey:nil];
    }
}
-(void)moviePlayerPlaybackFinish:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (moviePlayer.view.superview) {
        [moviePlayer.view removeFromSuperview];
        [self.view.layer addAnimation:[CATransition animation] forKey:nil];
    }
    [self setMoviePlayer:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
}

@end
