INSTALL_TARGET_PROCESSES = SpringBoard
TARGET = iphone:14.5:14.5
ARCHS = arm64 arm64e
export GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = JellyLockReborn
JellyLockReborn_FILES = hooks.xm $(wildcard VIEWS/*.m)
JellyLockReborn_PRIVATE_FRAMEWORKS = MediaRemote
JellyLockReborn_EXTRA_FRAMEWORKS += Cephei
JellyLockReborn_LIBRARIES = sparkapplist
JellyLockReborn_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"