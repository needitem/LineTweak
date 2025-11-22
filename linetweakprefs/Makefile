TARGET := iphone:clang:16.5:14.0
ARCHS = arm64 arm64e

THEOS_PACKAGE_INSTALL_PREFIX = /var/jb

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LineTweakPrefs

LineTweakPrefs_FILES = LineTweakPrefsRootListController.m
LineTweakPrefs_FRAMEWORKS = UIKit Preferences
LineTweakPrefs_PRIVATE_FRAMEWORKS = Preferences
LineTweakPrefs_CFLAGS = -fobjc-arc
LineTweakPrefs_INSTALL_PATH = /Library/PreferenceBundles

include $(THEOS_MAKE_PATH)/bundle.mk
