# /data

The file `data.tar.gz` contains everything needed in the `/data` folder on the host except `tuxfiles/ubuntu-24.04.2-live-server-amd64.iso` and `winfiles/0000-cloud-init/Win11_25H2_English_x64.iso`.

You have to download `ubuntu-24.04.2-live-server-amd64.iso` from the [old releases](https://old-releases.ubuntu.com/releases/24.04/ubuntu-24.04.2-live-server-amd64.iso) page of Ubuntu.
You have to download `Win11_25H2_English_x64.iso` by yourself from [Microsofts Windows Download Page](https://www.microsoft.com/en-us/software-download/windows11) or provide your own file.

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
