#!/bin/bash

BASE_URL="http://distfiles.gentoo.org/releases/amd64/autobuilds/"

EMERGE_BASE_PACKAGES="acpid dmidecode syslog-ng cronie dhcpcd mlocate xfsprogs dosfstools grub sudo postfix vim gentoo-sources linux-firmware parted portage-utils gentoolkit bash-completion gentoo-bashcomp eix tmux app-misc/screen dev-vcs/git net-misc/curl usbutils pciutils logrotate gptfdisk sys-block/gpart openssh qemu-guest-agent ntp app-admin/salt sysstat"


if [ -z "${ISO}" -o ! -f "dl/${ISO}" ];then
    OUTPUT=$(curl "${BASE_URL}latest-install-amd64-minimal.txt" 2> /dev/null)
    CURRENT=$(echo "${OUTPUT}" | sed -e 's/#.*$//' -e '/^$/d' | cut -d ' ' -f1)
    ISO=$(echo "${CURRENT}" | cut -d '/' -f2)

    if [ -f "dl/${ISO}" ];then
        :
        echo "latest iso ${ISO} already downloaded"
    else
        :
        echo "downloading current iso ${ISO}"
        rm dl/*.iso 2> /dev/null
        curl -o "dl/${ISO}" "${BASE_URL}${CURRENT}";
    fi
fi


if [ -z "${STAGE}" -o ! -f "dl/${STAGE}" ];then
    OUTPUT=$(curl "${BASE_URL}latest-stage3-amd64.txt" 2> /dev/null)
    CURRENT=$(echo "${OUTPUT}" | sed -e 's/#.*$//' -e '/^$/d' | cut -d ' ' -f1)
    STAGE=$(echo "${CURRENT}" | cut -d '/' -f2)

    if [ -f "dl/${STAGE}" ];then
        :
        echo "latest stage ${STAGE} already downloaded"
    else
        :
        echo "downloading current stage ${STAGE}"
        rm dl/*stage3*.bz2 2> /dev/null
        curl -o "dl/${STAGE}" "${BASE_URL}${CURRENT}";
    fi
fi


if [ -z "${PORTAGE}" ];then
    PORTAGE="portage-$(date --date yesterday +%Y%m%d).tar.bz2"

    if [ -f "dl/${PORTAGE}" ];then
        :
        echo "latest portage ${PORTAGE} already downloaded"
    else
        :
        echo "downloading current portage ${PORTAGE}"
        rm dl/*portage*.bz2 2> /dev/null
        curl -o "dl/${PORTAGE}" "http://distfiles.gentoo.org/releases/snapshots/current/${PORTAGE}";
    fi
fi

rm builder/builder.cfg 2> /dev/null
echo "# autogenerated by config.sh" >> builder/builder.cfg
echo "KERNEL_CONFIGURE=\"${KERNEL_CONFIGURE}\"" >> builder/builder.cfg
echo "KERNEL_MAKE_OPTS=\"${KERNEL_MAKE_OPTS}\"" >> builder/builder.cfg
echo "EMERGE_BASE_PACKAGES=\"${EMERGE_BASE_PACKAGES}\"" >> builder/builder.cfg
echo "EMERGE_EXTRA_PACKAGES=\"${EMERGE_EXTRA_PACKAGES}\"" >> builder/builder.cfg
echo "REV=\"$(git rev-parse --verify --short HEAD)\"" >> builder/builder.cfg
