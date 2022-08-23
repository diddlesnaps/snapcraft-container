ARG BASE_OS=xenial

FROM ubuntu:xenial as snapd
ENV DEBIAN_FRONTEND=noninteractive \
	LDFLAGS=-static

RUN apt-get update -qq && \
	apt-get dist-upgrade --yes && \
	apt-get install --yes -qq --no-install-recommends \
		fuse \
		gnupg \
		python3 \
		snapd \
		sudo \
		systemd \
		build-essential \
		git \
		help2man \
		zlib1g-dev \
		liblz4-dev \
		liblzma-dev \
		liblzo2-dev \
	&& \
	git clone https://github.com/plougher/squashfs-tools.git && \
	cd squashfs-tools && \
	git checkout 4.5.1 && \
	sed -Ei 's/#(XZ_SUPPORT.*)/\1/' squashfs-tools/Makefile && \
	sed -Ei 's/#(LZO_SUPPORT.*)/\1/' squashfs-tools/Makefile && \
	sed -Ei 's/#(LZ4_SUPPORT.*)/\1/' squashfs-tools/Makefile && \
	sed -Ei 's|(INSTALL_PREFIX = ).*|\1 /usr|' squashfs-tools/Makefile && \
	sed -Ei 's/\$\(INSTALL_DIR\)/$(DESTDIR)$(INSTALL_DIR)/g' squashfs-tools/Makefile && \
	cd squashfs-tools && \
	make -j$(nproc) && \
	make install && \
	mkdir -p /snap/snapd/current && \
	snap download snapd && \
	unsquashfs -f -d /snap/snapd/current snapd_*.snap && \
	cp /usr/bin/mksquashfs /snap/snapd/current/usr/bin && \
	cp /usr/bin/unsquashfs /snap/snapd/current/usr/bin && \
	mksquashfs /snap/snapd/current /snapd.snap

FROM ubuntu:${BASE_OS}

# Set the proper environment.
ENV DEBIAN_FRONTEND=noninteractive \
	container=docker \
	init=/lib/systemd/systemd

RUN apt-get update -qq && \
	apt-get dist-upgrade --yes && \
	apt-get install --yes -qq --no-install-recommends \
		build-essential \
		fuse \
		gnupg \
		python3 \
		snapd \
		sudo \
		systemd \
	&& \
	apt-get clean && \
	rm -rf /var/lib/apt/lists && \
	touch /var/lib/snapd/system-key && \
# stop udevadm from working
  dpkg-divert --local --rename --add /sbin/udevadm && \
  ln -s /bin/true /sbin/udevadm && \
# remove systemd 'wants' triggers
	rm -f \
		/etc/systemd/system/*.wants/* \
		/lib/systemd/system/local-fs.target.wants/* \
		/lib/systemd/system/multi-user.target.wants/* \
		/lib/systemd/system/sockets.target.wants/*initctl* \
		&& \
# remove everything except tmpfiles setup in sysinit target
	find \
		/lib/systemd/system/sysinit.target.wants \
		\( -type f -or -type l \) -and -not -name '*systemd-tmpfiles-setup*' \
		-delete && \
# remove UTMP updater service
	rm -f /lib/systemd/system/systemd-update-utmp-runlevel.service && \
# disable /tmp mount
	rm -vf /usr/share/systemd/tmp.mount && \
# disable most systemd console output
	echo ShowStatus=no >> /etc/systemd/system.conf && \
# disable ondemand.service
	systemctl disable ondemand.service && \
# set basic.target as default
	systemctl set-default basic.target && \
# enable the services we care about
	systemctl enable snapd.service && \
	systemctl enable snapd.socket

COPY --from=snapd /snapd.snap /snapd.snap
ADD entrypoint.sh /bin/
ADD systemd-detect-virt /usr/bin/

VOLUME ["/run", "/run/lock"]
STOPSIGNAL SIGRTMIN+3

ENTRYPOINT ["/bin/entrypoint.sh"]

CMD ["snapcraft"]
