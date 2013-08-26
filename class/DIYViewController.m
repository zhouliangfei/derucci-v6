//
//  DIYViewController.m
//  derucci-v6
//
//  Created by mac on 13-8-21.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "NavigateView.h"
#import "DIYViewController.h"

@interface DIYStepView : UIButton{
    UILabel *tagView;
}
@end
@implementation DIYStepView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        tagView=[GUI lableWithFrame:CGRectZero parent:self text:nil font:[UIFont fontWithName:@"Arial-ItalicMT" size:16] color:[UIColor whiteColor] align:1];
        [self setBackgroundImage:[UIImage imageNamed:@"source/DIY_btn0.png"] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:11]];
        [self setSelected:NO];
        //
        self.imageView.layer.borderWidth = 1;
        self.imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    //
    [tagView setFrame:CGRectMake(0, 9, 24, 61)];
    [self.imageView setFrame:CGRectMake(83, 9, 81, 61)];
    [self.titleLabel setFrame:CGRectMake(24, 9, 59, 61)];
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        [tagView setTextColor:[UIColor whiteColor]];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else {
        [tagView setTextColor:[UIColor colorWithHex:0x6a4343ff]];
        [self setTitleColor:[UIColor colorWithHex:0x6a4343ff] forState:UIControlStateNormal];
    }
}
-(void)setTag:(NSInteger)tag{
    [super setTag:tag];
    [tagView setText:[NSString stringWithFormat:@"%d",tag]];
}
@end

//............................................................
@interface DIYPhotoCell : UIPerspectViewCell{
    UIImageView *imageView;
}
@property(nonatomic,readonly) UIImageView *imageView;
@end

@implementation DIYPhotoCell
@synthesize imageView;
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        imageView = [[GUI imageWithFrame:self.bounds parent:self] retain];
        [self setSelected:NO];
    }
    return self;
}
-(void)dealloc{
    [imageView release];
    [super dealloc];
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [imageView setFrame:self.bounds];
}
@end

//............................................................
@interface DIYPerspectView : UIPerspectView
@property(nonatomic,retain) NSArray *access;
@end
@implementation DIYPerspectView
@synthesize access;
-(void)dealloc{
    [access release];
    [super dealloc];
}
@end

//............................................................
@interface DIYViewController (){
    UIView *leftView;
    UILabel *nameView;
    UITextView *infoView;
    UIFlipView *bookView;
    UIButton *showView;
    UIView *finishView;
    UIView *diyView;
    //
    NSArray *stepData;
    int currentPage;
}
@property(nonatomic,retain) NSDictionary *source;
@end

@implementation DIYViewController
@synthesize source;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *string = [NSString stringWithContentsOfFile:[Utils pathForDocument:@"diy/data.json"] encoding:NSUTF8StringEncoding error:nil];
    source = [[string JSONValue] retain];
    
    currentPage = -1;
	
    NSArray *frame = [NSArray arrayWithObjects:
                      [NSValue valueWithCGRect:CGRectMake(0, 0, 171, 80)],
                      [NSValue valueWithCGRect:CGRectMake(0, 83, 171, 80)],
                      [NSValue valueWithCGRect:CGRectMake(0, 166, 171, 80)],
                      [NSValue valueWithCGRect:CGRectMake(0, 249, 171, 80)],
                      [NSValue valueWithCGRect:CGRectMake(0, 332, 171, 80)],nil];
    NSArray *title = [NSArray arrayWithObjects:@"选择床架",@"选择布料",@"选择床垫",@"选择排骨架",@"选择床品",nil];
    //
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
    
    //步骤界面
    leftView=[GUI viewWithFrame:CGRectMake(11, 168, 171, 412) parent:self.view];
    for (int i=0; i<frame.count; i++) {
        CGRect rect = [[frame objectAtIndex:i] CGRectValue];
        DIYStepView *cell = [self makeStepWithLable:[title objectAtIndex:i] frame:CGRectOffset(rect, -512, 0) parent:leftView tag:i+1];
        [UIView animateWithDuration:0.4 delay:0.15 * i options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [cell setFrame:rect];
        } completion:nil];
    }
    
    //diy界面
    diyView = [GUI viewWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view];
    bookView = [[UIFlipView alloc] initWithFrame:CGRectMake(182, 75, 842, 693)];
    [bookView setPagingEnabled:YES];
    [bookView setDataSource:self];
    [bookView setDelegate:self];
    [diyView addSubview:bookView];
    
    [GUI imageWithFrame:CGRectMake(496, 549, 270, 24) parent:diyView source:@"source/DIY_360.png"];
    nameView=[GUI lableWithFrame:CGRectMake(250, 596, 673, 42) parent:diyView text:nil font:[UIFont fontWithName:@"HelveticaNeueLTStd-ThCn" size:34] color:[UIColor blackColor] align:0];
    infoView=[GUI textViewWithFrame:CGRectMake(250, 643, 673, 58) parent:diyView text:nil font:[UIFont boldSystemFontOfSize:12] color:[UIColor blackColor] align:0];
    
    showView=[GUIExt buttonWithFrame:CGRectMake(815, 597, 106, 30) parent:diyView normal:@"source/DIY_btn1.png" icon:@"source/DIY_icon1.png" title:@"完成搭配" target:self event:@selector(showTouch:)];
    [showView setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [showView setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [showView setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [showView.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [showView setAlpha:0];
    
    //完成界面
    finishView = [GUI viewWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view];
    UIButton *resetView=[GUIExt buttonWithFrame:CGRectMake(638, 685, 143, 44) parent:finishView normal:@"source/DIY_btn2.png" icon:@"source/DIY_icon3.png" title:@"重新选择" target:self event:@selector(resetTouch:)];
    [resetView setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [resetView setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [resetView setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [resetView.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    
    UIButton *printView=[GUIExt buttonWithFrame:CGRectMake(485, 685, 143, 44) parent:finishView normal:@"source/DIY_btn2.png" icon:@"source/DIY_icon2.png" title:@"打印清单" target:self event:@selector(printTouch:)];
    [printView setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [printView setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [printView setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [printView.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [finishView setAlpha:0];
    
    //leftView最上层
    [self.view addSubview:leftView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [bookView release],bookView=nil;
}

-(void)dealloc{
    [bookView release];
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
-(void)showTouch:(UIButton*)sender{
    for (int i=0; i<5; i++) {
        DIYStepView *view = (DIYStepView*)[leftView viewWithTag:i+1];
        [view setSelected:NO];
    }
    //
    for (UIView *view in finishView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    [GUI imageWithFrame:CGRectMake(308, 306, 590, 231) parent:finishView document:[NSString stringWithFormat:@"diy/view_a/View_a_%d_%d.png",selected[0],selected[1]]];
    [GUI imageWithFrame:CGRectMake(308, 306, 590, 231) parent:finishView document:[NSString stringWithFormat:@"diy/view_b/View_b_%d_%d.png",selected[4],selected[1]]];
    //
    [UIView beginAnimations:nil context:nil];
    [finishView setAlpha:1];
    [diyView setAlpha:0];
    [sender setAlpha:0];
    [UIView commitAnimations];
}
-(void)resetTouch:(UIButton*)sender{
    currentPage = -1;
    for (int i=0; i<5; i++) {
        DIYStepView *view = (DIYStepView*)[leftView viewWithTag:i+1];
        [view setImage:nil forState:UIControlStateNormal];
        selected[i]=0;
    }
    //
    [bookView setContentOffset:CGPointZero];
    [bookView reloadData];
    //
    [UIView beginAnimations:nil context:nil];
    [finishView setAlpha:0];
    [diyView setAlpha:1];
    [UIView commitAnimations];
}
-(void)printTouch:(UIButton*)sender{
    
}
//
-(id)makeStepWithLable:(NSString*)lable frame:(CGRect)frame parent:(UIView*)parent tag:(int)tag{
    DIYStepView *temp = [[DIYStepView alloc] initWithFrame:frame];
    [temp setTitle:lable forState:UIControlStateNormal];
    [temp setTag:tag];
    [parent addSubview:temp];
    return [temp autorelease];
}
-(id)getDataWithArray:(NSArray*)array key:(NSString*)key value:(int)value{
    NSMutableArray *temp = [NSMutableArray array];
    for (id item in array) {
        NSArray *arr = [item objectForKey:key];
        if (NSNotFound!=[arr indexOfObject:[NSNumber numberWithInt:value]]) {
            [temp addObject:item];
        }
    }
    return temp;
}
-(id)getDataWithStep:(int)step{
    if (step==0) {
        return [source objectForKey:@"bed"];
    }
    else if (step==1) {
        return [self getDataWithArray:[source objectForKey:@"bedColor"] key:@"bedId" value:selected[0]];
    }
    else if (step==2) {
        return [self getDataWithArray:[source objectForKey:@"bedStead"] key:@"bedId" value:selected[0]];
    }
    else if (step==3) {
         return [self getDataWithArray:[source objectForKey:@"mattress"] key:@"steadId" value:selected[2]];
    }
    else if (step==4) {
        return [self getDataWithArray:[source objectForKey:@"bedding"] key:@"mattressId" value:selected[3]];
    }
    return nil;
}
//

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    DIYPerspectView *perView = nil;
    if (scrollView==bookView) {
        int value = floorf((bookView.contentOffset.x + bookView.frame.size.width * 0.5) / bookView.frame.size.width);
        if (currentPage != value) {
            currentPage = value;
            for (DIYStepView *view in leftView.subviews) {
                [view setSelected:view.tag==value+1];
            }
        }
        UIFlipViewCell *cell = [bookView cellForIndex:value];
        if (cell) {
            perView = (DIYPerspectView*)[cell viewWithTag:value+1];
        }
    }else {
        perView =(DIYPerspectView*)scrollView;
    }
    
    if (perView) {
        int page = floorf((perView.contentOffset.y + perView.frame.size.height * 0.5) / perView.frame.size.height);
        if (perView.access.count>page) {
            id cur = [perView.access objectAtIndex:page];
            nameView.text = [cur objectForKey:@"name"];
            infoView.text = [cur objectForKey:@"content"];
        }
    }
}
-(NSInteger)numberOfCellInFlipView:(UIFlipView *)flipView{
    return 5;
}
-(UIFlipViewCell *)flipView:(UIFlipView *)flipView cellAtIndex:(NSInteger)index{
    static NSString *simpleFlipIdentifier = @"aboutFlipIdentifier";
    UIFlipViewCell *cell = [flipView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
    if (cell == nil){
        cell = [[[UIFlipViewCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
    }
    //
    for (UIView *view in cell.subviews) {
        [view removeFromSuperview];
    }
    DIYPerspectView *book3dView = [[DIYPerspectView alloc] initWithFrame:CGRectMake(0, 0, flipView.bounds.size.width, flipView.bounds.size.height)];
    [book3dView setAccess:[self getDataWithStep:index]];
    [book3dView setPagingEnabled:YES];
    [book3dView setTag:index+1];
    [book3dView setDataSource:self];
    [book3dView setDelegate:self];
    [cell addSubview:book3dView];
    [book3dView release];
    //
    return cell;
}
//PerspectView
-(CGSize)perspectView:(UIPerspectView *)perspectView sizeAtIndex:(NSInteger)index{
    return CGSizeMake(629, 321);
}
-(NSInteger)numberOfCellInPerspectView:(UIPerspectView *)perspectView{
    [self scrollViewDidScroll:bookView];
    return ((DIYPerspectView*)perspectView).access.count;
}
-(UIPerspectViewCell *)perspectView:(UIPerspectView *)perspectView cellAtIndex:(NSInteger)index{
    static NSString *simpleFlipIdentifier = @"aboutFlipIdentifier";
    DIYPhotoCell *cell = (DIYPhotoCell*)[perspectView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
    if (cell == nil){
        cell = [[[DIYPhotoCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
        [cell addTarget:self action:@selector(productTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    NSDictionary *dic = [((DIYPerspectView*)perspectView).access objectAtIndex:index];
    [cell.imageView setImage:[UIImage imageWithDocument:[dic  objectForKey:@"photo"]]];
    [cell setTag:index+1];
    //
    return cell;
}
-(void)productTouch:(DIYPhotoCell*)sender{
    int ind = sender.superview.tag-1;
    id tmp = [((DIYPerspectView*)sender.superview).access objectAtIndex:sender.tag-1];

    for (int i=ind; i<5; i++) {
        DIYStepView *view = (DIYStepView*)[leftView viewWithTag:i+1];
        if (i==ind) {
            [view setImage:[UIImage imageWithDocument:[tmp objectForKey:@"thumb"]] forState:UIControlStateNormal];
            selected[ind]=[[tmp objectForKey:@"id"] intValue];
        }else {
            [view setImage:nil forState:UIControlStateNormal];
            selected[i]=0;
        }
    }
    //
    BOOL isFinish = true;
    for (int i=0; i<5; i++) {
        if (selected[i]==0) {
            isFinish = false;
            break;
        }
    }
    [showView setAlpha:isFinish ? 1 : 0];
}
@end
