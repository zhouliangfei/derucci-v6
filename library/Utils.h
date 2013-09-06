//
//  Utils.h
//  i3
//
//  Created by macbook on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

//NSNull
@interface NSNull (NSNullUtils)
-(double)doubleValue;
-(float)floatValue;
-(int)intValue;
-(NSInteger)integerValue;
-(long long)longLongValue;
-(BOOL)boolValue;
@end
//NSObject
@interface NSObject (NSObjectUtils)
-(id)JSONFragment;
@end
//NSString
@interface NSString (NSStringUtils)
-(id)dateFromFormatter:(NSString*)format;
-(id)JSONValue;
@end
//NSDate
@interface NSDate (NSDateUtils)
-(id)stringFromFormatter:(NSString*)format;
@end

typedef enum {
    UITransitionStyleNULL,
    UITransitionStyleDissolve,
    UITransitionStyleCoverVertical,
    UITransitionStyleCoverHorizontal
} UITransitionStyle;

//*****************************************************
@interface Utils : NSObject
+(NSString*)document;
+(NSString*)pathForDocument:(NSString*)path;
+(NSString*)pathForResource:(NSString*)path;

+(NSString*)uuid;
+(NSString*)macAddress;
+(NSString*)md5:(NSString *)value;
+(NSArray*)intoSqlWithDictionary:(NSDictionary*)value;

+(id)getURL:(NSString*)value;

+(id)loadNibNamed:(NSString*)nibName;
+(id)loadNibNamed:(NSString*)nibName className:(NSString*)className;

+(UINavigationController*)rootViewController;
+(UIViewController*)gotoWithName:(NSString*)name animated:(UITransitionStyle)animated;
+(UIViewController*)openWithName:(NSString*)name animated:(UITransitionStyle)animated;
+(UIViewController*)back;

+(AVAudioPlayer*)audioWithPath:(NSString*)path;
@end
