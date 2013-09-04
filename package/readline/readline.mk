################################################################################
#
# readline
#
################################################################################

READLINE_VERSION = 6.2
READLINE_SOURCE = readline-$(READLINE_VERSION).tar.gz
READLINE_SITE = $(BR2_GNU_MIRROR)/readline
READLINE_INSTALL_STAGING = YES
READLINE_DEPENDENCIES = ncurses
READLINE_CONF_ENV = bash_cv_func_sigsetjmp=yes
READLINE_LICENSE = GPLv3+
READLINE_LICENSE_FILES = COPYING

define READLINE_PURGE_EXAMPLES
	rm -rf $(TARGET_DIR)/usr/share/readline
endef

READLINE_POST_INSTALL_TARGET_HOOKS += READLINE_PURGE_EXAMPLES

ifneq ($(BR2_PREFER_STATIC_LIB),y)

define READLINE_INSTALL_TARGET_CMDS
	$(MAKE1) DESTDIR=$(TARGET_DIR) -C $(@D) uninstall
	$(MAKE1) DESTDIR=$(TARGET_DIR) -C $(@D) install-shared uninstall-doc
	chmod 775 $(TARGET_DIR)/usr/lib/libreadline.so.$(READLINE_VERSION) \
		$(TARGET_DIR)/usr/lib/libhistory.so.$(READLINE_VERSION)
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) \
		$(TARGET_DIR)/usr/lib/libreadline.so.$(READLINE_VERSION) \
		$(TARGET_DIR)/usr/lib/libhistory.so.$(READLINE_VERSION)
endef

endif

$(eval $(autotools-package))
