TARGET = iphone:14.5:14.5
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = jellylockrebornpref


jellylockrebornpref_FILES = JLRRootListController.m AppearanceListController.m AppShortcutsListController.m shortcutsListController.m
jellylockrebornpref_FRAMEWORKS = UIKit 
jellylockrebornpref_PRIVATE_FRAMEWORKS = Preferences
jellylockrebornpref_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
jellylockrebornpref_LIBRARIES = colorpicker sparkapplist
jellylockrebornpref_INSTALL_PATH = /Library/PreferenceBundles
jellylockrebornpref_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
