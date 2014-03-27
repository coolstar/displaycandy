include theos/makefiles/common.mk

BUNDLE_NAME = DisplayCandySettings
DisplayCandySettings_FILES = DCSettingsListController.m
DisplayCandySettings_INSTALL_PATH = /Library/PreferenceBundles
DisplayCandySettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DisplayCandySettings.plist$(ECHO_END)
