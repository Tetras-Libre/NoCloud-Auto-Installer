
.PHONY: tarball

default:
	echo "make tarball"

tarball : initInstall.sh installMySQL.sh installNextcloud.env \
	installNextcloud.sh nextcloudAppsIntallation.sh run.sh \
	nextcloudStrongDirectoryPermissions.sh
	mkdir NoCloud-Auto-Installer
	cp -r *.sh *.env *.conf DOLIBARR_PACKAGES NoCloud-Auto-Installer
	tar cf NoCloud-Auto-Installer.tar NoCloud-Auto-Installer
	rm -r NoCloud-Auto-Installer

clean :
	@if [ -f NoCloud-Auto-Installer.tar ]; then \
		rm NoCloud-Auto-Installer.tar; fi
