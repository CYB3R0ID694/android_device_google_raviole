#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit some common Lineage stuff.
TARGET_DISABLE_EPPE := true
DISABLE_ARTIFACT_PATH_REQUIREMENTS := true
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Gapps
$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)

# Inherit device configuration
$(call inherit-product, device/google/raviole/aosp_raven.mk)
$(call inherit-product, device/google/gs101/lineage_common.mk)

include device/google/raviole/raven/device-lineage.mk

# Device identifier. This must come after all inclusions
PRODUCT_BRAND := google
PRODUCT_MODEL := Pixel 6 Pro
PRODUCT_NAME := lineage_raven

# Crdroid Extra Stuffs
TARGET_SUPPORTS_QUICK_TAP := true
TARGET_IS_PIXEL := true
WITH_GAPPS := true
TARGET_HAS_UDFPS := true
TARGET_BOOT_ANIMATION_RES := 1080
EXTRA_UDFPS_ANIMATIONS := true

# Use Scudo instead of Jemalloc
PRODUCT_USE_SCUDO := true

PRODUCT_BUILD_PROP_OVERRIDES += \
    TARGET_PRODUCT=raven \
    PRIVATE_BUILD_DESC="raven-user 14 AP1A.240505.004 11583682 release-keys"

BUILD_FINGERPRINT := google/raven/raven:14/AP1A.240505.004/11583682:user/release-keys

$(call inherit-product, vendor/google/raven/raven-vendor.mk)
