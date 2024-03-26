TARGET := iphone:clang:latest:14.0
ARCHS := arm64

INSTALL_TARGET_PROCESSES = Crunchyroll

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Crunchyrold

$(TWEAK_NAME)_FILES = $(wildcard *.x) $(wildcard *.m) $(wildcard ZipArchive/SSZipArchive/*.m) $(wildcard ZipArchive/SSZipArchive/minizip/*.c)
$(TWEAK_NAME)_FRAMEWORKS += Security
$(TWEAK_NAME)_LIBRARIES = z iconv
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -DHAVE_INTTYPES_H -DHAVE_PKCRYPT -DHAVE_STDINT_H -DHAVE_WZAES -DHAVE_ZLIB -DZLIB_COMPAT -Wno-unused-but-set-variable

include $(THEOS_MAKE_PATH)/tweak.mk
