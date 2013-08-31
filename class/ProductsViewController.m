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
#import "UIPerspectView.h"
#import "ProductViewController.h"
#import "ProductsViewController.h"

//*************************************************************************
@interface Products2DViewCell : UIControl{
    UIImageView *background;
}
@property(nonatomic,readonly) UILabel *titleView;
@property(nonatomic,readonly) UIImageView *imageView;
@end

@implementation Products2DViewCell
@synthesize titleView,imageView;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [[UIImage imageWithResource:@"source/product_cellBase.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        background = [[UIImageView alloc] initWithImage:image];
        [self addSubview:background];
        //
        imageView = [[GUI imageWithFrame:CGRectZero parent:self] retain];
        titleView = [[GUI lableWithFrame:CGRectZero parent:self text:nil font:[UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:22] color:[UIColor grayColor] align:1] retain];
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
    [imageView setFrame:CGRectMake(10, 10, size.width-20, size.height-65)];
    [titleView setFrame:CGRectMake(10,  size.height-55, size.width-20, 55)];
}
@end

//*************************************************************************
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
        UIImage *image = [[UIImage imageWithResource:@"source/product_cellBase.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        background = [[UIImageView alloc] initWithImage:image];
        [self addSubview:background];
        //
        imageView = [[GUI imageWithFrame:CGRectZero parent:self] retain];
        titleView = [[GUI lableWithFrame:CGRectZero parent:self text:nil font:[UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:22] color:[UIColor grayColor] align:1] retain];
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
    [imageView setFrame:CGRectMake(10, 10, size.width-20, size.height-65)];
    [titleView setFrame:CGRectMake(10,  size.height-55, size.width-20, 55)];
}
@end

//*************************************************************************
@interface ProductsCell : UIFlipViewCell<UIPerspectViewDelegate,UIPerspectViewDataSource,UIFlipViewDelegate,UIFlipViewDataSource>{
    UIPerspectView *book3dView;
    UIFlipView *book2dView;
}
@property(nonatomic,assign) NSArray *source;
@property(nonatomic,assign) int style;
@property(nonatomic,assign) id target;
@end

@implementation ProductsCell
@synthesize target=_target;
@synthesize source=_source;
@synthesize style=_style;

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        _style = -1;
        [self setStyle:0];
    }
    return self;
}
-(void)dealloc{
    [book3dView release];
    [book2dView release];
    [super dealloc];
}
-(void)setStyle:(int)style{
    if (_style != style) {
        _style = style;
        [self.layer addAnimation:[CATransition animation] forKey:nil];
        //
        if (_style==0) {
            if (book3dView) {
                [book3dView removeFromSuperview];
                [book3dView release],book3dView=nil;
            }
            book2dView = [[UIFlipView alloc] initWithFrame:CGRectMake(21, 78, 982, 685)];
            [book2dView setOrientation:UIFlipOrientationPortrait];
            [book2dView setClearance:5];
            [book2dView setDataSource:self];
            [book2dView setDelegate:self];
            [self addSubview:book2dView];
        }else {
            if (book2dView) {
                [book2dView removeFromSuperview];
                [book2dView release],book2dView=nil;
            }
            book3dView = [[UIPerspectView alloc] initWithFrame:CGRectMake(0, 75, 1024, 693)];
            [book3dView setPagingEnabled:YES];
            [book3dView setMarginTop:80];
            [book3dView setDataSource:self];
            [book3dView setDelegate:self];
            [self addSubview:book3dView];
        }
    }
}
-(void)setSource:(NSArray *)source{
    id temp = [source retain];
    [_source release],_source=nil;
    _source = temp;
    //
    if (book2dView) {
        [book2dView reloadData];
    }
    if (book3dView) {
        [book3dView reloadData];
    }
}
//
-(NSInteger)numberOfCellInFlipView:(UIFlipView *)flipView{
    return ceilf((float)[_source count]/3.0);
}
-(UIFlipViewCell *)flipView:(UIFlipView *)flipView cellAtIndex:(NSInteger)index{
    static NSString *simpleFlipIdentifier = @"aboutFlipIdentifier";
    UIFlipViewCell *cell = [flipView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
    if (cell == nil){
        cell = [[[UIFlipViewCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
    }
    
    for (UIView *view in cell.subviews) {
        [view removeFromSuperview];
    }
    int b = index * 3;
    int e = MIN(b + 3,_source.count);
    for (int i=b; i<e; i++) {
        NSDictionary *data = [_source objectAtIndex:i];
        Products2DViewCell *temp = [[Products2DViewCell alloc] initWithFrame:CGRectMake(329*(i-b), 0, 324, 225)];
        [temp addTarget:self action:@selector(productTouch:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:temp];
        [temp setTag:i+1];
        [temp release];
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            UIImage *imgs = [UIImage imageWithDocument:[data objectForKey:@"photo"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [temp.titleView setText:[data objectForKey:@"model"]];
                [temp.imageView setImage:imgs];
            });
        });
    }
    
    return cell;
}
-(CGFloat)flipView:(UIFlipView *)flipView sizeAtIndex:(NSInteger)index{
    return 225;
}

//PerspectView
-(CGSize)perspectView:(UIPerspectView *)perspectView sizeAtIndex:(NSInteger)index{
    return CGSizeMake(858, 596);
}
-(NSInteger)numberOfCellInPerspectView:(UIPerspectView *)perspectView{
    return [_source count];
}
-(UIPerspectViewCell *)perspectView:(UIPerspectView *)perspectView cellAtIndex:(NSInteger)index{
    static NSString *simpleFlipIdentifier = @"aboutFlipIdentifier";
    Products3DViewCell *cell = (Products3DViewCell*)[perspectView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
    if (cell == nil){
        cell = [[[Products3DViewCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
        [cell setAngle:-25];
        [cell addTarget:self action:@selector(productTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    NSDictionary *data = [_source objectAtIndex:index];
    [cell.imageView setImage:[UIImage imageWithDocument:[data objectForKey:@"photo"]]];
    [cell.titleView setText:[data objectForKey:@"model"]];
    [cell setTag:index+1];
    return cell;
}
//
-(void)productTouch:(id)sender{
    if (_target) {
        [_target performSelector:@selector(productTouch:) withObject:sender];
    }
}
@end

//*************************************************************************
@interface ProductsTipsCell : UIControl{
    UIView *background;
}
@property(nonatomic,readonly) UILabel *titleView;
@end

@implementation ProductsTipsCell
@synthesize titleView;
+(id)cellWithFrame:(CGRect)frame parent:(UIView*)parent title:(NSString*)title tag:(int)tag{
    ProductsTipsCell *temp = [[ProductsTipsCell alloc] initWithFrame:frame];
    [temp.titleView setText:title];
    [temp setTag:tag];
    [parent addSubview:temp];
    return [temp autorelease];
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        background = [[GUI viewWithFrame:CGRectZero parent:self] retain];
        titleView = [[GUI lableWithFrame:CGRectZero parent:self text:nil font:[UIFont boldSystemFontOfSize:12] color:[UIColor whiteColor] align:1] retain];
        [self sortChildren:frame.size];
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

//*************************************************************************
@interface ProductsTopCell : UIButton
@end
@implementation ProductsTopCell
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageWithResource:@"source/product_btnActBg.png"] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
        [self setContentEdgeInsets:UIEdgeInsetsMake(24, 0, 0, 0)];
    }
    return self;
}
+(id)cellWithWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal active:(NSString*)active normalTitle:(NSString*)normalTitle activeTitle:(NSString*)activeTitle target:(id)target event:(SEL)event{
    ProductsTopCell *temp = [[ProductsTopCell alloc] initWithFrame:frame];
    if (active) {
        [temp setImage:[UIImage imageWithResource:active] forState:UIControlStateSelected];
    }
    if (activeTitle) {
        [temp setTitle:activeTitle forState:UIControlStateSelected];
    }
    if (target && event) {
        [temp addTarget:target action:event forControlEvents:UIControlEventTouchUpInside];
    }
    [temp setImage:[UIImage imageWithResource:normal] forState:UIControlStateNormal];
    [temp setTitle:normalTitle forState:UIControlStateNormal];
    [parent addSubview:temp];
    return [temp autorelease];
}
+(id)cellWithWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal title:(NSString*)title target:(id)target event:(SEL)event{
    return [ProductsTopCell cellWithWithFrame:frame parent:parent normal:normal active:nil normalTitle:title activeTitle:nil target:target event:event];
}
@end

//*****************
@interface ProductsTopView : UIView
@property(nonatomic,readonly) UIButton *switchView;
@property(nonatomic,readonly) UIButton *seachView;
@property(nonatomic,readonly) UIButton *eachView;
@end

@implementation ProductsTopView
@synthesize switchView;
@synthesize seachView;
@synthesize eachView;

-(id)initWithTarget:(id)target{
    self=[super initWithFrame:CGRectMake(193, 0, 723, 75)];
    if (self) {
        [GUI imageWithFrame:CGRectMake(456, 24, 267, 29) parent:self source:@"source/product_line.png"];
        //
        switchView=[ProductsTopCell cellWithWithFrame:CGRectMake(457, 1, 88, 52) parent:self normal:@"source/product_icon2.png" active:@"source/product_icon1.png" 
                                          normalTitle:@"常规排列" activeTitle:@"动感排列" target:target event:@selector(switchTouch:)];
        seachView=[ProductsTopCell cellWithWithFrame:CGRectMake(545, 1, 88, 52) parent:self normal:@"source/product_icon4.png" title:@"产品搜索" target:target event:@selector(seachTouch:)];
        eachView=[ProductsTopCell cellWithWithFrame:CGRectMake(634, 1, 88, 52) parent:self normal:@"source/product_icon3.png" title:@"产品筛选" target:target event:@selector(eachTouch:)];
    }
    return self;
}
@end

//*************************************************************************
@interface ProductsSeachView : UIView{
    id targetObj;
    UITextField *inputView;
}
@property(nonatomic,readonly) id value;
@property(nonatomic,retain) id openner;
-(void)reset;
@end

@implementation ProductsSeachView
@synthesize openner;
@dynamic value;
-(id)initWithTarget:(id)target{
    self = [super initWithFrame:CGRectMake(0, 0, 1024, 768)];
    if (self) {
        targetObj = [target retain];
        
        [GUI imageWithFrame:CGRectMake(649, 53, 267, 45) parent:self source:@"source/product_seaBase.png"];
        inputView = [GUI textFieldWithFrame:CGRectMake(655, 59, 222, 33) parent:self text:nil font:[UIFont systemFontOfSize:14] color:[UIColor whiteColor] align:0 panding:5];
        [inputView setBackground:[UIImage imageWithResource:@"source/product_inBase.png"]];
        [GUI buttonWithFrame:CGRectMake(876, 59, 34, 33) parent:self normal:@"source/product_icon5.png" target:self event:@selector(cellTouch:)];
    }
    return self;
}
-(void)dealloc{
    [openner release];
    [super dealloc];
}
-(id)value{
    return inputView.text;
}
-(void)reset{
    inputView.text=@"";
}
-(void)cellTouch:(UIButton*)sender{
    if (targetObj) {
        [targetObj performSelector:@selector(seachTouch:) withObject:self];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self cellTouch:nil];
}
@end

//*************************************************************************
@interface ProductsEachCell : UIButton
@end
@implementation ProductsEachCell
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setImage:[UIImage imageWithResource:@"source/product_selAct.png"] forState:UIControlStateSelected];
        [self setImage:[UIImage imageWithResource:@"source/product_selNor.png"] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithHex:0xf39e7eff] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];
    }
    return self;
}
+(id)cellWithFrame:(CGRect)frame parent:(UIView*)parent title:(NSString*)title tag:(int)tag target:(id)target event:(SEL)event{
    ProductsEachCell *temp = [[ProductsEachCell alloc] initWithFrame:frame];
    [temp setTitle:title forState:UIControlStateNormal];
    [temp setSelected:YES];
    [temp setTag:tag];
    [parent addSubview:temp];
    if (target && event) {
        [temp addTarget:target action:event forControlEvents:UIControlEventTouchUpInside];
    }
    return [temp autorelease];
}
@end

//*************
@interface ProductsEachView : UIView{
    id targetObj;
}
@property(nonatomic,readonly) id value;
@property(nonatomic,retain) id openner;
-(void)reset;
@end

@implementation ProductsEachView
@synthesize openner;
@dynamic value;
-(id)initWithTarget:(id)target{
    self = [super initWithFrame:CGRectMake(0, 0, 1024, 768)];
    if (self) {
        targetObj = [target retain];
        [GUI imageWithFrame:CGRectMake(738, 53, 178, 119) parent:self source:@"source/product_selBase.png"];
        //
        NSArray *types = [Access getRoomTypes];
        for (int i=0; i<types.count; i++) {
            float ty = 67 + i/2 * 35;
            float tx = 750 + i%2 * 84.0;
            id temp = [types objectAtIndex:i];
            [ProductsEachCell cellWithFrame:CGRectMake(tx, ty, 76, 21) parent:self title:[temp objectForKey:@"name"] tag:[[temp objectForKey:@"id"] intValue] target:self event:@selector(cellTouch:)];
        }
    }
    return self;
}
-(void)dealloc{
    [targetObj release];
    [openner release];
    [super dealloc];
}
-(id)value{
    NSMutableArray *val = [NSMutableArray array];
    for (ProductsEachCell *view in self.subviews) {
        if ([view isKindOfClass:[ProductsEachCell class]]) {
            if (view.selected) {
                [val addObject:[NSNumber numberWithInt:view.tag]];
            }
        }
    }
    return [val componentsJoinedByString:@","];
}
-(void)reset{
    for (ProductsEachCell*btn in self.subviews) {
        if ([btn isKindOfClass:[ProductsEachCell class]]) {
            [btn setSelected:YES];
        }
    }
}
-(void)cellTouch:(UIButton*)sender{
    sender.selected =! sender.selected;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (targetObj) {
        [targetObj performSelector:@selector(eachTouch:) withObject:self];
    }
}
@end

//*************************************************************************
@interface ProductsViewController (){
    NSMutableArray *source;
    UIFlipView *bookView;
    ProductsTopView *topView;
    ProductsEachView *productEachView;
    ProductsSeachView *productSeachView;
    //
    int currentPage;
    int switchValue;
}
@end

@implementation ProductsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    topView = [[ProductsTopView alloc] initWithTarget:self];
    [self.view addSubview:topView];
    //
    source = [[Access getProductTypesWithParent:nil] retain];
    for (int i=0;i<source.count;i++) {
        id val = [source objectAtIndex:i];
        id dat = [Access getProductsWithType:[val objectForKey:@"id"] room:nil key:nil];
        if (dat) {
            [val setValue:dat forKey:@"product"];
        }else {
            [val setValue:[NSArray array] forKey:@"product"];
        }
        [ProductsTipsCell cellWithFrame:CGRectMake(i*105+214, 22, 106, 35) parent:topView title:[val objectForKey:@"name"] tag:i+1];
    }
    
    //
    currentPage = -1;
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
    
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
    [topView release],topView=nil;
    [bookView release],bookView=nil;
}

-(void)dealloc{
    [source release];
    [topView release];
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
    [self.view addSubview:topView];
    //
    if ([GUIExt extendsView]) {
        [GUIExt extendsView].animationImages=[Access ExtendsImages];
    }
}

//
-(void)eachTouch:(UIButton*)sender{
    @synchronized(self){
        if (nil == productEachView){
            productEachView = [[ProductsEachView alloc] initWithTarget:self];
            [self.view addSubview:productEachView];
            [productEachView setHidden:YES];
            [productEachView release];
        }
    }
    //
    [self.view.layer addAnimation:[CATransition animation] forKey:nil];
    if (productEachView.hidden) {
        [productEachView setOpenner:sender];
        [productEachView.openner setSelected:YES];
        [productEachView setHidden:NO];
    }else {
        [productEachView.openner setSelected:NO];
        [productEachView setHidden:YES];
        
        //加载新数据
        id cur = [source objectAtIndex:currentPage];
        id key = productSeachView ? productSeachView.value : nil;
        id dat = [Access getProductsWithType:[cur objectForKey:@"id"] room:productEachView.value key:key];
        if (dat) {
            [cur setValue:dat forKey:@"product"];
            ProductsCell *cell = (ProductsCell*)[bookView cellForIndex:currentPage];
            [cell setSource:dat];
        }
    }
}
-(void)seachTouch:(UIButton*)sender{
    @synchronized(self){
        if (nil == productSeachView){
            productSeachView = [[ProductsSeachView alloc] initWithTarget:self];
            [self.view addSubview:productSeachView];
            [productSeachView setHidden:YES];
            [productSeachView release];
        }
    }
    //
    [self.view.layer addAnimation:[CATransition animation] forKey:nil];
    if (productSeachView.hidden){
        [productSeachView setOpenner:sender];
        [productSeachView.openner setSelected:YES];
        [productSeachView setHidden:NO];
    }else {
        [productSeachView.openner setSelected:NO];
        [productSeachView setHidden:YES];
        
        //加载新数据
        id cur = [source objectAtIndex:currentPage];
        id room = (productEachView ? productEachView.value : nil);
        id dat = [Access getProductsWithType:[cur objectForKey:@"id"] room:(currentPage==0 ? room : nil) key:productSeachView.value];
        if (dat) {
            [cur setValue:dat forKey:@"product"];
            ProductsCell *cell = (ProductsCell*)[bookView cellForIndex:currentPage];
            [cell setSource:dat];
        }
    }
}
-(void)switchTouch:(UIButton*)sender{
    sender.selected = !sender.selected;
    switchValue = sender.selected;
    
    ProductsCell *cell = (ProductsCell*)[bookView cellForIndex:currentPage];
    [cell setStyle:switchValue];
}

//FlipView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == bookView){
        int value = floor((bookView.contentOffset.x + bookView.frame.size.width * 0.5) / bookView.frame.size.width);
        if (currentPage != value) {
            currentPage = value;
            if (currentPage==0) {
                topView.eachView.alpha=1;
                topView.eachView.userInteractionEnabled=YES;
            }else {
                topView.eachView.alpha=0.5;
                topView.eachView.userInteractionEnabled=NO;
            }
            
            //
            for (ProductsTipsCell *view in topView.subviews) {
                if ([view isKindOfClass:[ProductsTipsCell class]]) {
                    [view setSelected:view.tag-1==value];
                }
            }
        }
    }
}
-(NSInteger)numberOfCellInFlipView:(UIFlipView *)flipView{
    [self scrollViewDidScroll:flipView];
    return source.count;
}
-(UIFlipViewCell *)flipView:(UIFlipView *)flipView cellAtIndex:(NSInteger)index{
    static NSString *simpleFlipIdentifier = @"aboutFlipIdentifier";
    ProductsCell *cell = (ProductsCell*)[flipView dequeueReusableCellWithIdentifier:simpleFlipIdentifier];
    if (cell == nil){
        cell = [[[ProductsCell alloc] initWithReuseIdentifier:simpleFlipIdentifier] autorelease];
    }
    [cell setTarget:self];
    [cell setSource:[[source objectAtIndex:index] objectForKey:@"product"]];
    [cell setStyle:switchValue];
    return cell;
}
//
-(void)productTouch:(UIControl*)sender{
    ProductViewController *product = (ProductViewController*)[Utils gotoWithName:@"ProductViewController" animated:UITransitionStyleCoverHorizontal];
    product.style = currentPage;
    product.currentIndex = sender.tag-1;
    product.source = [[source objectAtIndex:currentPage] objectForKey:@"product"];
}
@end
