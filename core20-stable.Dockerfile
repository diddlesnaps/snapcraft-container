FROM ubuntu:focal

# Set the proper environment.
ENV DEBIAN_FRONTEND=noninteractive \
      container=docker \
      init=/lib/systemd/systemd

COPY unitfiles/docker-commandline.service /etc/systemd/system/

RUN apt-get update -qq && \
      apt-get dist-upgrade --yes && \
      apt-get install --yes -qq --no-install-recommends \
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
# remove systemd 'wants' triggers
	find \
		/etc/systemd/system/*.wants/ \
		/lib/systemd/system/multi-user.target.wants/ \
		/lib/systemd/system/local-fs.target.wants/ \
		/lib/systemd/system/sockets.target.wants/*initctl* \
		! -type d \
		-delete && \
# remove everything except tmpfiles setup in sysinit target
	find \
		/lib/systemd/system/sysinit.target.wants \
		! -type d \
		! -name '*systemd-tmpfiles-setup*' \
		-delete && \
# remove UTMP updater service
	find \
		/lib/systemd \
		-name systemd-update-utmp-runlevel.service \
		-delete && \
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
      systemctl enable snapd.socket && \
      systemctl enable docker-commandline

COPY entrypoint.py /bin/

VOLUME ["/run", "/run/lock"]
STOPSIGNAL SIGRTMIN+3

ENTRYPOINT ["/bin/entrypoint.py"]

CMD ["snap", "run", "snapcraft"]
