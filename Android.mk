LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_PREBUILT_KERNEL),)
AHD_PATH := kernel/infineon/ahd

include $(CLEAR_VARS)

LOCAL_MODULE        := infineon-ahd
LOCAL_MODULE_SUFFIX := .ko
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(TARGET_OUT_VENDOR)/lib/modules

_ahd_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_ahd_ko := $(_ahd_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)
KERNEL_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
KERNEL_OUT_RELATIVE := ../../KERNEL_OBJ

AHD_PARAMS := CONFIG_BCMDHD=m CONFIG_BCM4356=y CONFIG_BCMDHD_SDIO=n CONFIG_BCMDHD_PCIE=y CONFIG_ANDROID=y CONFIG_WL_AP_IF=y CONFIG_ANDROID12=y CONFIG_ANDROID_VERSION=13 CONFIG_DHD_USE_SCHED_SCAN=y

$(_ahd_ko): $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/$(BOARD_KERNEL_IMAGE_NAME)
	@mkdir -p $(dir $@)
	@mkdir -p $(KERNEL_MODULES_OUT)/lib/modules
	@cp -R $(AHD_PATH)/* $(_ahd_intermediates)/
	$(hide) +$(KERNEL_MAKE_CMD) $(KERNEL_MAKE_FLAGS) -C $(_ahd_intermediates) ARCH=arm64 $(KERNEL_CROSS_COMPILE) $(AHD_PARAMS) KDIR=$(KERNEL_OUT_RELATIVE) all
	modules=$$(find $(_ahd_intermediates) -type f -name '*.ko'); \
	for f in $$modules; do \
		$(KERNEL_TOOLCHAIN_PATH)strip --strip-unneeded $$f; \
		cp $$f $(KERNEL_MODULES_OUT)/lib/modules; \
	done;
	touch $(_ahd_intermediates)/infineon-ahd.ko

include $(BUILD_SYSTEM)/base_rules.mk
endif
