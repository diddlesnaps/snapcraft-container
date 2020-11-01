#!/bin/bash

systemctl="$(command -v systemctl)"

CMD="$1"
shift

if [ -z "$USE_SNAPCRAFT_CHANNEL" ]; then
    USE_SNAPCRAFT_CHANNEL=latest/stable
else
    case "$USE_SNAPCRAFT_CHANNEL" in
        stable|candidate|beta|edge)
            USE_SNAPCRAFT_CHANNEL="latest/$USE_SNAPCRAFT_CHANNEL"
            ;;
    esac
fi

cat > /usr/local/bin/docker_commandline.sh <<EOF
#!/bin/bash -e
$(export)
declare -x PATH="/snap/bin:/usr/bin:/bin:/usr/sbin:/sbin"
exec "$CMD" $@
EOF
chmod +x /usr/local/bin/docker_commandline.sh

cat > /etc/systemd/system/docker-exec.service <<EOF
[Unit]
Description=Docker commandline
Wants=snapd.seeded.service
After=snapd.service snapd.socket snapd.seeded.service

[Service]
ExecStartPre=/bin/rm -f /.dockerenv /run/.containerenv
ExecStartPre=/usr/bin/snap install snapcraft --classic --channel $USE_SNAPCRAFT_CHANNEL
ExecStart=/usr/local/bin/docker_commandline.sh
ExecStopPost=$systemctl exit \$EXIT_STATUS
Environment="SNAPCRAFT_BUILD_ENVIRONMENT=host"
Environment="LANG=C.UTF-8"
Restart=no
Type=oneshot
StandardInput=tty
StandardOutput=tty
StandardError=tty
WorkingDirectory=$PWD

[Install]
WantedBy=default.target
EOF

"$systemctl" enable docker-exec.service
exec /lib/systemd/systemd
