// LineTweak - Line 메신저 전송취소 메시지 보존
// 기능: 상대방이 전송취소한 메시지를 로컬에 저장하여 계속 볼 수 있게 함
// 미디어(사진/동영상) 포함

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>

// 삭제된 메시지 저장 경로
#define DELETED_MESSAGES_PATH @"/var/mobile/Documents/LineTweak/DeletedMessages.plist"
#define MEDIA_STORAGE_PATH @"/var/mobile/Documents/LineTweak/Media"
#define PREFS_PATH @"/var/mobile/Library/Preferences/com.taeho.linetweak.plist"

// 설정값 캐시
static BOOL tweakEnabled = YES;
static NSInteger maxMessages = 1000;
static BOOL debugLog = YES;
static BOOL saveMedia = YES;
static BOOL compressMedia = YES;

// 설정 로드 함수
static void loadPreferences() {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];

    tweakEnabled = prefs[@"enabled"] ? [prefs[@"enabled"] boolValue] : YES;
    maxMessages = prefs[@"maxMessages"] ? [prefs[@"maxMessages"] integerValue] : 1000;
    debugLog = prefs[@"debugLog"] ? [prefs[@"debugLog"] boolValue] : YES;
    saveMedia = prefs[@"saveMedia"] ? [prefs[@"saveMedia"] boolValue] : YES;
    compressMedia = prefs[@"compressMedia"] ? [prefs[@"compressMedia"] boolValue] : YES;

    if (debugLog) {
        NSLog(@"[LineTweak] 설정 로드: enabled=%d, maxMessages=%ld, debugLog=%d, saveMedia=%d, compress=%d",
              tweakEnabled, (long)maxMessages, debugLog, saveMedia, compressMedia);
    }
}

// 메시지 저장 헬퍼 클래스
@interface LineTweakStorage : NSObject
+ (instancetype)sharedInstance;
- (void)saveDeletedMessage:(NSDictionary *)messageInfo;
- (NSArray *)getAllDeletedMessages;
- (void)ensureStorageDirectory;
- (NSString *)saveImage:(UIImage *)image withPrefix:(NSString *)prefix;
- (NSString *)saveVideoFromURL:(NSURL *)url withPrefix:(NSString *)prefix;
- (NSString *)saveDataFromURL:(NSURL *)url withPrefix:(NSString *)prefix;
- (NSArray *)extractMediaFromObject:(id)object;
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
    NSFileManager *fm = [NSFileManager defaultManager];

    NSString *dirPath = [@"/var/mobile/Documents/LineTweak" stringByExpandingTildeInPath];
    if (![fm fileExistsAtPath:dirPath]) {
        [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (debugLog) NSLog(@"[LineTweak] 📁 저장 디렉토리 생성: %@", dirPath);
    }

    NSString *mediaPath = [MEDIA_STORAGE_PATH stringByExpandingTildeInPath];
    if (![fm fileExistsAtPath:mediaPath]) {
        [fm createDirectoryAtPath:mediaPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (debugLog) NSLog(@"[LineTweak] 📁 미디어 디렉토리 생성: %@", mediaPath);
    }
}

- (NSString *)saveImage:(UIImage *)image withPrefix:(NSString *)prefix {
    if (!image || !saveMedia) return nil;

    [self ensureStorageDirectory];

    NSString *timestamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    NSString *filename = [NSString stringWithFormat:@"%@_%@.jpg", prefix, timestamp];
    NSString *filePath = [[MEDIA_STORAGE_PATH stringByExpandingTildeInPath] stringByAppendingPathComponent:filename];

    NSData *imageData;
    if (compressMedia) {
        // 압축 (품질 70%)
        imageData = UIImageJPEGRepresentation(image, 0.7);
    } else {
        // 원본 품질
        imageData = UIImageJPEGRepresentation(image, 1.0);
    }

    if ([imageData writeToFile:filePath atomically:YES]) {
        if (debugLog) NSLog(@"[LineTweak] 🖼️ 이미지 저장됨: %@ (%.2f KB)", filename, imageData.length / 1024.0);
        return filename;
    }

    return nil;
}

- (NSString *)saveVideoFromURL:(NSURL *)url withPrefix:(NSString *)prefix {
    if (!url || !saveMedia) return nil;

    [self ensureStorageDirectory];

    NSString *timestamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    NSString *extension = url.pathExtension.length > 0 ? url.pathExtension : @"mov";
    NSString *filename = [NSString stringWithFormat:@"%@_%@.%@", prefix, timestamp, extension];
    NSString *filePath = [[MEDIA_STORAGE_PATH stringByExpandingTildeInPath] stringByAppendingPathComponent:filename];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;

    if ([fm fileExistsAtPath:url.path]) {
        if ([fm copyItemAtPath:url.path toPath:filePath error:&error]) {
            NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error:nil];
            unsigned long long fileSize = [attrs fileSize];
            if (debugLog) NSLog(@"[LineTweak] 🎥 비디오 저장됨: %@ (%.2f MB)", filename, fileSize / 1024.0 / 1024.0);
            return filename;
        } else {
            if (debugLog) NSLog(@"[LineTweak] ❌ 비디오 저장 실패: %@", error);
        }
    }

    return nil;
}

- (NSString *)saveDataFromURL:(NSURL *)url withPrefix:(NSString *)prefix {
    if (!url || !saveMedia) return nil;

    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) return nil;

    [self ensureStorageDirectory];

    NSString *timestamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    NSString *extension = url.pathExtension.length > 0 ? url.pathExtension : @"dat";
    NSString *filename = [NSString stringWithFormat:@"%@_%@.%@", prefix, timestamp, extension];
    NSString *filePath = [[MEDIA_STORAGE_PATH stringByExpandingTildeInPath] stringByAppendingPathComponent:filename];

    if ([data writeToFile:filePath atomically:YES]) {
        if (debugLog) NSLog(@"[LineTweak] 📄 파일 저장됨: %@ (%.2f KB)", filename, data.length / 1024.0);
        return filename;
    }

    return nil;
}

- (NSArray *)extractMediaFromObject:(id)object {
    if (!object || !saveMedia) return @[];

    NSMutableArray *mediaFiles = [NSMutableArray array];

    // UIImage 탐색
    if ([object isKindOfClass:[UIImage class]]) {
        NSString *filename = [self saveImage:(UIImage *)object withPrefix:@"img"];
        if (filename) [mediaFiles addObject:filename];
        return mediaFiles;
    }

    // 객체의 프로퍼티 탐색
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([object class], &propertyCount);

    for (unsigned int i = 0; i < propertyCount; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *key = [NSString stringWithUTF8String:propertyName];

        @try {
            id value = [object valueForKey:key];

            if ([value isKindOfClass:[UIImage class]]) {
                NSString *filename = [self saveImage:(UIImage *)value withPrefix:@"img"];
                if (filename) [mediaFiles addObject:filename];
            }
            else if ([value isKindOfClass:[NSURL class]]) {
                NSURL *url = (NSURL *)value;
                NSString *ext = url.pathExtension.lowercaseString;

                if ([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"] ||
                    [ext isEqualToString:@"png"] || [ext isEqualToString:@"gif"]) {
                    // 이미지 URL
                    UIImage *img = [UIImage imageWithContentsOfFile:url.path];
                    if (img) {
                        NSString *filename = [self saveImage:img withPrefix:@"img"];
                        if (filename) [mediaFiles addObject:filename];
                    } else {
                        NSString *filename = [self saveDataFromURL:url withPrefix:@"img"];
                        if (filename) [mediaFiles addObject:filename];
                    }
                }
                else if ([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mov"] ||
                         [ext isEqualToString:@"m4v"] || [ext isEqualToString:@"avi"]) {
                    // 비디오 URL
                    NSString *filename = [self saveVideoFromURL:url withPrefix:@"vid"];
                    if (filename) [mediaFiles addObject:filename];
                }
            }
            else if ([value isKindOfClass:[NSData class]]) {
                // NSData에서 이미지 시도
                UIImage *img = [UIImage imageWithData:(NSData *)value];
                if (img) {
                    NSString *filename = [self saveImage:img withPrefix:@"img"];
                    if (filename) [mediaFiles addObject:filename];
                }
            }
            else if ([value isKindOfClass:[NSArray class]]) {
                // 배열 내부 탐색
                for (id item in (NSArray *)value) {
                    NSArray *subMedia = [self extractMediaFromObject:item];
                    [mediaFiles addObjectsFromArray:subMedia];
                }
            }
        }
        @catch (NSException *exception) {
            // valueForKey 실패 무시
        }
    }

    free(properties);
    return mediaFiles;
}

- (void)saveDeletedMessage:(NSDictionary *)messageInfo {
    [self ensureStorageDirectory];

    NSMutableArray *messages = [NSMutableArray arrayWithArray:[self getAllDeletedMessages]];

    // 타임스탬프 추가
    NSMutableDictionary *enrichedMessage = [messageInfo mutableCopy];
    enrichedMessage[@"deletedAt"] = @([[NSDate date] timeIntervalSince1970]);

    [messages addObject:enrichedMessage];

    // 최근 N개만 저장 (용량 관리)
    if (messages.count > maxMessages) {
        [messages removeObjectsInRange:NSMakeRange(0, messages.count - maxMessages)];
    }

    NSString *path = [DELETED_MESSAGES_PATH stringByExpandingTildeInPath];
    [messages writeToFile:path atomically:YES];

    if (debugLog) {
        NSLog(@"[LineTweak] 💾 삭제된 메시지 저장됨: %lu개", (unsigned long)messages.count);
    }
}

- (NSArray *)getAllDeletedMessages {
    NSString *path = [DELETED_MESSAGES_PATH stringByExpandingTildeInPath];
    NSArray *messages = [NSArray arrayWithContentsOfFile:path];
    return messages ?: @[];
}

@end

// 트윅 로드 시 로그
%ctor {
    NSLog(@"[LineTweak] ✅ Line 전송취소 방지 트윅 로드됨!");
    [[LineTweakStorage sharedInstance] ensureStorageDirectory];

    // 설정 로드
    loadPreferences();

    // 설정 변경 감지
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                   NULL,
                                   (CFNotificationCallback)loadPreferences,
                                   CFSTR("com.taeho.linetweak/ReloadPrefs"),
                                   NULL,
                                   CFNotificationSuspensionBehaviorCoalesce);
}

%hook NSObject

// 메시지 삭제/취소 관련 메서드 감지
- (void)deleteMessage:(id)message {
    if (!tweakEnabled) {
        %orig;
        return;
    }

    if (debugLog) {
        NSLog(@"[LineTweak] 🗑️ deleteMessage 호출됨!");
        NSLog(@"[LineTweak] Class: %@", NSStringFromClass([self class]));
        NSLog(@"[LineTweak] Message: %@", message);
    }

    // 미디어 추출
    NSArray *mediaFiles = [[LineTweakStorage sharedInstance] extractMediaFromObject:message];

    // 메시지 정보 저장
    NSMutableDictionary *messageInfo = [@{
        @"type": @"delete",
        @"class": NSStringFromClass([self class]),
        @"message": [NSString stringWithFormat:@"%@", message],
        @"timestamp": @([[NSDate date] timeIntervalSince1970])
    } mutableCopy];

    if (mediaFiles.count > 0) {
        messageInfo[@"mediaFiles"] = mediaFiles;
        messageInfo[@"hasMedia"] = @YES;
    }

    [[LineTweakStorage sharedInstance] saveDeletedMessage:messageInfo];

    // 원본 메서드 호출하지 않음 (삭제 방지)
    // %orig;
    if (debugLog) {
        NSLog(@"[LineTweak] ⛔ 메시지 삭제 차단됨! (미디어: %lu개)", (unsigned long)mediaFiles.count);
    }
}

- (void)removeMessage:(id)message {
    if (!tweakEnabled) {
        %orig;
        return;
    }

    if (debugLog) {
        NSLog(@"[LineTweak] 🗑️ removeMessage 호출됨!");
        NSLog(@"[LineTweak] Class: %@", NSStringFromClass([self class]));
        NSLog(@"[LineTweak] Message: %@", message);
    }

    // 미디어 추출
    NSArray *mediaFiles = [[LineTweakStorage sharedInstance] extractMediaFromObject:message];

    NSMutableDictionary *messageInfo = [@{
        @"type": @"remove",
        @"class": NSStringFromClass([self class]),
        @"message": [NSString stringWithFormat:@"%@", message],
        @"timestamp": @([[NSDate date] timeIntervalSince1970])
    } mutableCopy];

    if (mediaFiles.count > 0) {
        messageInfo[@"mediaFiles"] = mediaFiles;
        messageInfo[@"hasMedia"] = @YES;
    }

    [[LineTweakStorage sharedInstance] saveDeletedMessage:messageInfo];

    // %orig;
    if (debugLog) {
        NSLog(@"[LineTweak] ⛔ 메시지 제거 차단됨! (미디어: %lu개)", (unsigned long)mediaFiles.count);
    }
}

- (void)unsendMessage:(id)message {
    if (!tweakEnabled) {
        %orig;
        return;
    }

    if (debugLog) {
        NSLog(@"[LineTweak] 📤 unsendMessage 호출됨!");
        NSLog(@"[LineTweak] Class: %@", NSStringFromClass([self class]));
        NSLog(@"[LineTweak] Message: %@", message);
    }

    // 미디어 추출
    NSArray *mediaFiles = [[LineTweakStorage sharedInstance] extractMediaFromObject:message];

    NSMutableDictionary *messageInfo = [@{
        @"type": @"unsend",
        @"class": NSStringFromClass([self class]),
        @"message": [NSString stringWithFormat:@"%@", message],
        @"timestamp": @([[NSDate date] timeIntervalSince1970])
    } mutableCopy];

    if (mediaFiles.count > 0) {
        messageInfo[@"mediaFiles"] = mediaFiles;
        messageInfo[@"hasMedia"] = @YES;
    }

    [[LineTweakStorage sharedInstance] saveDeletedMessage:messageInfo];

    // %orig;
    if (debugLog) {
        NSLog(@"[LineTweak] ⛔ 메시지 전송취소 차단됨! (미디어: %lu개)", (unsigned long)mediaFiles.count);
    }
}

%end

// UITableView/UICollectionView 셀 삭제 방지
%hook UITableView

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (!tweakEnabled) {
        %orig;
        return;
    }

    if (debugLog) {
        NSLog(@"[LineTweak] 📋 UITableView 행 삭제 차단: %@", indexPaths);
        NSLog(@"[LineTweak] ⛔ UI 삭제 애니메이션 차단됨!");
    }

    // 삭제 애니메이션 완전히 차단 - %orig 호출 안 함
}

%end

// UICollectionView 삭제도 차단
%hook UICollectionView

- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (!tweakEnabled) {
        %orig;
        return;
    }

    if (debugLog) {
        NSLog(@"[LineTweak] 📋 UICollectionView 아이템 삭제 차단: %@", indexPaths);
    }

    // 삭제 차단
}

%end

// 앱 시작 시 저장된 메시지 확인
%hook UIApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;

    NSLog(@"[LineTweak] 🚀 Line 앱 시작!");

    // 저장된 메시지 개수 확인
    NSArray *deletedMessages = [[LineTweakStorage sharedInstance] getAllDeletedMessages];
    NSLog(@"[LineTweak] 📦 저장된 삭제 메시지: %lu개", (unsigned long)deletedMessages.count);

    // 미디어 파일 개수 계산
    NSInteger mediaCount = 0;
    for (NSDictionary *msg in deletedMessages) {
        if ([msg[@"hasMedia"] boolValue]) {
            NSArray *files = msg[@"mediaFiles"];
            mediaCount += files.count;
        }
    }

    // 알림 표시
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"LineTweak 활성화"
            message:[NSString stringWithFormat:@"전송취소 방지 활성화\n저장된 메시지: %lu개\n미디어 파일: %ld개",
                    (unsigned long)deletedMessages.count, (long)mediaCount]
            preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *viewAction = [UIAlertAction
            actionWithTitle:@"저장된 메시지 보기"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                // 저장된 메시지 로그 출력
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

%end

// CoreData 삭제 방지 (Line이 CoreData 사용하는 경우)
%hook NSManagedObjectContext

- (BOOL)save:(NSError **)error {
    if (!tweakEnabled) {
        return %orig;
    }

    // 삭제 대기 중인 객체 로깅 및 복원
    NSSet *deletedObjects = [self deletedObjects];
    if (deletedObjects.count > 0) {
        if (debugLog) {
            NSLog(@"[LineTweak] 🗄️ CoreData 삭제 시도: %lu개 객체", (unsigned long)deletedObjects.count);
        }

        NSMutableArray *objectsToRestore = [NSMutableArray array];

        for (NSManagedObject *obj in deletedObjects) {
            // 엔티티 이름 확인 - 메시지 관련 엔티티만 처리
            NSString *entityName = obj.entity.name ?: @"";
            BOOL isMessageEntity = [entityName rangeOfString:@"Message" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                                   [entityName rangeOfString:@"Chat" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                                   [entityName rangeOfString:@"Talk" options:NSCaseInsensitiveSearch].location != NSNotFound;

            if (isMessageEntity) {
                if (debugLog) {
                    NSLog(@"[LineTweak] 💾 메시지 엔티티 삭제 차단: %@", entityName);
                    NSLog(@"[LineTweak] 객체: %@", obj);
                }

                // 미디어 추출
                NSArray *mediaFiles = [[LineTweakStorage sharedInstance] extractMediaFromObject:obj];

                // 삭제 정보 저장
                NSMutableDictionary *messageInfo = [@{
                    @"type": @"coredata_delete",
                    @"entity": entityName,
                    @"object": [NSString stringWithFormat:@"%@", obj],
                    @"timestamp": @([[NSDate date] timeIntervalSince1970])
                } mutableCopy];

                if (mediaFiles.count > 0) {
                    messageInfo[@"mediaFiles"] = mediaFiles;
                    messageInfo[@"hasMedia"] = @YES;
                }

                [[LineTweakStorage sharedInstance] saveDeletedMessage:messageInfo];

                // 삭제 취소 - 객체를 컨텍스트에 다시 추가
                [objectsToRestore addObject:obj];
            }
        }

        // 삭제된 객체들을 복원
        for (NSManagedObject *obj in objectsToRestore) {
            @try {
                // 삭제 상태를 취소
                [self refreshObject:obj mergeChanges:NO];
            }
            @catch (NSException *exception) {
                if (debugLog) {
                    NSLog(@"[LineTweak] ⚠️ 객체 복원 실패: %@", exception);
                }
            }
        }

        if (debugLog && objectsToRestore.count > 0) {
            NSLog(@"[LineTweak] ✅ %lu개 메시지 삭제 차단됨!", (unsigned long)objectsToRestore.count);
        }
    }

    return %orig;
}

%end
