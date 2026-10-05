# kOMA Workspace Indicator

A virtual desktop indicator for KDE Plasma 6, maintained as a diverging derivative of **Desktop Switcher 1.0 by Sm1Tee**.

Desktop Switcher provides the original widget, desktop switching, appearance controls, application icons, animations, and support page. The kOMA changes add a plain separator appearance, workspace numbers alongside application icons, compact sizing, English defaults, and icon refreshes when windows move between desktops.

## Attribution and license

The original author is **Sm1Tee**. kOMA modifications are maintained by **Greg / Columbia Foundry**. This is a modified version, not an official release or endorsement by the original author.

The entire derived widget remains **GPL-2.0-or-later**, as declared in the original Desktop Switcher 1.0 metadata. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md). Original author credit and the original author's support link are retained.

We could not locate an upstream source repository, and the downloaded widget's metadata contains no repository URL. This is an independently maintained repository derived from that widget, with its original credit and license retained.

## Installation

Requires KDE Plasma 6. From this directory:

```sh
kpackagetool6 --type Plasma/Applet --install .
```

Then add **kOMA Workspace Indicator** to your panel. For an existing installation, use `--upgrade` instead of `--install`.

The plugin ID remains `kde-desktop.workspaces` to preserve compatibility with existing kOMA panel configurations.

## Development

This project will continue to diverge from Desktop Switcher. Preserve upstream attribution and licensing when making changes, and document notable changes in [CHANGELOG.md](CHANGELOG.md).
