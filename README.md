# P.E.T.E.R. Professional Environment for Technically Efficient Reimaging


<table style="border-collapse: collapse; width: 100%;">
  <thead>
    <tr>
      <th style="text-align: left; vertical-align: top; border: 1px solid #ccc; padding: 2px;">
        <b>FUNCTION</b>
      </th>
      <th style="text-align: left; vertical-align: top; border: 1px solid #ccc; padding: 2px;"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td valign="top">
        <b>P.E.T.E.R.</b> will do a fully automated install of Win 11 using <b>Linux</b> in under 20 minutes:<br><br>- Secure Boot<br>- partition target disk<br>- download drivers from Microsoft Catalog and cache them<br>- inject drivers<br>- fix Win boot loaders if UEFI already has new MS keys
      </td>
      <td valign="top">
        <img width="500" src="docs/peter-logo-inkscape.png">
      </td>
    </tr>
  </tbody>
</table>

The [documentation](https://rawcdn.githack.com/derpcfreak/P.E.T.E.R./c71e973e020197aab09becb02fc9748200a7dfc3/docs/P.E.T.E.R.html) (a TiddlyWiki) is part of this repository and you can show/use it directly in your browser by [clicking here](https://rawcdn.githack.com/derpcfreak/P.E.T.E.R./c71e973e020197aab09becb02fc9748200a7dfc3/docs/P.E.T.E.R.html).<br>
The source of the docs is stored in [docs](docs).

**Below is a visualization of the pxe setup process:**

<img width="800" src="docs/installation-process.drawio.png">

The host where **P.E.T.E.R.** is running in principal looks like this,  a Linux host running AlmaLinux where the entire PXE-Boot-System runs inside a **systemd-nspawn container**.

<img width="800" src="docs/01-systemd-nspawn-container-running.png">

