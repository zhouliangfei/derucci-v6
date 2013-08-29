//
//  Utils.m
//  i3
//
//  Created by macbook on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "Utils.h"
#import <sys/socket.h> 
#import <sys/sysctl.h>
#import <net/if.h>
#import <arpa/inet.h>
#import <net/if_dl.h>
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
//NSNull
@implementation NSNull (NSNullUtils)
-(double)doubleValue{
    return 0;
}
-(float)floatValue{
    return 0;
}
-(int)intValue{
    return 0;
}
-(NSInteger)integerValue{
    return 0;
}
-(long long)longLongValue{
    return 0;
}
-(BOOL)boolValue{
    return false;
}
-(NSString *)description{
    return @"";
}
@end
//NSObject
@implementation NSObject (NSObjectUtils)
-(id)JSONFragment{
    if ([NSJSONSerialization isValidJSONObject:self]){
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONReadingMutableContainers error:&error];
        if (nil==error){
            return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        }
    }
    return nil;
}
@end
//NSString
@implementation NSString (NSStringUtils)
-(id)dateFromFormatter:(NSString*)format{
    NSDateFormatter *formatter=[[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    return [formatter dateFromString:self];
}
-(id)JSONValue{
    NSData *data = [self dataUsingEncoding: NSUTF8StringEncoding];
    if (data) {
        NSError *error = nil;
        id temp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (nil==error && [NSJSONSerialization isValidJSONObject:temp]){
            return temp;
        }
    }
    return nil;
}
@end
//NSDate
@implementation NSDate (NSDateUtils)
-(id)stringFromFormatter:(NSString*)format{
    NSDateFormatter *formatter=[[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}
@end
//
@implementation Utils

+(NSString*)document{
    static NSString *UtilsDocument;
    @synchronized(self){
        if (nil == UtilsDocument){
            UtilsDocument = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] retain];
        }
    }
    return UtilsDocument;
}
+(NSString*)pathForDocument:(NSString*)path
{
    return [[Utils document] stringByAppendingPathComponent:path];
}
+(NSString*)pathForResource:(NSString*)path
{
    return [[NSBundle mainBundle] pathForResource:path ofType:@""];;
}

+(NSString*)uuid {
    CFUUIDRef cfid = CFUUIDCreate(nil);
    CFStringRef cfidstring = CFUUIDCreateString(nil, cfid);    
    CFRelease(cfid);
    
    NSString *uuid = (NSString *)CFStringCreateCopy(NULL,cfidstring);    
    CFRelease(cfidstring);    
    return [uuid autorelease];
}
+(NSString*)macAddress {
    int mib[6];
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0){
        return nil;
    }
    
    size_t len;
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0){
        return nil;
    }
    
    char *buf;
    if ((buf = malloc(len)) == NULL){
        return nil;
    }
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0){
        return nil;
    }

    struct if_msghdr *ifm = (struct if_msghdr *)buf;    
    struct sockaddr_dl *sdl = (struct sockaddr_dl *)(ifm + 1);    
    unsigned char *ptr = (unsigned char *)LLADDR(sdl);    
    NSString *temp = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return temp;
}
+(NSString*)md5:(NSString *)value { 
    const char *cStr = [value UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);  
    
    int b = CC_MD5_DIGEST_LENGTH / 4;
    int e = CC_MD5_DIGEST_LENGTH * 3 / 4;
    NSMutableString *temp = [NSMutableString string];
    for(int i = b; i<e; i++){
        [temp appendFormat:@"%02x",result[i]];
    }
    return [temp lowercaseString];
}
+(NSArray*)intoSqlWithDictionary:(NSDictionary*)value{
    NSMutableArray *sql = [NSMutableArray array];
    for (id from in value){
        NSArray *list = [value objectForKey:from];
        for (id dat in list){
            NSString *params = nil;
            NSString *values = nil;
            for (id pro in dat) {
                id tmp = [dat objectForKey:pro];
                if (tmp == NULL || tmp == [NSNull null]) {
                    continue;
                }
                //属性
                if (params==nil) {
                    params = [NSString stringWithFormat:@"%@",pro];
                }else {
                    params = [params stringByAppendingFormat:@",%@",pro];
                }
                //值
                if ([tmp isKindOfClass:[NSString class]]) {
                    if ([tmp rangeOfString:@"\""].length > 0){
                        tmp = [tmp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    }
                    if (values==nil) {
                        values = [NSString stringWithFormat:@"\"%@\"",tmp];
                    }else {
                        values = [values stringByAppendingFormat:@",\"%@\"",tmp];
                    }
                }else{
                    if (values==nil) {
                        values = [NSString stringWithFormat:@"%@",tmp];
                    }else {
                        values = [values stringByAppendingFormat:@",%@",tmp];
                    }
                }
            }
            if (params && values){
                [sql addObject:[NSString stringWithFormat:@"REPLACE INTO %@ (%@) VALUES (%@)",from,params,values]];
            }
        }
    }
    return sql;
}
+(id)getURL:(NSString*)value{
    NSURL *url = [NSURL URLWithString:[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (url) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
        [request setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        //[request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        //[request setHTTPMethod:@"POST"];
        
        NSError *error = nil;
        NSURLResponse *response = nil;
        NSData *dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (nil == error && nil != response) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            if ((200 == statusCode) && (nil != dataReply)){
                NSString *source = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
                return [source autorelease];
            }

            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSHTTPURLResponse localizedStringForStatusCode:statusCode] forKey:NSLocalizedDescriptionKey];
            return [NSError errorWithDomain:self.description code:statusCode userInfo:userInfo];
        }
    }
    return nil;
}

+(id)loadNibNamed:(NSString*)nibName{
    NSArray *temp = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    return [temp lastObject];
}

+(id)loadNibNamed:(NSString*)nibName className:(NSString*)className{
    NSArray *temp = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    for (id nib in temp) {
        if ([className isEqualToString:[NSString stringWithUTF8String:object_getClassName(nib)]]) {
            return nib;
        }
    }
    return nil;
}

/*
 controller
 */
+(UIViewController*)pushViewController:(UIViewController*)viewController animated:(UITransitionStyle)animated{
    switch (animated) {
        case UITransitionStyleDissolve:
            [[Utils rootViewController] pushViewController:viewController animated:NO];
            [[Utils rootViewController].view.layer addAnimation:[CATransition animation] forKey:nil];
            break;
        case UITransitionStyleCoverVertical:
            //XXXXXXXX
            [[Utils rootViewController] pushViewController:viewController animated:NO];
            [[Utils rootViewController].view.layer addAnimation:[CATransition animation] forKey:nil];
            break;
        case UITransitionStyleCoverHorizontal:
            [[Utils rootViewController] pushViewController:viewController animated:YES];
            break;
        default:
            [[Utils rootViewController] pushViewController:viewController animated:NO];
            break;
    }
    [viewController setModalTransitionStyle:animated];
    return viewController;
}
+(UIViewController*)popViewController:(UIViewController*)viewController animated:(UITransitionStyle)animated{
    switch (animated) {
        case UITransitionStyleDissolve:
            [[Utils rootViewController] popToViewController:viewController animated:NO];
            [[Utils rootViewController].view.layer addAnimation:[CATransition animation] forKey:nil];
            break;
        case UITransitionStyleCoverVertical:
            //XXXXXXXX
            [[Utils rootViewController] popToViewController:viewController animated:NO];
            [[Utils rootViewController].view.layer addAnimation:[CATransition animation] forKey:nil];
            break;
        case UITransitionStyleCoverHorizontal:
            [[Utils rootViewController] popToViewController:viewController animated:YES];
            break;
        default:
            [[Utils rootViewController] popToViewController:viewController animated:NO];
            break;
    }
    return viewController;
}
+(UINavigationController*)rootViewController{
    static UINavigationController *UtilsRootViewController;
    @synchronized(self){
        if (nil == UtilsRootViewController){
            UtilsRootViewController = [[UINavigationController alloc] init];
            [UtilsRootViewController setNavigationBarHidden:YES];
            NSLog(@"%@",[Utils document]);
        }
    }
    return UtilsRootViewController;
}
+(UIViewController*)gotoWithName:(NSString*)name animated:(UITransitionStyle)animated{
    Class class = NSClassFromString(name);
    if (class) {
        NSArray *viewControllers = [[Utils rootViewController] viewControllers];
        for (UIViewController *oldController in viewControllers) {
            if ([oldController isKindOfClass:class]) {
                return [Utils popViewController:oldController animated:animated];
            }
        }
        //
        UIViewController *viewController = [[[class alloc] initWithNibName:nil bundle:nil] autorelease];
        return [Utils pushViewController:viewController animated:animated];
    }
    return nil;
}
+(UIViewController*)openWithName:(NSString*)name animated:(UITransitionStyle)animated{
    Class class = NSClassFromString(name);
    if (class) {
        UIViewController *viewController = [[[class alloc] initWithNibName:nil bundle:nil] autorelease];
        return [Utils pushViewController:viewController animated:animated];
    }
    return nil;
}
+(UIViewController*)back{
    NSArray *viewControllers = [[Utils rootViewController] viewControllers];
    if (viewControllers.count > 1) {
        UIViewController *curController = [viewControllers objectAtIndex:viewControllers.count-1];
        UIViewController *topController = [viewControllers objectAtIndex:viewControllers.count-2];
        return [Utils popViewController:topController animated:curController.modalTransitionStyle];
    }
    return nil;
}

/*
 audioPlayer
 */
+(AVAudioPlayer*)audioWithPath:(NSString*)path{
    static AVAudioPlayer *UtilsAudioPlayer;
    @synchronized(self){
        if (UtilsAudioPlayer && path && ![UtilsAudioPlayer.url.path isEqualToString:path]) {
            [UtilsAudioPlayer release],UtilsAudioPlayer=nil;
        }
        if (nil==UtilsAudioPlayer) {
            NSURL *url = [NSURL fileURLWithPath:path];
            if (url){
                UtilsAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
            }
        }
    }
    return UtilsAudioPlayer;
}
@end
