#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#define PREFS_PATH @"/var/mobile/Library/Preferences/com.taeho.linetweak.plist"
#define DELETED_MESSAGES_PATH @"/var/mobile/Documents/LineTweak/DeletedMessages.plist"

@interface LineTweakPrefsRootListController : PSListController
@end

@implementation LineTweakPrefsRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];

        // 헤더
        PSSpecifier *groupSpec = [PSSpecifier preferenceSpecifierNamed:@"LineTweak 설정"
                                                                 target:self
                                                                    set:NULL
                                                                    get:NULL
                                                                 detail:Nil
                                                                   cell:PSGroupCell
                                                                   edit:Nil];
        [groupSpec setProperty:@"Line 메시지 삭제 방지" forKey:@"footerText"];
        [specs addObject:groupSpec];

        // 활성화/비활성화 스위치
        PSSpecifier *enableSpec = [PSSpecifier preferenceSpecifierNamed:@"트윅 활성화"
                                                                  target:self
                                                                     set:@selector(setPreferenceValue:specifier:)
                                                                     get:@selector(readPreferenceValue:)
                                                                  detail:Nil
                                                                    cell:PSSwitchCell
                                                                    edit:Nil];
        [enableSpec setProperty:@"enabled" forKey:@"key"];
        [enableSpec setProperty:@YES forKey:@"default"];
        [enableSpec setProperty:PREFS_PATH forKey:@"defaults"];
        [enableSpec setProperty:@"com.taeho.linetweak/ReloadPrefs" forKey:@"PostNotification"];
        [specs addObject:enableSpec];

        // 저장된 메시지 정보
        PSSpecifier *infoGroup = [PSSpecifier preferenceSpecifierNamed:@"저장된 메시지"
                                                                target:self
                                                                   set:NULL
                                                                   get:NULL
                                                                detail:Nil
                                                                  cell:PSGroupCell
                                                                  edit:Nil];
        [specs addObject:infoGroup];

        // 메시지 개수 표시
        PSSpecifier *countSpec = [PSSpecifier preferenceSpecifierNamed:@"저장된 메시지 개수"
                                                                target:self
                                                                   set:NULL
                                                                   get:@selector(getMessageCount:)
                                                                detail:Nil
                                                                  cell:PSTitleValueCell
                                                                  edit:Nil];
        [specs addObject:countSpec];

        // 메시지 목록 보기 버튼
        PSSpecifier *viewSpec = [PSSpecifier preferenceSpecifierNamed:@"메시지 목록 보기"
                                                               target:self
                                                                  set:NULL
                                                                  get:NULL
                                                               detail:Nil
                                                                 cell:PSButtonCell
                                                                 edit:Nil];
        viewSpec->action = @selector(viewMessages);
        [specs addObject:viewSpec];

        // 전체 삭제 버튼
        PSSpecifier *clearSpec = [PSSpecifier preferenceSpecifierNamed:@"저장된 메시지 전체 삭제"
                                                                target:self
                                                                   set:NULL
                                                                   get:NULL
                                                                detail:Nil
                                                                  cell:PSButtonCell
                                                                  edit:Nil];
        clearSpec->action = @selector(clearAllMessages);
        [clearSpec setProperty:[UIColor redColor] forKey:@"textColor"];
        [specs addObject:clearSpec];

        // 설정
        PSSpecifier *settingsGroup = [PSSpecifier preferenceSpecifierNamed:@"설정"
                                                                    target:self
                                                                       set:NULL
                                                                       get:NULL
                                                                    detail:Nil
                                                                      cell:PSGroupCell
                                                                      edit:Nil];
        [specs addObject:settingsGroup];

        // 저장 개수 제한
        PSSpecifier *limitSpec = [PSSpecifier preferenceSpecifierNamed:@"최대 저장 개수"
                                                                target:self
                                                                   set:@selector(setPreferenceValue:specifier:)
                                                                   get:@selector(readPreferenceValue:)
                                                                detail:Nil
                                                                  cell:PSEditTextCell
                                                                  edit:Nil];
        [limitSpec setProperty:@"maxMessages" forKey:@"key"];
        [limitSpec setProperty:@"1000" forKey:@"default"];
        [limitSpec setProperty:PREFS_PATH forKey:@"defaults"];
        [limitSpec setProperty:@"com.taeho.linetweak/ReloadPrefs" forKey:@"PostNotification"];
        [limitSpec setProperty:@YES forKey:@"isNumeric"];
        [limitSpec setProperty:@"숫자만 입력 (기본값: 1000)" forKey:@"placeholder"];
        [specs addObject:limitSpec];

        // 미디어 저장
        PSSpecifier *saveMediaSpec = [PSSpecifier preferenceSpecifierNamed:@"사진/동영상 저장"
                                                                    target:self
                                                                       set:@selector(setPreferenceValue:specifier:)
                                                                       get:@selector(readPreferenceValue:)
                                                                    detail:Nil
                                                                      cell:PSSwitchCell
                                                                      edit:Nil];
        [saveMediaSpec setProperty:@"saveMedia" forKey:@"key"];
        [saveMediaSpec setProperty:@YES forKey:@"default"];
        [saveMediaSpec setProperty:PREFS_PATH forKey:@"defaults"];
        [saveMediaSpec setProperty:@"com.taeho.linetweak/ReloadPrefs" forKey:@"PostNotification"];
        [specs addObject:saveMediaSpec];

        // 미디어 압축
        PSSpecifier *compressSpec = [PSSpecifier preferenceSpecifierNamed:@"미디어 압축 (용량 절약)"
                                                                   target:self
                                                                      set:@selector(setPreferenceValue:specifier:)
                                                                      get:@selector(readPreferenceValue:)
                                                                   detail:Nil
                                                                     cell:PSSwitchCell
                                                                     edit:Nil];
        [compressSpec setProperty:@"compressMedia" forKey:@"key"];
        [compressSpec setProperty:@YES forKey:@"default"];
        [compressSpec setProperty:PREFS_PATH forKey:@"defaults"];
        [compressSpec setProperty:@"com.taeho.linetweak/ReloadPrefs" forKey:@"PostNotification"];
        [specs addObject:compressSpec];

        // 광고 차단
        PSSpecifier *blockAdsSpec = [PSSpecifier preferenceSpecifierNamed:@"광고 차단"
                                                                   target:self
                                                                      set:@selector(setPreferenceValue:specifier:)
                                                                      get:@selector(readPreferenceValue:)
                                                                   detail:Nil
                                                                     cell:PSSwitchCell
                                                                     edit:Nil];
        [blockAdsSpec setProperty:@"blockAds" forKey:@"key"];
        [blockAdsSpec setProperty:@YES forKey:@"default"];
        [blockAdsSpec setProperty:PREFS_PATH forKey:@"defaults"];
        [blockAdsSpec setProperty:@"com.taeho.linetweak/ReloadPrefs" forKey:@"PostNotification"];
        [specs addObject:blockAdsSpec];

        // 디버그 로그
        PSSpecifier *debugSpec = [PSSpecifier preferenceSpecifierNamed:@"디버그 로그"
                                                                target:self
                                                                   set:@selector(setPreferenceValue:specifier:)
                                                                   get:@selector(readPreferenceValue:)
                                                                detail:Nil
                                                                  cell:PSSwitchCell
                                                                  edit:Nil];
        [debugSpec setProperty:@"debugLog" forKey:@"key"];
        [debugSpec setProperty:@YES forKey:@"default"];
        [debugSpec setProperty:PREFS_PATH forKey:@"defaults"];
        [debugSpec setProperty:@"com.taeho.linetweak/ReloadPrefs" forKey:@"PostNotification"];
        [specs addObject:debugSpec];

        // About
        PSSpecifier *aboutGroup = [PSSpecifier preferenceSpecifierNamed:@"정보"
                                                                 target:self
                                                                    set:NULL
                                                                    get:NULL
                                                                 detail:Nil
                                                                   cell:PSGroupCell
                                                                   edit:Nil];
        [aboutGroup setProperty:@"LineTweak v1.0.0\nby Taeho" forKey:@"footerText"];
        [specs addObject:aboutGroup];

        _specifiers = [specs copy];
    }

    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *path = [specifier propertyForKey:@"defaults"];
    NSString *key = [specifier propertyForKey:@"key"];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:path];

    id value = prefs[key];
    if (!value) {
        value = [specifier propertyForKey:@"default"];
    }

    return value;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *path = [specifier propertyForKey:@"defaults"];
    NSString *key = [specifier propertyForKey:@"key"];

    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:path] ?: [NSMutableDictionary dictionary];
    [prefs setObject:value forKey:key];
    [prefs writeToFile:path atomically:YES];

    NSString *notification = [specifier propertyForKey:@"PostNotification"];
    if (notification) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                            (__bridge CFStringRef)notification,
                                            NULL, NULL, YES);
    }
}

- (NSString *)getMessageCount:(PSSpecifier *)specifier {
    NSArray *messages = [NSArray arrayWithContentsOfFile:DELETED_MESSAGES_PATH];
    return [NSString stringWithFormat:@"%lu개", (unsigned long)(messages.count ?: 0)];
}

- (void)viewMessages {
    NSArray *messages = [NSArray arrayWithContentsOfFile:DELETED_MESSAGES_PATH];

    if (!messages || messages.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"메시지 없음"
                                                                       message:@"저장된 삭제 메시지가 없습니다."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    NSMutableString *messageList = [NSMutableString string];
    for (NSDictionary *msg in messages) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[msg[@"timestamp"] doubleValue]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

        [messageList appendFormat:@"[%@] %@\n%@\n\n",
         [formatter stringFromDate:date],
         msg[@"type"] ?: @"unknown",
         msg[@"message"] ?: @""];
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"삭제된 메시지 목록"
                                                                   message:messageList
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)clearAllMessages {
    UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"확인"
                                                                     message:@"저장된 모든 메시지를 삭제하시겠습니까?"
                                                              preferredStyle:UIAlertControllerStyleAlert];

    [confirm addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:nil]];
    [confirm addAction:[UIAlertAction actionWithTitle:@"삭제"
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction *action) {
        [[NSFileManager defaultManager] removeItemAtPath:DELETED_MESSAGES_PATH error:nil];

        UIAlertController *success = [UIAlertController alertControllerWithTitle:@"완료"
                                                                         message:@"모든 메시지가 삭제되었습니다."
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        [success addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:success animated:YES completion:nil];

        [self reloadSpecifiers];
    }]];

    [self presentViewController:confirm animated:YES completion:nil];
}

@end
