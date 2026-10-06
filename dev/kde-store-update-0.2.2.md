# KDE Store update: 0.2.2

Upload `dist/koma-workspace-indicator-0.2.2.plasmoid` to the existing kOMA
Workspace Indicator listing. Retain the existing listing and plugin ID
`kde-desktop.workspaces`, so installed panel instances and settings are preserved.

File version: `0.2.2`

Suggested changelog:

> Improve workspace icon updates using KDE's native desktop and activity models.
> Window-title changes no longer trigger broad icon-list rebuilding. Icons update
> directly from model roles, and only the configured number of icons is loaded.
> Existing appearance options, desktop navigation, and middle-click actions remain.

Requirements: KDE Plasma 6, including the `org.kde.kitemmodels` QML module
(usually supplied by the distribution's KItemModels package).

Validation: six Qt 6 regression tests pass, including 1,000 title updates across
two views without replacing icon delegates; Qt 6 lint passes. Installed locally
in both existing panels and Plasma reload completed without Chet loading errors.
Long-duration resource usage and the complete live interaction matrix remain
unverified. Do not describe this release as a proven fix for a Plasma memory leak.

GitHub release:
https://github.com/gregoftheweb/kOMA-Workspace-Indicator/releases/tag/v0.2.2

The Store update must be performed through the listing owner's signed-in account.
Its existing public listing URL has not been recorded in this workspace.
