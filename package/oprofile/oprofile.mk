################################################################################
#
# oprofile
#
################################################################################

OPROFILE_VERSION = 0.9.8
OPROFILE_SITE = http://downloads.sourceforge.net/project/oprofile/oprofile/oprofile-$(OPROFILE_VERSION)
OPROFILE_LICENSE = GPLv2+
OPROFILE_LICENSE_FILES = COPYING
OPROFILE_CONF_OPT = \
	--localstatedir=/var \
	--disable-account-check \
	--enable-gui=no \
	--with-kernel=$(STAGING_DIR)/usr \
	ac_cv_lib_popt_poptGetContext=yes
OPROFILE_AUTORECONF = YES
OPROFILE_BINARIES = utils/ophelp pp/opannotate pp/oparchive pp/opgprof
OPROFILE_BINARIES += pp/opreport opjitconv/opjitconv daemon/oprofiled
OPROFILE_BINARIES += utils/op-check-perfevents pe_profiling/operf libabi/opimport

OPROFILE_FLAT_STACKSIZE=64000

ifeq ($(BR2_i386),y)
OPROFILE_ARCH = i386
endif
ifeq ($(BR2_mipsel),y)
OPROFILE_ARCH = mips
endif
ifeq ($(BR2_powerpc),y)
OPROFILE_ARCH = ppc
endif
ifeq ($(BR2_x86_64),y)
OPROFILE_ARCH = x86-64
endif
ifeq ($(OPROFILE_ARCH),)
OPROFILE_ARCH = $(BR2_ARCH)
endif

OPROFILE_DEPENDENCIES = popt binutils host-pkgconf
ifneq ($(BR2_bfin),y)
OPROFILE_DEPENDENCIES = binutils
endif

ifeq ($(BR2_PACKAGE_LIBPFM4),y)
OPROFILE_DEPENDENCIES += libpfm4
endif

define OPROFILE_CREATE_FILES
	touch $(@D)/NEWS $(@D)/AUTHORS $(@D)/ChangeLog
endef

OPROFILE_POST_PATCH_HOOKS += OPROFILE_CREATE_FILES

define OPROFILE_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 755 $(TARGET_DIR)/usr/bin
	$(INSTALL) -d -m 755 $(TARGET_DIR)/usr/share/oprofile
	$(INSTALL) -d -m 755 $(TARGET_DIR)/usr/lib/oprofile
	if [ -d $(@D)/events/$(OPROFILE_ARCH) ]; then \
		cp -dpfr $(@D)/events/$(OPROFILE_ARCH) \
			$(TARGET_DIR)/usr/share/oprofile; \
	fi
	$(INSTALL) -m 644 $(@D)/libregex/stl.pat $(TARGET_DIR)/usr/share/oprofile
	$(INSTALL) -m 755 $(@D)/utils/opcontrol $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 755 $(addprefix $(@D)/, $(OPROFILE_BINARIES)) $(TARGET_DIR)/usr/bin
	if [ $(BR2_BINFMT_FLAT) != y ]; then \
	$(INSTALL) -m 755 $(@D)/libopagent/.libs/*.so* $(TARGET_DIR)/usr/lib/oprofile; \
	fi
endef

define OPROFILE_UNINSTALL_TARGET_CMDS
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/, $(notdir $(OPROFILE_BINARIES)))
	rm -f $(TARGET_DIR)/usr/bin/opcontrol
	rm -rf $(TARGET_DIR)/usr/share/oprofile
	rm -rf $(TARGET_DIR)/usr/lib/oprofile
endef

$(eval $(autotools-package))
