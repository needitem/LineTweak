# Custom Theos configuration for Docker cross-compilation
SYSROOT = $(THEOS)/sdks/iPhoneOS16.5.sdk

# Use ld.gold instead of ld for better cross-compilation support
ifeq ($(shell uname -s),Linux)
    LDFLAGS += -fuse-ld=gold
endif
