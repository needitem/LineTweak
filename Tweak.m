#line 1 "Tweak.x"



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <objc/runtime.h>


#define DELETED_MESSAGES_PATH @"/var/mobile/Documents/LineTweak/DeletedMessages.plist"


@interface LineTweakStorage : NSObject
+ (instancetype)sharedInstance;
- (void)saveDeletedMessage:(NSDictionary *)messageInfo;
- (NSArray *)getAllDeletedMessages;
- (void)ensureStorageDirectory;
@end

@implementation LineTweakStorage

+ (instancetype)sharedInstance {
    static LineTweakStorage *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LineTweakStorage alloc] init];
    });
    return instance;
}

- (void)ensureStorageDirectory {
    NSString *dirPath = [@"/var/mobile/Documents/LineTweak" stringByExpandingTildeInPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dirPath]) {
        [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"[LineTweak] 📁 저장 디렉토리 생성: %@", dirPath);
    }
}

- (void)saveDeletedMessage:(NSDictionary *)messageInfo {
    [self ensureStorageDirectory];

    NSMutableArray *messages = [NSMutableArray arrayWithArray:[self getAllDeletedMessages]];

    
    NSMutableDictionary *enrichedMessage = [messageInfo mutableCopy];
    enrichedMessage[@"deletedAt"] = @([[NSDate date] timeIntervalSince1970]);

    [messages addObject:enrichedMessage];

    
    if (messages.count > 1000) {
        [messages removeObjectsInRange:NSMakeRange(0, messages.count - 1000)];
    }

    NSString *path = [DELETED_MESSAGES_PATH stringByExpandingTildeInPath];
    [messages writeToFile:path atomically:YES];

    NSLog(@"[LineTweak] 💾 삭제된 메시지 저장됨: %lu개", (unsigned long)messages.count);
}

- (NSArray *)getAllDeletedMessages {
    NSString *path = [DELETED_MESSAGES_PATH stringByExpandingTildeInPath];
    NSArray *messages = [NSArray arrayWithContentsOfFile:path];
    return messages ?: @[];
}

@end


static __attribute__((constructor)) void _logosLocalCtor_7e2484d5(int __unused argc, char __unused **argv, char __unused **envp) {
    NSLog(@"[LineTweak] ✅ Line 전송취소 방지 트윅 로드됨!");
    [[LineTweakStorage sharedInstance] ensureStorageDirectory];
}


static BOOL isLoggingEnabled = YES;


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

__asm__(".linker_option \"-framework\", \"CydiaSubstrate\"");

@class NSManagedObjectContext; @class NSObject; @class UITableView; @class UIApplication; 
static void (*_logos_orig$_ungrouped$NSObject$deleteMessage$)(_LOGOS_SELF_TYPE_NORMAL NSObject* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$NSObject$deleteMessage$(_LOGOS_SELF_TYPE_NORMAL NSObject* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$NSObject$removeMessage$)(_LOGOS_SELF_TYPE_NORMAL NSObject* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$NSObject$removeMessage$(_LOGOS_SELF_TYPE_NORMAL NSObject* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$NSObject$unsendMessage$)(_LOGOS_SELF_TYPE_NORMAL NSObject* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$NSObject$unsendMessage$(_LOGOS_SELF_TYPE_NORMAL NSObject* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$UITableView$deleteRowsAtIndexPaths$withRowAnimation$)(_LOGOS_SELF_TYPE_NORMAL UITableView* _LOGOS_SELF_CONST, SEL, NSArray *, UITableViewRowAnimation); static void _logos_method$_ungrouped$UITableView$deleteRowsAtIndexPaths$withRowAnimation$(_LOGOS_SELF_TYPE_NORMAL UITableView* _LOGOS_SELF_CONST, SEL, NSArray *, UITableViewRowAnimation); static BOOL (*_logos_orig$_ungrouped$UIApplication$application$didFinishLaunchingWithOptions$)(_LOGOS_SELF_TYPE_NORMAL UIApplication* _LOGOS_SELF_CONST, SEL, UIApplication *, NSDictionary *); static BOOL _logos_method$_ungrouped$UIApplication$application$didFinishLaunchingWithOptions$(_LOGOS_SELF_TYPE_NORMAL UIApplication* _LOGOS_SELF_CONST, SEL, UIApplication *, NSDictionary *); static BOOL (*_logos_orig$_ungrouped$NSManagedObjectContext$save$)(_LOGOS_SELF_TYPE_NORMAL NSManagedObjectContext* _LOGOS_SELF_CONST, SEL, NSError **); static BOOL _logos_method$_ungrouped$NSManagedObjectContext$save$(_LOGOS_SELF_TYPE_NORMAL NSManagedObjectContext* _LOGOS_SELF_CONST, SEL, NSError **); 

#line 79 "Tweak.x"



static void _logos_method$_ungrouped$NSObject$deleteMessage$(_LOGOS_SELF_TYPE_NORMAL NSObject* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id message) {
    if (isLoggingEnabled) {
        NSLog(@"[LineTweak] 🗑️ deleteMessage 호출됨!");
        NSLog(@"[LineTweak] Class: %@", NSStringFromClass([self class]));
        NSLog(@"[LineTweak] Message: %@", message);

        
        NSDictionary *messageInfo = @{
            @"type": @"delete",
            @"class": NSStringFromClass([self class]),
            @"message": [NSString stringWithFormat:@"%@", message],
            @"timestamp": @([[NSDate date] timeIntervalSince1970])
        };
        [[LineTweakStorage sharedInstance] saveDeletedMessage:messageInfo];
    }

    
    
    NSLog(@"[LineTweak] ⛔ 메시지 삭제 차단됨!");
}

static void _logos_method$_ungrouped$NSObject$removeMessage$(_LOGOS_SELF_TYPE_NORMAL NSObject* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id message) {
    if (isLoggingEnabled) {
        NSLog(@"[LineTweak] 🗑️ removeMessage 호출됨!");
        NSLog(@"[LineTweak] Class: %@", NSStringFromClass([self class]));
        NSLog(@"[LineTweak] Message: %@", message);

        NSDictionary *messageInfo = @{
            @"type": @"remove",
            @"class": NSStringFromClass([self class]),
            @"message": [NSString stringWithFormat:@"%@", message],
            @"timestamp": @([[NSDate date] timeIntervalSince1970])
        };
        [[LineTweakStorage sharedInstance] saveDeletedMessage:messageInfo];
    }

    
    NSLog(@"[LineTweak] ⛔ 메시지 제거 차단됨!");
}

static void _logos_method$_ungrouped$NSObject$unsendMessage$(_LOGOS_SELF_TYPE_NORMAL NSObject* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id message) {
    if (isLoggingEnabled) {
        NSLog(@"[LineTweak] 📤 unsendMessage 호출됨!");
        NSLog(@"[LineTweak] Class: %@", NSStringFromClass([self class]));
        NSLog(@"[LineTweak] Message: %@", message);

        NSDictionary *messageInfo = @{
            @"type": @"unsend",
            @"class": NSStringFromClass([self class]),
            @"message": [NSString stringWithFormat:@"%@", message],
            @"timestamp": @([[NSDate date] timeIntervalSince1970])
        };
        [[LineTweakStorage sharedInstance] saveDeletedMessage:messageInfo];
    }

    
    NSLog(@"[LineTweak] ⛔ 메시지 전송취소 차단됨!");
}






static void _logos_method$_ungrouped$UITableView$deleteRowsAtIndexPaths$withRowAnimation$(_LOGOS_SELF_TYPE_NORMAL UITableView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSArray * indexPaths, UITableViewRowAnimation animation) {
    NSLog(@"[LineTweak] 📋 UITableView 행 삭제 시도: %@", indexPaths);

    
    
    
}






static BOOL _logos_method$_ungrouped$UIApplication$application$didFinishLaunchingWithOptions$(_LOGOS_SELF_TYPE_NORMAL UIApplication* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIApplication * application, NSDictionary * launchOptions) {
    BOOL result = _logos_orig$_ungrouped$UIApplication$application$didFinishLaunchingWithOptions$(self, _cmd, application, launchOptions);

    NSLog(@"[LineTweak] 🚀 Line 앱 시작!");

    
    NSArray *deletedMessages = [[LineTweakStorage sharedInstance] getAllDeletedMessages];
    NSLog(@"[LineTweak] 📦 저장된 삭제 메시지: %lu개", (unsigned long)deletedMessages.count);

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"LineTweak 활성화"
            message:[NSString stringWithFormat:@"전송취소 방지 활성화\n저장된 메시지: %lu개", (unsigned long)deletedMessages.count]
            preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *viewAction = [UIAlertAction
            actionWithTitle:@"저장된 메시지 보기"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                
                for (NSDictionary *msg in deletedMessages) {
                    NSLog(@"[LineTweak] 💬 %@", msg);
                }
            }];

        UIAlertAction *okAction = [UIAlertAction
            actionWithTitle:@"확인"
            style:UIAlertActionStyleCancel
            handler:nil];

        [alert addAction:viewAction];
        [alert addAction:okAction];

        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIViewController *rootVC = application.keyWindow.rootViewController;
        #pragma clang diagnostic pop
        if (rootVC) {
            [rootVC presentViewController:alert animated:YES completion:nil];
        }
    });

    return result;
}






static BOOL _logos_method$_ungrouped$NSManagedObjectContext$save$(_LOGOS_SELF_TYPE_NORMAL NSManagedObjectContext* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSError ** error) {
    
    NSSet *deletedObjects = [self deletedObjects];
    if (deletedObjects.count > 0) {
        NSLog(@"[LineTweak] 🗄️ CoreData 삭제 시도: %lu개 객체", (unsigned long)deletedObjects.count);

        for (NSManagedObject *obj in deletedObjects) {
            NSLog(@"[LineTweak] 삭제 대상: %@", obj);

            
            NSDictionary *messageInfo = @{
                @"type": @"coredata_delete",
                @"entity": obj.entity.name ?: @"unknown",
                @"object": [NSString stringWithFormat:@"%@", obj],
                @"timestamp": @([[NSDate date] timeIntervalSince1970])
            };
            [[LineTweakStorage sharedInstance] saveDeletedMessage:messageInfo];
        }
    }

    return _logos_orig$_ungrouped$NSManagedObjectContext$save$(self, _cmd, error);
}






















static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$NSObject = objc_getClass("NSObject"); { MSHookMessageEx(_logos_class$_ungrouped$NSObject, @selector(deleteMessage:), (IMP)&_logos_method$_ungrouped$NSObject$deleteMessage$, (IMP*)&_logos_orig$_ungrouped$NSObject$deleteMessage$);}{ MSHookMessageEx(_logos_class$_ungrouped$NSObject, @selector(removeMessage:), (IMP)&_logos_method$_ungrouped$NSObject$removeMessage$, (IMP*)&_logos_orig$_ungrouped$NSObject$removeMessage$);}{ MSHookMessageEx(_logos_class$_ungrouped$NSObject, @selector(unsendMessage:), (IMP)&_logos_method$_ungrouped$NSObject$unsendMessage$, (IMP*)&_logos_orig$_ungrouped$NSObject$unsendMessage$);}Class _logos_class$_ungrouped$UITableView = objc_getClass("UITableView"); { MSHookMessageEx(_logos_class$_ungrouped$UITableView, @selector(deleteRowsAtIndexPaths:withRowAnimation:), (IMP)&_logos_method$_ungrouped$UITableView$deleteRowsAtIndexPaths$withRowAnimation$, (IMP*)&_logos_orig$_ungrouped$UITableView$deleteRowsAtIndexPaths$withRowAnimation$);}Class _logos_class$_ungrouped$UIApplication = objc_getClass("UIApplication"); { MSHookMessageEx(_logos_class$_ungrouped$UIApplication, @selector(application:didFinishLaunchingWithOptions:), (IMP)&_logos_method$_ungrouped$UIApplication$application$didFinishLaunchingWithOptions$, (IMP*)&_logos_orig$_ungrouped$UIApplication$application$didFinishLaunchingWithOptions$);}Class _logos_class$_ungrouped$NSManagedObjectContext = objc_getClass("NSManagedObjectContext"); { MSHookMessageEx(_logos_class$_ungrouped$NSManagedObjectContext, @selector(save:), (IMP)&_logos_method$_ungrouped$NSManagedObjectContext$save$, (IMP*)&_logos_orig$_ungrouped$NSManagedObjectContext$save$);}} }
#line 254 "Tweak.x"
