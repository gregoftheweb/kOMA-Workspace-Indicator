# Changelog

## 0.2.3 — 2026-10-08

- Order each workspace's app icons left to right as the windows sit on screen, across all monitors (KDE's `SortWindowPositionHorizontal`), instead of alphabetically by app. Moving a window reorders its icon.
- Add the kOMA developer tooling: `make check` (qmllint, qmlformat, Prettier, ShellCheck, metadata checks, QML tests) as a pre-commit hook, `make package` for the store upload, and `make install`, which installs only the package files.

## 0.2.2 — 2026-10-06

- Replace broad task-change rescans and temporary icon arrays with KDE desktop/activity-filtered task models and native pager eligibility filters.
- Bind icons to model roles so title updates preserve delegates and icon updates affect existing delegates. Only icons within the configured limit are instantiated.
- Preserve appearance options, desktop navigation, counts, and middle-click actions; map close-all requests through the filtered models.
- Add Qt 6 model tests for title storms, icon changes, pager eligibility, insertion/removal/reordering, icon limits, two views, and close-all mapping.

## 0.2.1 — 2026-10-05

- Use English throughout the interface, including settings, support, accessibility labels, and window counts.
- Remove Russian text and the language selector.

## 0.2.0 — 2026-10-05

- Extract the existing kOMA derivative into a standalone project named kOMA Workspace Indicator.
- Preserve Sm1Tee's authorship and GPL-2.0-or-later license; include the license text and provenance notice.
- Carry forward separator indicators, workspace numbers with icons, compact sizing, English defaults, and task-model refresh handling.
- Add dated notices to modified files and prepare the standalone .plasmoid release.
