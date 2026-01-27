# P.E.T.E.R.
Professional Environment for Technically Efficient Reimaging

The documentation (a TiddlyWiki) is part of this repository and you can show it in your browser by [clicking here](https://rawcdn.githack.com/derpcfreak/P.E.T.E.R./c71e973e020197aab09becb02fc9748200a7dfc3/docs/P.E.T.E.R.html). The source of the docs is stored in [docs](docs).

**P.E.T.E.R.** will do a fully automated install of Windows 11 using Linux:

- Secure Boot
- partition target disk
- download drivers from Microsoft Catalog and cache them
- inject drivers to Windows installation
- fix Windows boot loaders if UEFI already has new MS keys

Below is a visualization of the process.

<img width="800" src="docs/installation-process.drawio.png">

The host where **P.E.T.E.R.** is running in principal looks like this:

