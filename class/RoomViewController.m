//
//  RoomViewController.m
//  derucci-v6
//
//  Created by mac on 13-8-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "Access.h"
#import "UIFlipView.h"
#import "NavigateView.h"
#import "UISequenceView.h"
#import "RoomViewController.h"
//
#import "ProductViewController.h"

//.........................
@interface RoomColorCell : UIFlipViewCell{
    UITextView *textView;
    UIImageView *imageView;
}
@property(nonatomic,readonly) UIImageView *imageView;
@property(nonatomic,readonly) UITextView *textView;
@end

@implementation RoomColorCell
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
@interface RoomColorExtCell : RoomColorCell{
    UIButton *infoView;
}
@property(nonatomic,readonly) UIButton *infoView;
@end

@implementation RoomColorExtCell
@synthesize infoView;

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        infoView = [[GUI buttonWithFrame:CGRectZero parent:self normal:@"source/btn_more.png" target:nil event:nil] retain];
        [infoView setContentEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 0)];
        [infoView.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [infoView setTitle:@"产品详情" forState:UIControlStateNormal];
    }
    return self;
}
-(void)dealloc{
    [infoView release];
    [super dealloc];
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [infoView setFrame:CGRectMake(frame.size.width-69, frame.size.height-26, 69, 23)];
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

//............
@interface RoomColor : UIView<UIFlipViewDelegate,UIFlipViewDataSource>{
    int cellStyle;
    UIFlipView *contentView;
}
@property(nonatomic,assign) int select;
@property(nonatomic,retain) NSArray *source;
@property(nonatomic,copy) void(^clickEvent)(id target);
-(id)initWithFrame:(CGRect)frame style:(int)style;
@end

@implementation RoomColor
@synthesize source;
@synthesize select;
@synthesize clickEvent;
-(id)initWithFrame:(CGRect)frame style:(int)style{
    self = [super initWithFrame:frame];
    if (self) {
        cellStyle = style;
        //
        [self setBackgroundColor:[UIColor colorWithHex:0xffffffdd]];
        contentView = [[UIFlipView alloc] initWithFrame:self.bounds];
        [contentView setSeparatorColor:[UIColor lightGrayColor]];
        [contentView setOrientation:UIFlipOrientationPortrait];
        [contentView setDataSource:self];
        [contentView setDelegate:self];
        [self addSubview:contentView];
    }
    return self;
}
-(void)dealloc{
    [source release];
    [contentView release];
    [clickEvent release];
    [super dealloc];
}
-(NSInteger)numberOfCellInFlipView:(UIFlipView *)flipView{
    return ceilf((float)source.count/3.0);
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
    int b = index * 3;
    int e = MIN(b + 3,source.count);
    for (int i=b; i<e; i++) {
        id temp = [self.source objectAtIndex:i];
        RoomColorCell *item = nil;
        if (cellStyle==0) {
            item = [[RoomColorCell alloc] initWithReuseIdentifier:simpleFlipIdentifier];
        }else {
            item = [[RoomColorExtCell alloc] initWithReuseIdentifier:simpleFlipIdentifier];
            [((RoomColorExtCell*)item).infoView addTarget:self action:@selector(infoViewTouch:) forControlEvents:UIControlEventTouchUpInside];
        }
        [item.imageView setImage:[UIImage imageWithDocument:[temp objectForKey:@"photo"]]];
        [item addTarget:self action:@selector(cellTouch:) forControlEvents:UIControlEventTouchUpInside];
        [item setSelected:([[temp objectForKey:@"id"] intValue]==select)];
        [item.textView setText:[temp objectForKey:@"name"]];
        [item setFrame:CGRectMake(34+i%3*254, 25, 220, 180)];
        [item setTag:i+1];
        [cell addSubview:item];
        [item release];
    }
    //
    return cell;
}
-(CGFloat)flipView:(UIFlipView *)flipView sizeAtIndex:(NSInteger)index{
    return 230;
}
//
-(void)cellTouch:(RoomColorCell*)sender{
    select = [[[self.source objectAtIndex:sender.tag-1] objectForKey:@"id"] intValue];
    for (UIView *cell in contentView.subviews) {
        for (UIFlipViewCell *item in cell.subviews) {
            if ([item isKindOfClass:UIFlipViewCell.class]) {
                item.selected=(item==sender);
            }
        }
    }
    if (self.clickEvent) {
        self.clickEvent(sender);
    }
}
-(void)infoViewTouch:(UIButton*)sender{
    ProductViewController *product = (ProductViewController*)[Utils openWithName:@"ProductViewController" animated:UITransitionStyleDissolve];
    product.currentIndex = sender.superview.tag-1;
    product.source = source;
}
@end

//........................................................................
@interface RoomViewController (){
    UISequenceView *sequence;
    RoomColor *popView;
    UIView *leftView;
    //
    UILabel *titleView;
    UILabel *subTitleView;
    UIImageView *backgroundView;
    //
    int wallId;
    int floorId;
    int productId;
    int productColorId;
}
@end

@implementation RoomViewController
@synthesize source;

- (void)viewDidLoad{
    [super viewDidLoad];
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
	
    sequence = [[UISequenceView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [sequence setLayerCount:2];
    [sequence setTotalFrame:25];
    [self.view addSubview:sequence];
    
    leftView = [GUI viewWithFrame:CGRectMake(-226, 74, 274, 694) parent:self.view];
    backgroundView = [GUI imageWithFrame:CGRectMake(0, 0, 226, 694) parent:leftView];
    subTitleView = [GUI lableWithFrame:CGRectMake(23, 63, 178, 16) parent:leftView text:nil font:[UIFont systemFontOfSize:16] color:[UIColor whiteColor] align:0];
    titleView = [GUI lableWithFrame:CGRectMake(23, 27, 178, 48) parent:leftView text:nil font:[UIFont fontWithName:@"HelveticaNeueLTStd-ThCn" size:36] color:[UIColor whiteColor] align:0];
    
    [GUI buttonWithFrame:CGRectMake(246, 17, 27, 28) parent:leftView normal:@"source/btn_open.png" target:self event:@selector(openTouch:)];

    //按钮
    [GUIExt RightAttributeWithFrame:CGRectMake(0, 104, 226, 79) parent:leftView title:@"COLORS OF FLOOR" subTitle:@"地板颜色" target:self event:@selector(floorTouch:)];
    [GUIExt RightAttributeWithFrame:CGRectMake(0, 183, 226, 79) parent:leftView title:@"COLORS OF WALL" subTitle:@"墙面颜色" target:self event:@selector(wallTouch:)];
    [GUIExt RightAttributeWithFrame:CGRectMake(0, 262, 226, 79) parent:leftView title:@"MODELS OF PRODUCTS" subTitle:@"产品款式" target:self event:@selector(productTouch:)];
    [GUIExt RightAttributeWithFrame:CGRectMake(0, 341, 226, 79) parent:leftView title:@"MATERIALS" subTitle:@"选择布料" target:self event:@selector(materialTouch:)];
    //线
    [GUI imageWithFrame:CGRectMake(0, 104, 226, 1) parent:leftView source:@"source/line.png"];
    [GUI imageWithFrame:CGRectMake(0, 183, 226, 1) parent:leftView source:@"source/line.png"];
    [GUI imageWithFrame:CGRectMake(0, 262, 226, 1) parent:leftView source:@"source/line.png"];
    [GUI imageWithFrame:CGRectMake(0, 341, 226, 1) parent:leftView source:@"source/line.png"];
    [GUI imageWithFrame:CGRectMake(0, 420, 226, 1) parent:leftView source:@"source/line.png"];
    //
    [self setStyle:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setSource:nil];
    [popView release],popView=nil;
    [sequence release],sequence=nil;
}

-(void)dealloc{
    [popView release];
    [sequence release];
    [source release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
-(void)viewDidAppear:(BOOL)animated{
    [NavigateView shareInstanceInView:self.view];
    if (source) {
        [self setStyle:[[source objectForKey:@"id"] intValue]-1];
        [self updataWall];
    }
}

-(void)setStyle:(int)style{
    NSArray *title = [NSArray arrayWithObjects:
                      @"CAREER SHOW",@"职场秀",
                      @"NIGHT LIFE",@"夜生活",
                      @"HAPPY TOUR",@"享乐途",
                      @"THE NEW ARISTOCRACY",@"新贵族",
                      @"OTAKU",@"宅一族",
                      @"FASHION 90S",@"潮90",nil];
    if (style/2<title.count) {
        backgroundView.image =[UIImage imageWithResource:[NSString stringWithFormat:@"source/room_titBg%d.png",style+1]];
        subTitleView.text=[title objectAtIndex:style*2+1];
        titleView.text = [title objectAtIndex:style*2];
        titleView.adjustsFontSizeToFitWidth=YES;
    }
}
//初始化数据
-(void)updataWall{
    id wall = [source objectForKey:@"roomWalls"];
    if (nil == wall) {
        wall = [Access getWallsWithRoomId:[source objectForKey:@"id"]];
        wallId = [self getDefault:wall];
        [source setValue:wall  forKey:@"roomWalls"];
    }
    
    id floor = [Access getFloorsWithRoomId:[source objectForKey:@"id"] wallId:[NSNumber numberWithInt:wallId]];
    floorId = [self getDefault:floor];
    [source setValue:floor forKey:@"roomFloors"];
    
    [self updataFloor];
}
-(void)updataFloor{
    NSDictionary *path = [Access getPathWithRoomId:[source objectForKey:@"id"] wallId:[NSNumber numberWithInt:wallId] floorId:[NSNumber numberWithInt:floorId]];
    if (path) {
        NSString *low = [Utils pathForDocument:[[path objectForKey:@"files"] stringByAppendingPathComponent:@"s%d.png"]];
        NSString *high = [Utils pathForDocument:[[path objectForKey:@"files"] stringByAppendingPathComponent:@"%d.png"]];
        [sequence updata:0 low:low high:high];
    }
    
    [self updataProduct];
}
-(void)updataProduct{
    id pro = [source objectForKey:@"roomProducts"];
    if (nil == pro) {
        pro = [Access getProductsWithRoomId:[source objectForKey:@"id"]];
        productId = [self getDefault:pro];
        [source setValue:pro forKey:@"roomProducts"];
    }
    
    id col = [Access getColorsWithProductId:[NSNumber numberWithInt:productId]];
    productColorId = [self getDefault:col];
    [source setValue:col forKey:@"roomProColors"];
    
    [self updataProductColor];
}
-(void)updataProductColor{
    NSDictionary *proPath = [Access getPathWithProductId:[NSNumber numberWithInt:productId] colorId:[NSNumber numberWithInt:productColorId]];
    if (proPath) {
        NSString *low = [Utils pathForDocument:[[proPath objectForKey:@"files"] stringByAppendingPathComponent:@"s%d.png"]];
        NSString *high = [Utils pathForDocument:[[proPath objectForKey:@"files"] stringByAppendingPathComponent:@"%d.png"]];
        [sequence updata:1 low:low high:high];
    }
    //这里更新外屏
    if ([GUIExt extendsView]) {
        [GUIExt extendsView].animationImages=[NSArray arrayWithObject:[proPath objectForKey:@"photo"]];
    }
}

-(int)getDefault:(id)data{
    for (id val in data) {
        if ([[val objectForKey:@"isDefault"] intValue]==1) {
            return [[val objectForKey:@"id"] intValue];
        }
    }
    return 0;
}
//
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self removePopView];
    [self resetButton:nil];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (sequence.userInteractionEnabled) {
        [sequence.pointLayer setHidden:YES];
        UITouch *touch = [touches anyObject];
        CGPoint pre = [touch locationInView:self.view]; 
        CGPoint nex = [touch previousLocationInView:self.view];
        
        if (abs(pre.x-nex.x)>0 && abs(pre.x-nex.x)>abs(pre.y-nex.y)){
            if (sequence.quality == UISequenceViewQualityHigh) {
                sequence.quality = UISequenceViewQualityLow;
            } 
            if (pre.x-nex.x>0) {
                sequence.currentFrame++;
            }else {
                sequence.currentFrame--;
            }
        }
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (sequence.userInteractionEnabled){
        [sequence.pointLayer setHidden:NO];
        sequence.quality = UISequenceViewQualityHigh;
    }
}

//弹出部分
-(void)removePopView{
    if (popView) {
        [sequence setUserInteractionEnabled:YES];
        if (popView.superview) {
            [self.view.layer addAnimation:[CATransition animation] forKey:nil];
            [popView removeFromSuperview];
        }
        [popView release];
        popView=nil;
    }
}
-(void)addPopWithData:(NSArray*)data style:(int)style select:(int)select{
    if (data) {
        int total = ceilf((float)data.count/3.0);
        float th = MIN(total * 232,694);
        float ty = 74 + (694-th)/2.0;
        
        popView = [[RoomColor alloc] initWithFrame:CGRectMake(225, ty, 799, th) style:style];
        [popView setSelect:select];
        [popView setSource:data];
        [self.view addSubview:popView];
        [sequence setUserInteractionEnabled:NO];
        [self.view.layer addAnimation:[CATransition animation] forKey:nil];
    }
}
-(void)resetButton:(UIControl*)button{
    for (UIView *view in leftView.subviews) {
        if ([view isKindOfClass:[RightAttributeButton class]] && button!=view) {
            [(UIControl*)view setSelected:NO];
        }
    }
}
-(void)wallTouch:(UIControl*)sender{
    [self removePopView];
    sender.selected=!sender.selected;
    if (sender.selected) {
        [self resetButton:sender];
        [self addPopWithData:[source objectForKey:@"roomWalls"] style:0 select:wallId];
        if (popView) {
            popView.clickEvent=^(id target){
                wallId = popView.select;
                [self updataWall];
            };
        }
    }
}
-(void)floorTouch:(UIControl*)sender{
    [self removePopView];
    sender.selected=!sender.selected;
    if (sender.selected) {
        [self resetButton:sender];
        [self addPopWithData:[source objectForKey:@"roomFloors"] style:0 select:floorId];
        if (popView) {
            popView.clickEvent=^(id target){
                floorId = popView.select;
                [self updataFloor];
            };
        }
    }
}
-(void)productTouch:(UIControl*)sender{
    [self removePopView];
    sender.selected=!sender.selected;
    if (sender.selected) {
        [self resetButton:sender];
        [self addPopWithData:[source objectForKey:@"roomProducts"] style:1 select:productId];
        if (popView) {
            popView.clickEvent=^(id target){
                productId = popView.select;
                [self updataProduct];
            };
        }
    }
}
-(void)materialTouch:(UIControl*)sender{
    [self removePopView];
    sender.selected=!sender.selected;
    if (sender.selected) {
        [self resetButton:sender];
        [self addPopWithData:[source objectForKey:@"roomProColors"] style:0 select:productColorId];
        if (popView) {
            popView.clickEvent=^(id target){
                productColorId = popView.select;
                [self updataProductColor];
            };
        }
    }
}
//
-(void)openTouch:(UIButton*)sender{
    sender.selected = !sender.selected;
    //
    if (sender.selected) {
        [GUIExt tweenTo:0 object:leftView];
    }else {
        [self removePopView];
        [self resetButton:nil];
        [GUIExt tweenTo:-226 object:leftView];
    }
}
@end
