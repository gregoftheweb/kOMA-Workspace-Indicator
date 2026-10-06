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

### Model architecture (Chet)

The indicator stays in QML and uses KDE's existing native models. Each desktop
has a `TasksModel` filtered by desktop and current activity; KDE shares its
underlying window source across these models. Two native `KSortFilterProxyModel`
filters retain only window tasks that are not marked `SkipPager`. This adds the
standard `org.kde.kitemmodels` QML module as a runtime requirement.

Icons bind directly to model rows and the `decoration` role. Title updates no
longer rescan every desktop or replace icon arrays. Rows outside the icon limit
have lightweight placeholders but do not instantiate icons. Counts remain
available in every appearance mode. KDE handles sticky windows, membership
changes, hidden-window filtering, and activities. Each panel retains its own
view/proxy models; this phase introduces no custom compiled backend.

Run the model and delegate regression checks with Qt 6 (some distributions also
provide a Qt 5 `qmltestrunner` under the unqualified command name):

```sh
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
  /usr/lib/qt6/bin/qmltestrunner -input tests
/usr/lib/qt6/bin/qmllint contents/ui/*.qml tests/*.qml
```

The tests inject controlled task rows to verify filtering, delegate stability,
icon limits, and close-all index mapping. They do not simulate KWin's live
window protocol. Before releasing, verify window moves, all-desktop windows,
activity changes, desktop addition/removal, horizontal/vertical layouts, all
appearance modes, wheel/keyboard switching, and middle-click actions in a real
Plasma session with two panel instances. A synthetic title storm passing does
not prove that the previously observed Plasma CPU problem is resolved.
