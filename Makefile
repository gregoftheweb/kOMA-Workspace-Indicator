# kOMA Workspace Indicator — developer tasks.  `make setup` once, then `make check` before committing
# (the pre-commit hook runs it for you).

# Qt 6 tools; on Arch the plain names on PATH can be Qt 5 (qt5-declarative)
QT_BIN ?= /usr/lib/qt6/bin
export QT_BIN
export NPM_CONFIG_LOGLEVEL = warn
QMLLINT ?= $(QT_BIN)/qmllint
QMLTESTRUNNER ?= $(QT_BIN)/qmltestrunner
SHELL_SCRIPTS := bin/install bin/dev-reload scripts/package.sh scripts/qmlformat-check.sh .githooks/pre-commit

.PHONY: setup lint format test check package install clean

setup:  ## dev tools into node_modules, and enable the git hook
	npm install --silent --no-fund --no-audit
	git config core.hooksPath .githooks

lint:  ## every static gate
	$(QMLLINT) contents/ui/*.qml contents/ui/config/*.qml contents/config/*.qml
	scripts/qmlformat-check.sh
	npx --no-install prettier --check .
	npx --no-install shellcheck $(SHELL_SCRIPTS)
	python3 scripts/validate-metadata.py

format:  ## apply every formatter
	scripts/qmlformat-check.sh --fix
	npx --no-install prettier --write .

test:  ## QML model tests (headless)
	QT_QPA_PLATFORM=offscreen $(QMLTESTRUNNER) -input tests

check: lint test  ## what CI and the pre-commit hook run

package: check  ## dist/koma-workspace-indicator-<version>.plasmoid for the KDE Store
	scripts/package.sh

install:  ## install into this session and restart plasmashell
	bin/dev-reload

clean:
	rm -rf dist/*.plasmoid
