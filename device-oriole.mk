#
# Copyright (C) 2020 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Restrict the visibility of Android.bp files to improve build analysis time
$(call inherit-product-if-exists, vendor/google/products/sources_pixel.mk)

TARGET_KERNEL_DIR ?= device/google/raviole-kernel
TARGET_BOARD_KERNEL_HEADERS := device/google/raviole-kernel/kernel-headers

ifdef RELEASE_GOOGLE_ORIOLE_KERNEL_VERSION
TARGET_LINUX_KERNEL_VERSION := $(RELEASE_GOOGLE_ORIOLE_KERNEL_VERSION)
endif

ifdef RELEASE_GOOGLE_ORIOLE_KERNEL_DIR
TARGET_KERNEL_DIR := $(RELEASE_GOOGLE_ORIOLE_KERNEL_DIR)
TARGET_BOARD_KERNEL_HEADERS := $(RELEASE_GOOGLE_ORIOLE_KERNEL_DIR)/kernel-headers
endif

$(call inherit-product-if-exists, vendor/google_devices/raviole/prebuilts/device-vendor-oriole.mk)
$(call inherit-product-if-exists, vendor/google_devices/gs101/prebuilts/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/gs101/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/oriole/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/raviole/proprietary/oriole/device-vendor-oriole.mk)
$(call inherit-product-if-exists, vendor/google/camera/devices/raviole/oriole/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/raviole/proprietary/WallpapersOriole.mk)

DEVICE_PACKAGE_OVERLAYS += device/google/raviole/oriole/overlay

include device/google/raviole/audio/oriole/audio-tables.mk
include device/google/gs101/device-shipping-common.mk
include device/google/gs101/telephony/pktrouter.mk
include hardware/google/pixel/vibrator/cs40l25/device.mk
include device/google/gs-common/bcmbt/bluetooth.mk
include device/google/gs-common/touch/stm/stm11.mk

# Fingerprint HAL
GOODIX_CONFIG_BUILD_VERSION := g6_trusty
ifneq (,$(filter AP1%,$(RELEASE_PLATFORM_VERSION)))
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/raviole/prebuilts/firmware/fingerprint/24Q1
else ifneq (,$(filter AP2% AP3%,$(RELEASE_PLATFORM_VERSION)))
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/raviole/prebuilts/firmware/fingerprint/24Q2
else
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/raviole/prebuilts/firmware/fingerprint/trunk
endif
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_common.mk)
ifeq ($(filter factory%, $(TARGET_PRODUCT)),)
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_shipping.mk)
else
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_factory.mk)
endif

# go/lyric-soong-variables
$(call soong_config_set,lyric,camera_hardware,oriole)
$(call soong_config_set,lyric,tuning_product,oriole)
$(call soong_config_set,google3a_config,target_device,oriole)

# Init files
PRODUCT_COPY_FILES += \
	device/google/raviole/conf/init.raviole.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.raviole.rc \
	device/google/raviole/conf/init.oriole.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.oriole.rc

# Recovery files
PRODUCT_COPY_FILES += \
	device/google/gs101/conf/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.oriole.rc

# insmod files
PRODUCT_COPY_FILES += \
	device/google/raviole/init.insmod.oriole.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/init.insmod.oriole.cfg

# Thermal Config
PRODUCT_COPY_FILES += \
	device/google/raviole/thermal_info_config_oriole.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config.json \
	device/google/raviole/thermal_info_config_charge_oriole.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config_charge.json \
	device/google/raviole/thermal_info_config_oriole_WHI_A.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config_WHI_A.json

# Power HAL config
PRODUCT_COPY_FILES += \
	device/google/raviole/powerhint-oriole.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json \
	device/google/raviole/powerhint-oriole-mainline.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint-mainline.json \

# Bluetooth sepolicy
include device/google/gs101/sepolicy/oriole-sepolicy.mk

# Bluetooth
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.a2dp_aac.vbr_supported=true \
    persist.bluetooth.firmware.selection=BCM.hcd

# Bluetooth Tx power caps for oriole
PRODUCT_COPY_FILES += \
    device/google/raviole/bluetooth_power_limits_oriole.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits.csv \
    device/google/raviole/bluetooth_power_limits_oriole_jp.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_JP.csv \
    device/google/raviole/bluetooth_power_limits_G9S9B_US.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_G9S9B_US.csv \
    device/google/raviole/bluetooth_power_limits_GB7N6_US.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_GB7N6_US.csv \
    device/google/raviole/bluetooth_power_limits_G9S9B_EU.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_G9S9B_EU.csv \
    device/google/raviole/bluetooth_power_limits_GB7N6_EU.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_GB7N6_EU.csv


# Bluetooth Hal Extension test tools
ifneq (,$(filter eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PACKAGES_DEBUG += \
    sar_test \
    hci_inject
endif

# userdebug specific
ifneq (,$(filter eng, $(TARGET_BUILD_VARIANT)))
# Bluetooth LE Audio Hardware offload
PRODUCT_PRODUCT_PROPERTIES += \
    ro.bluetooth.leaudio_offload.supported=true \
    persist.bluetooth.leaudio_offload.disabled=true \
    persist.bluetooth.le_audio_test=false
endif

# Bluetooth HAL
PRODUCT_COPY_FILES += \
	device/google/raviole/bluetooth/bt_vendor_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth/bt_vendor_overlay.conf

# MIPI Coex Configs
PRODUCT_COPY_FILES += \
    device/google/raviole/radio/oriole_display_mipi_coex_table.csv:$(TARGET_COPY_OUT_VENDOR)/etc/modem/display_primary_mipi_coex_table.csv \
    device/google/raviole/radio/oriole_camera_front_mipi_coex_table.csv:$(TARGET_COPY_OUT_VENDOR)/etc/modem/camera_front_mipi_coex_table.csv \
    device/google/raviole/radio/oriole_camera_rear_wide_mipi_coex_table.csv:$(TARGET_COPY_OUT_VENDOR)/etc/modem/camera_rear_wide_mipi_coex_table.csv

# Camera
PRODUCT_COPY_FILES += \
	device/google/raviole/media_profiles_oriole.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml

PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.camera.fixed_fps_range_boost=1

# Display Config
PRODUCT_COPY_FILES += \
	device/google/raviole/oriole/display_golden_cal0.pb:$(TARGET_COPY_OUT_VENDOR)/etc/display_golden_cal0.pb \
	device/google/raviole/oriole/display_colordata_dev_cal0.pb:$(TARGET_COPY_OUT_VENDOR)/etc/display_colordata_dev_cal0.pb

# NFC
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
	frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
	frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
	frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml \
	frameworks/native/data/etc/android.hardware.nfc.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.uicc.xml \
	frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.ese.xml \
	device/google/raviole/nfc/libnfc-hal-st.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libnfc-hal-st.conf \
	device/google/raviole/nfc/libnfc-nci.conf:$(TARGET_COPY_OUT_PRODUCT)/etc/libnfc-nci.conf

PRODUCT_PACKAGES += \
	$(RELEASE_PACKAGE_NFC_STACK) \
	Tag \
	android.hardware.nfc-service.st \
	NfcOverlayOriole

# SecureElement
PRODUCT_PACKAGES += \
	android.hardware.secure_element@1.2-service-gto \
	android.hardware.secure_element@1.2-service-gto-ese2

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.ese.xml \
	frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml \
	device/google/raviole/nfc/libse-gto-hal.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libse-gto-hal.conf \
	device/google/raviole/nfc/libse-gto-hal2.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libse-gto-hal2.conf

DEVICE_MANIFEST_FILE += \
	device/google/raviole/nfc/manifest_se.xml

# Vibrator HAL
PRODUCT_PRODUCT_PROPERTIES +=\
    ro.vendor.vibrator.hal.long.frequency.shift=15 \
    ro.vendor.vibrator.hal.device.mass=0.205 \
    ro.vendor.vibrator.hal.loc.coeff=2.25 \
    persist.vendor.vibrator.hal.chirp.enabled=0

ACTUATOR_MODEL := luxshare_ict_081545

# PowerStats HAL
PRODUCT_SOONG_NAMESPACES += \
    device/google/raviole/powerstats/oriole \
    device/google/raviole

# Keyboard bottom padding in dp for portrait mode
PRODUCT_PRODUCT_PROPERTIES += ro.com.google.ime.kb_pad_port_b=10

# Display
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += vendor.display.lbe.supported=1
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.surface_flinger.set_idle_timer_ms=1500

# Media Performance Class 12
PRODUCT_PROPERTY_OVERRIDES += ro.odm.build.media_performance_class=31

# userdebug specific
ifneq (,$(filter eng, $(TARGET_BUILD_VARIANT)))
    PRODUCT_COPY_FILES += \
        device/google/gs101/init.hardware.wlc.rc.userdebug:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.wlc.rc
endif

# Increment the SVN for any official public releases
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.build.svn=82

# Set support hide display cutout feature
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_hide_display_cutout=true

# Hide cutout overlays
PRODUCT_PACKAGES += \
    NoCutoutOverlay \
    AvoidAppsInCutoutOverlay

# Android DeviceAsWebcam specific overlay
PRODUCT_PACKAGES += \
    DeviceAsWebcamOriole

# SKU specific RROs
PRODUCT_PACKAGES += \
    SettingsOverlayGR1YH \
    SettingsOverlayGB7N6 \
    SettingsOverlayG9S9B

# Fingerprint antispoof property
PRODUCT_PRODUCT_PROPERTIES +=\
    persist.vendor.fingerprint.disable.fake.override=none

# Fingerprint HAL
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.udfps.lhbm_controlled_in_hal_supported=true \
    persist.vendor.udfps.als_feed_forward_supported=true


# DCK properties based on target
PRODUCT_PROPERTY_OVERRIDES += \
    ro.gms.dck.eligible_wcc=2 \
    ro.gms.dck.se_capability=1

# Trusty liboemcrypto.so
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/raviole/prebuilts
ifneq (,$(filter AP1%,$(RELEASE_PLATFORM_VERSION)))
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/raviole/prebuilts/trusty/24Q1
else ifneq (,$(filter AP2% AP3%,$(RELEASE_PLATFORM_VERSION)))
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/raviole/prebuilts/trusty/24Q2
else
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/raviole/prebuilts/trusty/trunk
endif

# Set support one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode=true

# Enable camera exif model/make reporting
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.camera.exif_reveal_make_model=true

# tetheroffload HAL
PRODUCT_PACKAGES += \
	vendor.samsung_slsi.hardware.tetheroffload@1.1-service

# Override default distortion output gain according to UX experiments
PRODUCT_PRODUCT_PROPERTIES += \
    vendor.audio.hapticgenerator.distortion.output.gain=0.5

# RKPD
PRODUCT_PRODUCT_PROPERTIES += \
    remote_provisioning.hostname=remoteprovisioning.googleapis.com \

# Set zram size
PRODUCT_VENDOR_PROPERTIES += \
    vendor.zram.size=3g

# This device is shipped with 31 (Android S)
PRODUCT_SHIPPING_API_LEVEL := 31

# declare use of spatial audio
PRODUCT_PROPERTY_OVERRIDES += \
    ro.audio.spatializer_enabled=true

# optimize spatializer effect
PRODUCT_PROPERTY_OVERRIDES += \
    audio.spatializer.effect.util_clamp_min=300

PRODUCT_PACKAGES += \
	libspatialaudio

# Device features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml

# Bluetooth OPUS codec
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.opus.enabled=true

# Location
ifneq (,$(filter eng, $(TARGET_BUILD_VARIANT)))
        PRODUCT_COPY_FILES += \
		device/google/raviole/location/gps.xml.oriole:$(TARGET_COPY_OUT_VENDOR)/etc/gnss/gps.xml
else
        PRODUCT_COPY_FILES += \
		device/google/raviole/location/gps_user.xml.oriole:$(TARGET_COPY_OUT_VENDOR)/etc/gnss/gps.xml
endif

# Enable DeviceAsWebcam support
PRODUCT_VENDOR_PROPERTIES += \
    ro.usb.uvc.enabled=true

# Quick Start device-specific settings
PRODUCT_PRODUCT_PROPERTIES += \
    ro.quick_start.oem_id=00e0 \
    ro.quick_start.device_id=oriole
