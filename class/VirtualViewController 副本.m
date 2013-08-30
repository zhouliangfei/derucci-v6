//
//  VirtualViewController.m
//  derucci-v6
//
//  Created by mac on 13-8-16.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "Access.h"
#import "NavigateView.h"
#import "VirtualViewController.h"

@interface VirtualViewController (){
    NSDictionary *source;
    UIView *mapView;
    UIView *panoView;
    UIView *bottomView;
    UIFlipView *thumbView;
    //
    int currentArea;
    int currentPano;
    float pan;
    float tilt;
}
@end

@implementation VirtualViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *string = [NSString stringWithContentsOfFile:[Utils pathForDocument:@"virtual/data.json"] encoding:NSUTF8StringEncoding error:nil];
    source = [[string JSONValue] retain];
    currentArea = -1;
	
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
    [GUI imageWithFrame:CGRectMake(366, 110, 279, 33) parent:self.view source:@"source/virtual_title.png"];
    
    panoView = [GUI viewWithFrame:CGRectMake(0, -593, 1024, 593) parent:self.view];

    bottomView = [GUI viewWithFrame:CGRectMake(0, 768, 1024, 175) parent:self.view];
    thumbView = [[UIFlipView alloc] initWithFrame:CGRectMake(21, 19, 660, 117)];
    [thumbView setClearance:12.f];
    [thumbView setDataSource:self];
    [thumbView setDelegate:self];
    [bottomView addSubview:thumbView];
    [thumbView release];
    
    mapView = [GUI viewWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view];
    [GUI imageWithFrame:CGRectFromString([source objectForKey:@"frame"]) parent:mapView document:[source objectForKey:@"path"]];
    NSArray *area = [source objectForKey:@"area"];
    for (int i=0; i<area.count; i++) {
        CGPoint center = CGPointFromString([[area objectAtIndex:i] objectForKey:@"position"]);
        
        UIButton *btn = [GUI buttonWithFrame:CGRectMake(0, 0, 43, 69) parent:mapView normal:@"source/virtual_icon_nor.png" active:@"source/virtual_icon_act.png" target:self event:@selector(mapTouch:)];
        [btn setCenter:CGPointMake(center.x, center.y-200)];
        [btn setAlpha:0];
        [btn setTag:i+1];
        
        [UIView animateWithDuration:0.4 delay:0.15 * i options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [btn setCenter:CGPointMake(center.x, center.y-btn.frame.size.height/2)];
            [btn setAlpha:1];
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
-(void)mapTouch:(UIButton*)sender{
    if (NO == sender.selected) {
        currentArea = sender.tag-1;
        currentPano = 0;
        //
        for (UIButton *btn in mapView.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                [btn setSelected:btn==sender];
            }
        }
        [thumbView reloadData];
        [self displayPano];
        //
        [UIView beginAnimations:nil context:nil];
        [mapView setTransform:CGAffineTransformMakeScale(0.34, 0.34)];
        [mapView setCenter:CGPointMake(853, 640)];
        [panoView setFrame:CGRectMake(0, 0, 1024, 593)];
        [bottomView setFrame:CGRectMake(0, 593, 1024, 175)];
        [UIView commitAnimations];
    }
}
-(void)thumbTouch:(UIControl*)sender{
    if (NO == sender.selected) {
        currentPano = sender.tag-1;
        //
        for (UIControl *btn in thumbView.subviews) {
            if ([btn isKindOfClass:[UIControl class]]) {
                [btn setSelected:btn==sender];
            }
        }
        [self displayPano];
    }
}
-(void)displayPano{
    id cur = [[[[source objectForKey:@"area"] objectAtIndex:currentArea] objectForKey:@"panorama"] objectAtIndex:currentPano];
    [self makePanoView:cur];
}

//列表
-(NSInteger)numberOfCellInFlipView:(UIFlipView *)flipView{
    if (currentArea>=0) {
        return [[[[source objectForKey:@"area"] objectAtIndex:currentArea] objectForKey:@"panorama"] count];
    }
    return 0;
}
-(UIFlipViewCell *)flipView:(UIFlipView *)flipView cellAtIndex:(NSInteger)index{
    static NSString *simpleFlipIdentifier = @"aboutFlipIdentifier";
    GUIFlipBorderCell *cell = (GUIFlipBorderCell*)[flipView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
    if (cell == nil){
        cell = [[[GUIFlipBorderCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
        [cell addTarget:self action:@selector(thumbTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    id value = [[[source objectForKey:@"area"] objectAtIndex:currentArea] objectForKey:@"panorama"];
    NSString *filePath = [[value objectAtIndex:index] objectForKey:@"thumb"];
    [cell setImage:[UIImage imageWithDocument:filePath]];
    [cell setSelected:index==currentPano];
    [cell setTag:index+1];
    return cell;
}
-(CGFloat)flipView:(UIFlipView *)flipView sizeAtIndex:(NSInteger)index{
    return 156;
}

//..............................................................
-(void)view:(PLViewBase *)plView pointTouch:(PLButton*)sender{
    NSDictionary *dat = sender.data;
    currentPano = [[dat objectForKey:@"target"] intValue]-1;
    //
    pan = 360.f-[[dat objectForKey:@"pan"] floatValue];
    tilt = [[dat objectForKey:@"tilt"] floatValue];
    [self makePanoView:dat];
}
-(void)makePanoView:(id)data{
    PLView *pano = [[PLView alloc] initWithFrame:panoView.bounds];
    [pano setIsDeviceOrientationEnabled:NO];
	[pano setIsAccelerometerEnabled:NO];
    [pano setType:PLViewTypeCubeFaces];
    [pano addCubeTexture:[self getTexture:[data objectForKey:@"path"]]];
    [pano.camera setRotation:PLRotationMake(tilt, pan, 0)];
    [pano setDelegate:self];
    [pano setAlpha:0.0f];
    [pano drawView];
    [panoView addSubview:pano];
    [pano release];
    //
    pan = 0.0f;
    tilt = 0.0f;
    //生成热点
    for (id pt in [data objectForKey:@"point"]){
        PLButton *btn = [pano addPointWithImage:[UIImage imageNamed:@""]];
        btn.u = [[pt objectForKey:@"u"] floatValue];
        btn.v = [[pt objectForKey:@"v"] floatValue];
        btn.data = pt;
    }
    //
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveLinear animations:^(){
        pano.alpha = 1.0f;
    } completion:^(BOOL finished){
        for (UIView *item in panoView.subviews){
            if ([item isKindOfClass:[PLView class]] && item != pano) {
                [item removeFromSuperview];
            }
        }
    }];
}
-(id)getTexture:(NSString*)dir{
    NSMutableDictionary *texture = [NSMutableDictionary dictionary];
    NSString *bottom = [NSString stringWithFormat:dir,@"d"];
    NSString *front = [NSString stringWithFormat:dir,@"f"];
    NSString *right = [NSString stringWithFormat:dir,@"r"];
    NSString *back = [NSString stringWithFormat:dir,@"b"];
    NSString *left = [NSString stringWithFormat:dir,@"l"];
    NSString *top = [NSString stringWithFormat:dir,@"u"];
    [texture setValue:[PLTexture textureWithImage:[UIImage imageWithDocument:bottom]] forKey:@"bottom"];
    [texture setValue:[PLTexture textureWithImage:[UIImage imageWithDocument:front]] forKey:@"front"];
    [texture setValue:[PLTexture textureWithImage:[UIImage imageWithDocument:right]] forKey:@"right"];
    [texture setValue:[PLTexture textureWithImage:[UIImage imageWithDocument:back]] forKey:@"back"];
    [texture setValue:[PLTexture textureWithImage:[UIImage imageWithDocument:left]] forKey:@"left"];
    [texture setValue:[PLTexture textureWithImage:[UIImage imageWithDocument:top]] forKey:@"top"];
    return texture;
}
@end
