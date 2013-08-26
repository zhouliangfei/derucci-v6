//
//  ProductsViewController.m
//  derucci-v6
//
//  Created by mac on 13-8-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "Access.h"
#import "NavigateView.h"
#import "ProductViewController.h"
#import "ProductsViewController.h"

//........................................................................
@interface ProductsViewCell : UIControl{
    UIImageView *background;
}
@property(nonatomic,readonly) UILabel *titleView;
@property(nonatomic,readonly) UIImageView *imageView;
@end

@implementation ProductsViewCell
@synthesize titleView,imageView;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [[UIImage imageNamed:@"source/product_cellBase.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        background = [[UIImageView alloc] initWithImage:image];
        [self addSubview:background];
        //
        imageView = [[GUI imageWithFrame:CGRectZero parent:self] retain];
        titleView = [[GUI lableWithFrame:CGRectZero parent:self text:@"" font:[UIFont boldSystemFontOfSize:14] color:[UIColor grayColor] align:1] retain];
        [self sortChildren:self.bounds.size];
    }
    return self;
}
-(void)dealloc{
    [background release];
    [imageView release];
    [titleView release];
    [super dealloc];
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self sortChildren:frame.size];
}
-(void)sortChildren:(CGSize)size{
    [background setFrame:CGRectMake(0, 0, size.width, size.height)];
    [imageView setFrame:CGRectMake(10, 10, size.width-20, size.height-40)];
    [titleView setFrame:CGRectMake(10,  size.height-30, size.width-20, 30)];
}
@end

//........................................................................
@interface Products3DViewCell : UIPerspectViewCell{
    UIImageView *background;
}
@property(nonatomic,readonly) UILabel *titleView;
@property(nonatomic,readonly) UIImageView *imageView;
@end

@implementation Products3DViewCell
@synthesize titleView,imageView;

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        UIImage *image = [[UIImage imageNamed:@"source/product_cellBase.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        background = [[UIImageView alloc] initWithImage:image];
        [self addSubview:background];
        //
        imageView = [[GUI imageWithFrame:CGRectZero parent:self] retain];
        titleView = [[GUI lableWithFrame:CGRectZero parent:self text:@"" font:[UIFont boldSystemFontOfSize:14] color:[UIColor grayColor] align:1] retain];
        [self sortChildren:self.bounds.size];
    }
    return self;
}
-(void)dealloc{
    [background release];
    [imageView release];
    [titleView release];
    [super dealloc];
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self sortChildren:frame.size];
}
-(void)sortChildren:(CGSize)size{
    [background setFrame:CGRectMake(0, 0, size.width, size.height)];
    [imageView setFrame:CGRectMake(10, 10, size.width-20, size.height-40)];
    [titleView setFrame:CGRectMake(10,  size.height-30, size.width-20, 30)];
}
@end

//........................................................................
@interface ProductsTipsCell : UIControl{
    UIView *background;
}
@property(nonatomic,readonly) UILabel *titleView;
@end

@implementation ProductsTipsCell
@synthesize titleView;
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        background = [[GUI viewWithFrame:CGRectZero parent:self] retain];
        titleView = [[GUI lableWithFrame:CGRectZero parent:self text:@"" font:[UIFont boldSystemFontOfSize:12] color:[UIColor whiteColor] align:1] retain];
        [self sortChildren:self.bounds.size];
        [self setSelected:NO];
    }
    return self;
}
-(void)dealloc{
    [background release];
    [titleView release];
    [super dealloc];
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        [background setBackgroundColor:[UIColor whiteColor]];
    }else {
        [background setBackgroundColor:[UIColor colorWithHex:0xffffff88]];
    }
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self sortChildren:frame.size];
}
-(void)sortChildren:(CGSize)size{
    [titleView setFrame:CGRectMake(0, 0, size.width, size.height-3)];
    [background setFrame:CGRectMake(0, size.height-3, size.width, 3)];
}
@end

//........................................................................
@interface ProductsViewController (){
    NSMutableArray *source;
    UIFlipView *bookView;
    UIView *typeView;
    //
    int currentPage;
    UIButton *switchView;
    ProductsTipsCell *tipsA;
    ProductsTipsCell *tipsB;
}
@end

@implementation ProductsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    typeView = [GUI viewWithFrame:CGRectMake(407, 22, 211, 35) parent:self.view];
    //
    source = [[NSMutableArray array] retain];
    NSArray *types = [Access getProductTypesWithParent:nil];
    for (int i=0;i<types.count;i++) {
        id val = [types objectAtIndex:i];
        id dat = [Access getProductsWithType:[val objectForKey:@"id"]];
        if (dat) {
            [source addObject:dat];
            //
            ProductsTipsCell *tips = [[ProductsTipsCell alloc] initWithFrame:CGRectMake(i*105, 0, 106, 35)];
            [tips.titleView setText:[val objectForKey:@"name"]];
            [tips setTag:i+1];
            [typeView addSubview:tips];
            [tips release];
        }
    }
    
    //
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
    
    switchView = [GUI buttonWithFrame:CGRectMake(866, 30, 71, 17) parent:self.view];
    [switchView addTarget:self action:@selector(switchTouch:) forControlEvents:UIControlEventTouchUpInside];
    [switchView setImage:[UIImage imageNamed:@"source/product_icon_3d.png"] forState:UIControlStateSelected];
    [switchView setImage:[UIImage imageNamed:@"source/product_icon_2d.png"] forState:UIControlStateNormal];
    [switchView.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [switchView setTitle:@"动感排列" forState:UIControlStateSelected];
    [switchView setTitle:@"常规排列" forState:UIControlStateNormal];
    
    //cellBase
    currentPage = -1;
    bookView = [[UIFlipView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [bookView setPagingEnabled:YES];
    [bookView setDataSource:self];
    [bookView setDelegate:self];
    [self.view addSubview:bookView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [source release],source=nil;
    [bookView release],bookView=nil;
}

-(void)dealloc{
    [source release];
    [bookView release];
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
    [self.view addSubview:switchView];
    [self.view addSubview:typeView];
}

//样式
-(void)switchTouch:(UIButton*)sender{
    sender.selected = !sender.selected;
    
    UIFlipViewCell *cell = [bookView cellForIndex:currentPage];
    [self makePageWithParent:cell];
}
-(void)makePageWithParent:(UIView*)cell{
    for (UIView *view in cell.subviews) {
        [view removeFromSuperview];
    }
    if (switchView.selected) {
        UIPerspectView *book3dView = [[UIPerspectView alloc] initWithFrame:CGRectMake(0, 75, 1024, 693)];
        [book3dView setPagingEnabled:YES];
        [book3dView setMarginTop:80];
        [book3dView setDataSource:self];
        [book3dView setDelegate:self];
        [cell addSubview:book3dView];
        [book3dView release];
    }else {
        UIFlipView *book2dView = [[UIFlipView alloc] initWithFrame:CGRectMake(21, 78, 982, 685)];
        [book2dView setOrientation:UIFlipOrientationPortrait];
        [book2dView setClearance:5];
        [book2dView setDataSource:self];
        [book2dView setDelegate:self];
        [cell addSubview:book2dView];
        [book2dView release];
    }
    [self.view.layer addAnimation:[CATransition animation] forKey:nil];
}
//FlipView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == bookView){
        int value = floor((bookView.contentOffset.x + bookView.frame.size.width * 0.5) / bookView.frame.size.width);
        if (currentPage != value) {
            currentPage = value;
            for (ProductsTipsCell *view in typeView.subviews) {
                [view setSelected:view.tag-1==value];
            }
        }
    }
}
-(NSInteger)numberOfCellInFlipView:(UIFlipView *)flipView{
    if (flipView==bookView) {
        [self scrollViewDidScroll:flipView];
        return source.count;
    }
    NSArray *data = [source objectAtIndex:flipView.superview.tag-1];
    return ceilf((float)[data count]/3.0);
}
-(UIFlipViewCell *)flipView:(UIFlipView *)flipView cellAtIndex:(NSInteger)index{
    static NSString *simpleFlipIdentifier = @"aboutFlipIdentifier";
    UIFlipViewCell *cell = [flipView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
    if (cell == nil){
        cell = [[[UIFlipViewCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
    }

    if (flipView==bookView) {
        [cell setTag:index+1];
        [self makePageWithParent:cell];
    }else {
        for (UIView *view in cell.subviews) {
            [view removeFromSuperview];
        }
        NSArray *data = [source objectAtIndex:flipView.superview.tag-1];
        int b = index * 3;
        int e = MIN(b + 3,data.count);
        for (int i=b; i<e; i++) {
            NSDictionary *data = [[source objectAtIndex:flipView.superview.tag-1] objectAtIndex:i];
            NSString *filePath = [data objectForKey:@"photo"];
            
            ProductsViewCell *temp = [[ProductsViewCell alloc] initWithFrame:CGRectMake(329*(i-b), 0, 324, 225)];
            [temp addTarget:self action:@selector(productTouch:) forControlEvents:UIControlEventTouchUpInside];
            [temp.imageView setImage:[UIImage imageWithDocument:filePath]];
            [temp.titleView setText:[data objectForKey:@"name"]];
            [temp setTag:i+1];
            [cell addSubview:temp];
            [temp release];
        }
    }
    return cell;
}
-(CGFloat)flipView:(UIFlipView *)flipView sizeAtIndex:(NSInteger)index{
    if (flipView==bookView) {
        return 1024;
    }
    return 225;
}

//PerspectView
-(CGSize)perspectView:(UIPerspectView *)perspectView sizeAtIndex:(NSInteger)index{
    return CGSizeMake(858, 596);
}
-(NSInteger)numberOfCellInPerspectView:(UIPerspectView *)perspectView{
    NSArray *data = [source objectAtIndex:perspectView.superview.tag-1];
    return [data count];
}
-(UIPerspectViewCell *)perspectView:(UIPerspectView *)perspectView cellAtIndex:(NSInteger)index{
    static NSString *simpleFlipIdentifier = @"aboutFlipIdentifier";
    Products3DViewCell *cell = (Products3DViewCell*)[perspectView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
    if (cell == nil){
        cell = [[[Products3DViewCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
        [cell setAngle:-25];
        [cell addTarget:self action:@selector(productTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    NSDictionary *data = [[source objectAtIndex:perspectView.superview.tag-1] objectAtIndex:index];
    NSString *filePath = [data objectForKey:@"photo"];
    [cell.imageView setImage:[UIImage imageWithDocument:filePath]];
    [cell.titleView setText:[data objectForKey:@"name"]];
    [cell setTag:index+1];
    return cell;
}

-(void)productTouch:(UIControl*)sender{
    ProductViewController *product = (ProductViewController*)[Utils gotoWithName:@"ProductViewController" animated:UITransitionStyleCoverHorizontal];
    product.currentIndex = sender.tag-1;
    product.source = [source objectAtIndex:currentPage];
}
@end
