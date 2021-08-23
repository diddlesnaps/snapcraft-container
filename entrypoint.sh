#!/bin/bash

systemctl="$(command -v systemctl)"

CMD="$1"
shift
args=""
if [ $# -gt 0 ]; then
    args="$(printf "%q " "$@")"
fi

case "$CMD" in
    snapcraft|/snap/bin/snapcraft)
        CMD="snap run snapcraft"
        ;;
esac

if [ -z "$USE_SNAPCRAFT_CHANNEL" ]; then
    . /etc/lsb-release
    case "$DISTRIB_CODENAME" in
        xenial)
            # core/xenial disabled in snapcraft 5+.
            USE_SNAPCRAFT_CHANNEL="4.x/stable"
            ;;
        *)
            USE_SNAPCRAFT_CHANNEL="latest/stable"
            ;;
    esac
else
    case "$USE_SNAPCRAFT_CHANNEL" in
        stable|candidate|beta|edge)
            USE_SNAPCRAFT_CHANNEL="latest/$USE_SNAPCRAFT_CHANNEL"
            ;;
    esac
fi

cat > /usr/local/bin/docker_commandline.sh <<EOF
#!/bin/bash
$(export)
declare -x PATH="/snap/bin:/usr/bin:/bin:/usr/sbin:/sbin"
echo "Executing: '$CMD $args'"
$CMD $args
/bin/systemctl exit $?
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
