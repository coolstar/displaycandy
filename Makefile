export ARCHS = armv7
export TARGET = iphone:clang:latest:5.0
#export DEBUG = 1

THEOS_PACKAGE_DIR_NAME = packages

include theos/makefiles/common.mk

SUBPROJECTS = displaycandysettings

TWEAK_NAME = DisplayCandy
DisplayCandy_FILES = DCFunctions.m Tweak.x DCTransitionController.m DCTransitionView.m DCAppToAppWrapperView.x DCBuiltInTransitionView.m DCCoverTransitionView.m DCRevealTransitionView.m DCPushTransitionView.m DCTVTubeTransitionView.m DCSwingTransitionView.m DCZoomTransitionView.x DCDisplayStackManager.x DCSettings.m
DisplayCandy_FRAMEWORKS = UIKit QuartzCore CoreGraphics
DisplayCandy_PRIVATE_FRAMEWORKS = GraphicsServices

include $(THEOS_MAKE_PATH)/aggregate.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
