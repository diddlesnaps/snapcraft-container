These container images start systemd and execute the command line passed on invokation. The commandline is executed as an interactive systemd service unit.

You may override the entrypoint with the `--entrypoint` parameter if you need to run the container without starting systemd. Or you may drop to a shell with systemd running by setting the command to `bash`.

These container images require you to pass `--privileged`, along with `--security-opt apparmor=":docker-snapcraft:unconfined"`.

You also need to create a directory at `/sys/kernel/security/apparmor/policy/namespaces/docker-snapcraft`. This will initialise an empty AppArmor namespace. Once you've finished you can `rmdir` that same directory (it _must_ be `rmdir`, because `rm -r` and `rm -rf` won't work)

Note
----
Currently there is an issue with the combination of Core20 and running this image through qemu emulating ARMv7, such as when running on GitHub Actions. See [the bug on Launchpad.net](https://bugs.launchpad.net/qemu/+bug/1886811) for the root cause.

Running snapcraft
-----------------

Running without specifying a command will run `snapcraft` without any parameters:

```bash
sudo mkdir /sys/kernel/security/apparmor/policy/namespaces/docker-snapcraft
docker run --rm -it --privileged --security-opt apparmor=":docker-snapcraft:unconfined" -v $PWD:/data -w /data diddledan/snapcraft:core18
sudo rmdir /sys/kernel/security/apparmor/policy/namespaces/docker-snapcraft
```

To run with parameters, specify `snapcraft [...params]` when creating the container:

```bash
sudo mkdir /sys/kernel/security/apparmor/policy/namespaces/docker-snapcraft
docker run --rm -it --privileged --security-opt apparmor=":docker-snapcraft:unconfined" -v $PWD:/data -w /data diddledan/snapcraft:core18 snapcraft stage --enable-experimental-package-repositories
sudo rmdir /sys/kernel/security/apparmor/policy/namespaces/docker-snapcraft
```

Drop to a shell with systemd running
------------------------------------

```bash
sudo mkdir /sys/kernel/security/apparmor/policy/namespaces/docker-snapcraft
docker run --rm -it --privileged --security-opt apparmor=":docker-snapcraft:unconfined" -v $PWD:/data -w /data diddledan/snapcraft:core18 bash
sudo rmdir /sys/kernel/security/apparmor/policy/namespaces/docker-snapcraft
```

Drop to a shell without starting systemd
----------------------------------------

```bash
sudo mkdir /sys/kernel/security/apparmor/policy/namespaces/docker-snapcraft
docker run --rm -it --privileged --security-opt apparmor=":docker-snapcraft:unconfined" -v $PWD:/data -w /data --entrypoint bash diddledan/snapcraft:core18
sudo rmdir /sys/kernel/security/apparmor/policy/namespaces/docker-snapcraft
```
