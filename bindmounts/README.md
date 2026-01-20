# /data

The file `data.tar.gz` contains everything needed in the `/data` folder on the host except `tuxfiles/ubuntu-24.04.2-live-server-amd64.iso` and `winfiles/0000-cloud-init/Win11_25H2_English_x64.iso`.

You have to download `ubuntu-24.04.2-live-server-amd64.iso` and `Win11_25H2_English_x64.iso` by yourself and place them in the following location on the host:

```
/data/tuxfiles/ubuntu-24.04.2-live-server-amd64.iso
/data//winfiles/0000-cloud-init/Win11_25H2_English_x64.iso
```

After that create/update this 2 symbolic links:

```
/data/tuxfiles/ubuntu.iso -> ubuntu-24.04.2-live-server-amd64.iso
/data/winfiles/0000-cloud-init/windows.iso -> Win11_25H2_English_x64.iso
```

## Note:

To recreate `data.tar.gz` for this repo use the following command in the `/data` folder on the host

```bash
cd /data
tar --exclude=win2samba/* --exclude=tuxfiles/ubuntu-24.04.2-live-server-amd64.iso --exclude=winfiles/0000-cloud-init/Win11_25H2_English_x64.iso -czvf data.tar.gz *
```
