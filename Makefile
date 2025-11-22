TARGET := iphone:clang:16.5:14.0
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = LINE
THEOS_PACKAGE_INSTALL_PREFIX = /var/jb

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LineTweak

LineTweak_FILES = Tweak.x
LineTweak_CFLAGS = -fobjc-arc -fno-modules -fno-objc-arc-exceptions
LineTweak_FRAMEWORKS = UIKit Foundation CoreData AVFoundation WebKit

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += linetweakprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
