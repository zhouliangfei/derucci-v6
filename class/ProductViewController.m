//
//  ProductViewController.m
//  derucci-v6
//
//  Created by mac on 13-8-14.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "Access.h"
#import "UIFlipView.h"
#import "UIPerspectView.h"
#import "NavigateView.h"
#import "ProductViewController.h"

//............................................................
@interface ProductPhotoCell : UIPerspectViewCell{
    UITextView *textView;
    UIImageView *imageView;
}
@property(nonatomic,readonly) UIImageView *imageView;
@property(nonatomic,readonly) UITextView *textView;
@end

@implementation ProductPhotoCell
@synthesize imageView;
@synthesize textView;
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        textView = [[GUI lableWithFrame:CGRectZero parent:self text:nil font:[UIFont systemFontOfSize:30] color:[UIColor colorWithHex:0xc8c8c8ff] align:1] retain];
        imageView = [[GUI imageWithFrame:CGRectZero parent:self] retain];
        [self setSelected:NO];
    }
    return self;
}
-(void)dealloc{
    [textView release];
    [imageView release];
    [super dealloc];
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [textView setFrame:CGRectMake(0, frame.size.height, frame.size.width, 85)];
    [imageView setFrame:CGRectMake(15, 15, frame.size.width-30, frame.size.height-30)];
}
@end
//.........................
@interface ProductPhoto : UIView<UIPerspectViewDataSource,UIPerspectViewDelegate>{
    UIPerspectView *contentView;
}
@property(nonatomic,retain) NSArray *source;
@end

@implementation ProductPhoto
@synthesize source;
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithHex:0xffffffdd]];
        contentView = [[UIPerspectView alloc] initWithFrame:self.bounds];
        [contentView setPagingEnabled:YES];
        [contentView setDataSource:self];
        [contentView setDelegate:self];
        [self addSubview:contentView];
    }
    return self;
}
-(void)dealloc{
    [source release];
    [contentView release];
    [super dealloc];
}
-(CGSize)perspectView:(UIPerspectView *)perspectView sizeAtIndex:(NSInteger)index{
    return CGSizeMake(663, 497);
}
-(NSInteger)numberOfCellInPerspectView:(UIPerspectView *)perspectView{
    return [source count];
}
-(UIPerspectViewCell *)perspectView:(UIPerspectView *)perspectView cellAtIndex:(NSInteger)index{
    static NSString *simpleFlipIdentifier = @"aboutFlipIdentifier";
    ProductPhotoCell *cell = (ProductPhotoCell*)[perspectView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
    if (cell == nil){
        cell = [[[ProductPhotoCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
    }
    [cell.imageView setImage:[UIImage imageWithDocument:[[source objectAtIndex:index] objectForKey:@"bigPhoto"]]];
    [cell.textView setText:[NSString stringWithFormat:@"%d/%d",index+1,[source count]]];
    return cell;
}
@end

//............................................................
@interface ProductColorsCell : UIFlipViewCell{
    UITextView *textView;
    UIImageView *imageView;
}
@property(nonatomic,readonly) UIImageView *imageView;
@property(nonatomic,readonly) UITextView *textView;
@end

@implementation ProductColorsCell
@synthesize imageView;
@synthesize textView;
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        textView = [[GUI lableWithFrame:CGRectZero parent:self text:nil font:[UIFont systemFontOfSize:12] color:[UIColor blackColor] align:0] retain];
        imageView = [[GUI imageWithFrame:CGRectZero parent:self] retain];
        [self setSelected:NO];
    }
    return self;
}
-(void)dealloc{
    [textView release];
    [imageView release];
    [super dealloc];
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [textView setFrame:CGRectMake(0, frame.size.height-29, frame.size.width, 29)];
    [imageView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-29)];
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        imageView.layer.borderWidth = 5;
        imageView.layer.borderColor = [[UIColor orangeColor] CGColor];
    }else {
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [[UIColor grayColor] CGColor];
    }
}
@end
//.........................
@interface ProductColors : UIView<UIFlipViewDelegate,UIFlipViewDataSource>{
    UIFlipView *contentView;
}
@property(nonatomic,retain) NSArray *source;
@end

@implementation ProductColors
@synthesize source;
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithHex:0xffffffdd]];
        contentView = [[UIFlipView alloc] initWithFrame:CGRectMake(34, 27, frame.size.width-68, frame.size.height-54)];
        [contentView setClearance:34];
        [contentView setDataSource:self];
        [contentView setDelegate:self];
        [self addSubview:contentView];
    }
    return self;
}
-(void)dealloc{
    [source release];
    [contentView release];
    [super dealloc];
}
-(NSInteger)numberOfCellInFlipView:(UIFlipView *)flipView{
    return source.count;
}
-(UIFlipViewCell *)flipView:(UIFlipView *)flipView cellAtIndex:(NSInteger)index{
    static NSString *simpleFlipIdentifier = @"aboutFlipIdentifier";
    ProductColorsCell *cell = (ProductColorsCell*)[flipView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
    if (cell == nil){
        cell = [[[ProductColorsCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
    }
    [cell.imageView setImage:[UIImage imageWithDocument:[[source objectAtIndex:index] objectForKey:@"photo"]]];
    [cell.textView setText:[[source objectAtIndex:index] objectForKey:@"name"]];
    return cell;
}
-(CGFloat)flipView:(UIFlipView *)flipView sizeAtIndex:(NSInteger)index{
    return 220;
}
@end
//............................................................
@interface ProductOverViewCell : UIFlipViewCell{
    UITextView *textView;
    UIImageView *imageView;
}
@property(nonatomic,readonly) UIImageView *imageView;
@property(nonatomic,readonly) UITextView *textView;
@end

@implementation ProductOverViewCell
@synthesize imageView;
@synthesize textView;
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        textView = [[GUI textViewWithFrame:CGRectZero parent:self text:nil font:[UIFont systemFontOfSize:12] color:[UIColor colorWithHex:0x737272ff] align:0] retain];
        imageView = [[GUI imageWithFrame:CGRectZero parent:self] retain];
    }
    return self;
}
-(void)dealloc{
    [textView release];
    [imageView release];
    [super dealloc];
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if (self.selected) {
        [textView setFrame:CGRectMake(340, 35, self.bounds.size.width-375, self.bounds.size.height-70)];
        [imageView setFrame:CGRectMake(35, 35, 270, self.bounds.size.height-70)];
    }else {
        [textView setFrame:CGRectMake(35, 35, self.bounds.size.width-375, self.bounds.size.height-70)];
        [imageView setFrame:CGRectMake(self.bounds.size.width-305, 35, 270, self.bounds.size.height-70)];
    }
}
@end

//.........................
@interface ProductOverView : UIView<UIFlipViewDelegate,UIFlipViewDataSource>{
    UIFlipView *contentView;
}
@property(nonatomic,retain) NSArray *source;
@end;

@implementation ProductOverView
@synthesize source;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithHex:0xffffffdd]];
        contentView = [[UIFlipView alloc] initWithFrame:self.bounds];
        [contentView setOrientation:UIFlipOrientationPortrait];
        [contentView setSeparatorColor:[UIColor lightGrayColor]];
        [contentView setDataSource:self];
        [contentView setDelegate:self];
        [self addSubview:contentView];
    }
    return self;
}
-(void)dealloc{
    [contentView release];
    [super dealloc];
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [contentView setFrame:self.bounds];
}
-(NSInteger)numberOfCellInFlipView:(UIFlipView *)flipView{
    return source.count;
}
-(UIFlipViewCell *)flipView:(UIFlipView *)flipView cellAtIndex:(NSInteger)index{
    static NSString *simpleFlipIdentifier = @"aboutFlipIdentifier";
    ProductOverViewCell *cell = (ProductOverViewCell*)[flipView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
    if (cell == nil){
        cell = [[[ProductOverViewCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
    }
    [cell.imageView setImage:[UIImage imageWithDocument:[[source objectAtIndex:index] objectForKey:@"photo"]]];
    [cell.textView setText:[[source objectAtIndex:index] objectForKey:@"content"]];
    [cell setSelected:index%2];
    return cell;
}
-(CGFloat)flipView:(UIFlipView *)flipView sizeAtIndex:(NSInteger)index{
    return 231;
}
@end;

//............................................................
@interface ProductViewController (){
    UIView *popView;
    UIView *rightView;
    UIFlipView *bookView;
    //
    int page;
    UILabel *nameView;
    UILabel *modelView;
    UITextView *sizeView;
    UITextView *descriptionView;
}
@end

@implementation ProductViewController
@synthesize currentIndex;
@synthesize source;
@dynamic style;

- (void)viewDidLoad
{
    [super viewDidLoad];
	//
    page = -1;
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
    
    bookView = [[UIFlipView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [bookView setPagingEnabled:YES];
    [bookView setDataSource:self];
    [bookView setDelegate:self];
    [self.view addSubview:bookView];
    //798
    [self setStyle:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    //
    [source release],source=nil;
    [popView release],popView=nil;
    [bookView release],bookView=nil;
}

-(void)dealloc{
    [popView release];
    [bookView release];
    [source release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)viewDidAppear:(BOOL)animated{
    [NavigateView shareInstanceInView:self.view];
    //
    if ([GUIExt extendsView]) {
        [GUIExt extendsView].animationImages=[Access ExtendsImages];
    }
}

-(void)setStyle:(int)style{
    if (rightView && rightView.superview) {
        [rightView removeFromSuperview];
    }
    modelView = nil;
    nameView = nil;
    descriptionView = nil;
    sizeView = nil;
    if (style==0) {
        rightView = [GUI viewWithFrame:CGRectMake(965, 74, 226, 694) parent:self.view];
        [GUI imageWithFrame:CGRectMake(59, 0, 226, 694) parent:rightView source:@"source/product_rigBase.png"];
        [GUI buttonWithFrame:CGRectMake(0, 34, 27, 28) parent:rightView normal:@"source/btn_open.png" target:self event:@selector(openTouch:)];
        [GUI buttonWithFrame:CGRectMake(96, 625, 45, 49) parent:rightView normal:@"source/product_icon_room.png" target:self event:@selector(roomTouch:)];
        [GUI buttonWithFrame:CGRectMake(210, 626, 38, 50) parent:rightView normal:@"source/product_icon_fav.png" target:self event:@selector(favTouch:)];
        
        [GUIExt LeftAttributeWithFrame:CGRectMake(59, 352, 226, 79) parent:rightView title:@"OVERVIEW" subTitle:@"产品概述" target:self event:@selector(overviewTouch:)];
        [GUIExt LeftAttributeWithFrame:CGRectMake(59, 432, 226, 79) parent:rightView title:@"COLORS" subTitle:@"颜色选择" target:self event:@selector(colorTouch:)];
        [GUIExt LeftAttributeWithFrame:CGRectMake(59, 512, 226, 79) parent:rightView title:@"PHOTO GALLERY" subTitle:@"产品相册" target:self event:@selector(photoTouch:)];
        
        modelView=[GUI lableWithFrame:CGRectMake(83, 25, 178, 42) parent:rightView text:nil font:[UIFont fontWithName:@"HelveticaNeueLTStd-ThCn" size:33] color:[UIColor whiteColor] align:0];
        nameView=[GUI lableWithFrame:CGRectMake(83, 67, 178, 16) parent:rightView text:nil font:[UIFont systemFontOfSize:16] color:[UIColor whiteColor] align:0];
        descriptionView=[GUI textViewWithFrame:CGRectMake(79, 119, 187, 125) parent:rightView text:nil font:[UIFont systemFontOfSize:12] color:[UIColor colorWithHex:0x52261dff] align:0];
        sizeView=[GUI textViewWithFrame:CGRectMake(79, 271, 181, 68) parent:rightView text:nil font:[UIFont systemFontOfSize:12] color:[UIColor colorWithHex:0x52261dff] align:0];
        //线
        [GUI imageWithFrame:CGRectMake(172, 626, 1, 54) parent:rightView source:@"source/vline.png"];
        [GUI imageWithFrame:CGRectMake(59, 104, 226, 1) parent:rightView source:@"source/rline.png"];
        [GUI imageWithFrame:CGRectMake(59, 259, 226, 1) parent:rightView source:@"source/rline.png"];
        [GUI imageWithFrame:CGRectMake(59, 352, 226, 1) parent:rightView source:@"source/rline.png"];
        [GUI imageWithFrame:CGRectMake(59, 432, 226, 1) parent:rightView source:@"source/line.png"];
        [GUI imageWithFrame:CGRectMake(59, 512, 226, 1) parent:rightView source:@"source/line.png"];
        [GUI imageWithFrame:CGRectMake(59, 591, 226, 1) parent:rightView source:@"source/line.png"];
    }else {
        rightView = [GUI viewWithFrame:CGRectMake(965, 74, 226, 694) parent:self.view];
        [GUI imageWithFrame:CGRectMake(59, 0, 226, 694) parent:rightView source:@"source/product_rigBase.png"];
        [GUI buttonWithFrame:CGRectMake(0, 34, 27, 28) parent:rightView normal:@"source/btn_open.png" target:self event:@selector(openTouch:)];
        [GUI buttonWithFrame:CGRectMake(153, 626, 38, 50) parent:rightView normal:@"source/product_icon_fav.png" target:self event:@selector(favTouch:)];
        
        modelView=[GUI lableWithFrame:CGRectMake(83, 25, 178, 42) parent:rightView text:nil font:[UIFont fontWithName:@"HelveticaNeueLTStd-ThCn" size:33] color:[UIColor whiteColor] align:0];
        nameView=[GUI lableWithFrame:CGRectMake(83, 67, 178, 16) parent:rightView text:nil font:[UIFont systemFontOfSize:16] color:[UIColor whiteColor] align:0];
        descriptionView=[GUI textViewWithFrame:CGRectMake(79, 119, 187, 458) parent:rightView text:nil font:[UIFont systemFontOfSize:12] color:[UIColor colorWithHex:0x52261dff] align:0];
        //线
        [GUI imageWithFrame:CGRectMake(59, 104, 226, 1) parent:rightView source:@"source/rline.png"];
        [GUI imageWithFrame:CGRectMake(59, 591, 226, 1) parent:rightView source:@"source/line.png"];
    }
}
//
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self removePopView];
    [self resetButton:nil];
}
-(void)removePopView{
    if (popView) {
        [bookView setUserInteractionEnabled:YES];
        if (popView.superview) {
            [self.view.layer addAnimation:[CATransition animation] forKey:nil];
            [popView removeFromSuperview];
        }
        [popView release],popView=nil;
    }
}
-(void)resetButton:(UIControl*)button{
    for (UIView *view in rightView.subviews) {
        if ([view isKindOfClass:[LeftAttributeButton class]] && button!=view) {
            [(UIControl*)view setSelected:NO];
        }
    }
}
-(void)photoTouch:(UIControl *)sender{
    [self removePopView];
    sender.selected=!sender.selected;
    if (sender.selected) {
        [self resetButton:sender];
        
        NSMutableDictionary *curPro = [source objectAtIndex:page];
        id tmp = [curPro objectForKey:@"photoGallery"];
        if (nil == tmp) {
            tmp = [Access getProductPhotoGalleryWithId:[curPro objectForKey:@"id"]];
            [curPro setValue:tmp forKey:@"photoGallery"];
        }
        
        popView = [[ProductPhoto alloc] initWithFrame:CGRectMake(0, 74, 799, 694)];
        [(ProductPhoto*)popView setSource:tmp];
        [self.view addSubview:popView];
        [bookView setUserInteractionEnabled:NO];
        [self.view.layer addAnimation:[CATransition animation] forKey:nil];
    }
}
-(void)colorTouch:(UIControl *)sender{
    [self removePopView];
    sender.selected=!sender.selected;
    if (sender.selected) {
        [self resetButton:sender];
        NSMutableDictionary *curPro = [source objectAtIndex:page];
        id tmp = [curPro objectForKey:@"colors"];
        if (nil == tmp) {
            tmp = [Access getProductColorsWithId:[curPro objectForKey:@"id"]];
            [curPro setValue:tmp forKey:@"colors"];
        }
        //
        popView = [[ProductColors alloc] initWithFrame:CGRectMake(0, 506, 799, 234)];
        [(ProductColors*)popView setSource:tmp];
        [self.view addSubview:popView];
        [bookView setUserInteractionEnabled:NO];
        [self.view.layer addAnimation:[CATransition animation] forKey:nil];
    }
}
-(void)overviewTouch:(UIControl *)sender{
    [self removePopView];
    sender.selected=!sender.selected;
    if (sender.selected) {
        [self resetButton:sender];
        NSMutableDictionary *curPro = [source objectAtIndex:page];
        id tmp = [curPro objectForKey:@"overview"];
        if (nil == tmp) {
            tmp = [Access getProductOverviewWithId:[curPro objectForKey:@"id"]];
            [curPro setValue:tmp forKey:@"overview"];
        }
        //
        popView = [[ProductOverView alloc] initWithFrame:CGRectMake(0, 74, 799, 694)];
        [(ProductOverView*)popView setSource:tmp];
        [self.view addSubview:popView];
        [bookView setUserInteractionEnabled:NO];
        [self.view.layer addAnimation:[CATransition animation] forKey:nil];
    }
}
//代理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int value = floor((bookView.contentOffset.x + bookView.frame.size.width * 0.5) / bookView.frame.size.width); 
    if (value != page){
        if (value >=0) {
            page = value;
            if (sizeView) {
                sizeView.text = [[source objectAtIndex:page] objectForKey:@"size"];
            }
            nameView.text = [[source objectAtIndex:page] objectForKey:@"name"];
            modelView.text = [[source objectAtIndex:page] objectForKey:@"model"];
            descriptionView.text = [[source objectAtIndex:page] objectForKey:@"description"];
        }
    }
}
-(CGPoint)contentOffsetInFlipView:(UIFlipView *)flipView{
    return CGPointMake(currentIndex*1024, 0);
}
-(NSInteger)numberOfCellInFlipView:(UIFlipView *)flipView{
    [self scrollViewDidScroll:flipView];
    return [source count];
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
    NSString *filePath = [[source objectAtIndex:index] objectForKey:@"bigPhoto"];
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:cell document:filePath];
    return cell;
}
//
-(void)openTouch:(UIButton*)sender{
    sender.selected = !sender.selected;
    //
    if (sender.selected) {
        [GUIExt tweenTo:739 object:rightView];
    }else {
        [self removePopView];
        [self resetButton:nil];
        [GUIExt tweenTo:965 object:rightView];
    }
}
-(void)roomTouch:(UIButton*)sender{
}
-(void)favTouch:(UIButton*)sender{
}
@end
