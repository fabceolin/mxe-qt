# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := glib
$(PKG)_WEBSITE  := https://gtk.org/
$(PKG)_DESCR    := GLib
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.69.0
$(PKG)_CHECKSUM := 5aa7807258e53fa2feb106987faa458a62e7a9e59b3a0b55957b6288ce67dd8a
$(PKG)_SUBDIR   := glib-$($(PKG)_VERSION)
$(PKG)_FILE     := glib-$($(PKG)_VERSION).tar.bz2
#$(PKG)_URL      := https://download.gnome.org/sources/glib/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_URL      := https://gitlab.gnome.org/GNOME/glib/-/archive/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc meson-conf dbus gettext libffi libiconv pcre zlib $(BUILD)~$(PKG) $(BUILD)~meson
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)

$(PKG)_DEPS_$(BUILD) := meson ninja gettext libffi libiconv zlib

define $(PKG)_UPDATE
    $(call MXE_GET_GH_TAGS,GNOME/glib) | \
    grep -v '\([0-9]\+\.\)\{2\}9[0-9]' | \
    $(SORT) -Vr | \
    head -1
endef

define $(PKG)_BUILD_$(BUILD)
    cd '$(SOURCE_DIR)' &&  $(PREFIX)/$(BUILD)/bin/meson --prefix='$(PREFIX)/$(TARGET)' \
                                                        --buildtype=release \
                                                        --pkg-config-path='$(PREFIX)/$(TARGET)/bin/pkgconf' \
                                                        '$(BUILD_DIR)'
    cd '$(BUILD_DIR)' && ninja
    cd '$(BUILD_DIR)' && ninja install
endef

define $(PKG)_BUILD
    # other packages expect glib-tools in $(TARGET)/bin
    rm -f  '$(PREFIX)/$(TARGET)/bin/glib-*'
    ln -sf '$(PREFIX)/$(BUILD)/bin/glib-genmarshal'        '$(PREFIX)/$(TARGET)/bin/'
    ln -sf '$(PREFIX)/$(BUILD)/bin/glib-compile-schemas'   '$(PREFIX)/$(TARGET)/bin/'
    ln -sf '$(PREFIX)/$(BUILD)/bin/glib-compile-resources' '$(PREFIX)/$(TARGET)/bin/'
    cd '$(SOURCE_DIR)' && $(TARGET)-meson '$(BUILD_DIR)' -Dforce_posix_threads=true
    cd '$(BUILD_DIR)' && ninja
    cd '$(BUILD_DIR)' && ninja install
endef
