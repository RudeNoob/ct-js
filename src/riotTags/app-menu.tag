app-menu
    .app-menu-aGrid
        .app-menu-aSection
            h1 {voc.projectHeading}
            ul.aMenu
                li(onclick="{this.saveProject}")
                    svg.feather
                        use(xlink:href="data/icons.svg#save")
                    span {vocGlob.common.save}
                li(onclick="{}")
                    svg.feather
                        use(xlink:href="data/icons.svg#")
                    span {voc.openIncludeFolder}
                li(onclick="{}")
                    svg.feather
                        use(xlink:href="data/icons.svg#")
                    span {voc.zipProject}
            ul.aMenu
                li(onclick="{openProject}")
                    svg.feather
                        use(xlink:href="data/icons.svg#folder")
                    span {voc.openProject}
                li(onclick="{openExample}")
                    svg.feather
                        use(xlink:href="data/icons.svg#folder")
                    span {voc.openExample}

        .app-menu-aSection
            h1 {voc.latestHeading}
            ul.aMenu
                li(each="{project in latestProjects}" onclick="{() => loadLatestProject(project)}")

        .app-menu-aSection
            h1 {voc.deployHeading}
            ul.aMenu
                li(onclick="{}")
                    svg.feather
                        use(xlink:href="data/icons.svg#")
                    span {voc.openProject}
                li(onclick="{}")
                    svg.feather
                        use(xlink:href="data/icons.svg#")
                    span {voc.openExample}

        .app-menu-aSection
            h1 {voc.troubleshootingHeading}
            ul.aMenu
                li(onclick="{toggleDevTools}")
                    svg.feather
                        use(xlink:href="data/icons.svg#terminal")
                    span {voc.toggleDevTools}
                li(onclick="{copySystemInfo}")
                    svg.feather
                        use(xlink:href="data/icons.svg#file-text")
                    span {voc.copySystemInfo}
                li(onclick="{() => nw.Shell.openExternal('https://discord.gg/3f7TsRC'))}")
                    svg.icon
                        use(xlink:href="data/icons.svg#discord")
                    span {voc.visitDiscordForGamedevSupport}
                li(onclick="{() => nw.Shell.openExternal('https://github.com/ct-js/ct-js/issues/new/choose'))}")
                    svg.icon
                        use(xlink:href="data/icons.svg#github")
                    span {voc.postAnIssue}

        .app-menu-aSection
            h1 {voc.metaHeading}
            ul.aMenu
                li(onclick="{() => nw.Shell.openExternal('https://github.com/ct-js/ct-js')}")
                    svg.feather
                        use(xlink:href="data/icons.svg#code")
                    span {voc.contribute}
                li(onclick="{() => nw.Shell.openExternal('https://www.patreon.com/comigo')}")
                    svg.feather
                        use(xlink:href="data/icons.svg#heart")
                    span {voc.donate}
                li(onclick="{() => nw.Shell.openExternal('https://ctjs.rocks/')}")
                    svg.feather
                        use(xlink:href="data/icons.svg#")
                    span {voc.ctsite}
                li(onclick="{showLicense}")
                    svg.feather
                        use(xlink:href="data/icons.svg#")
                    span {voc.ctsite}

        .app-menu-aSection.taller
            h1 {voc.settingsHeading}
            ul.aMenu
                li(onclick="{toggleDenseCode}")
                    svg.feather
                        use(xlink:href="data/icons.svg#{localStorage.codeDense === 'on' ? 'check-square' : 'square'}")
                    span {voc.codeDense}
                li(onclick="{toggleLigatures}")
                    svg.feather
                        use(xlink:href="data/icons.svg#{localStorage.codeLigatures === 'off' ? 'square' : 'check-square'}")
                    span {voc.codeLigatures}
                li(onclick="{toggleSounds}")
                    svg.feather
                        use(xlink:href="data/icons.svg#{localStorage.disableSounds === 'off' ? 'check-square' : 'square'}")
                    span {voc.disableSounds}
                li(onclick="{zoomIn}")
                    svg.feather
                        use(xlink:href="data/icons.svg#zoom-in")
                    span {voc.zoomIn}
                li(onclick="{zoomOut}")
                    svg.feather
                        use(xlink:href="data/icons.svg#zoom-out")
                    span {voc.zoomOut}
    script.
        this.namespace = 'appMenu';
        this.mixin(window.riotVoc);

        this.refreshLatestProjects = function refreshLatestProjects() {
            if (('lastProjects' in localStorage) &&
                (localStorage.lastProjects !== '')) {
                this.latestProjects = localStorage.lastProjects.split(';');
            } else {
                this.latestProjects = [];
            }
        };
        this.refreshLatestProjects();

        this.loadLatestProject = projPath => {
            alertify.confirm(window.languageJSON.common.reallyexit, e => {
                if (e) {
                    window.signals.trigger('resetAll');
                    window.loadProject(project);
                }
            });
        };

        this.saveProject = async () => {
            // TODO: ????
        };

        this.copySystemInfo = () => {
            const os = require('os'),
                    path = require('path');
            const packaged = path.basename(process.execPath, path.extname(process.execPath)) !== 'nw';
            const report = `Ct.js v${process.versions.ctjs} 😽 ${packaged ? '(packaged)' : '(runs from sources)'}\n\n` +
                    `NW.JS v${process.versions.nw}\n` +
                    `Chromium v${process.versions.chromium}\n` +
                    `Node.js v${process.versions.node}\n` +
                    `Pixi.js v${PIXI.VERSION}\n\n` +
                    `OS ${process.platform} ${process.arch} // ${os.type()} ${os.release()}`;
            nw.Clipboard.get().set(report, 'text');
        };

        this.toggleDevTools = () => {
            const win = nw.Window.get();
            win.showDevTools();
        };

        this.openIcons = () => {
            this.parent.tab = 'icons';
            this.parent.update();
        };

        this.openProject = () => {
            alertify.confirm(window.languageJSON.common.reallyexit, () => {
                window.showOpenDialog({
                    defaultPath: require('./data/node_requires/resources/projects').getDefaultProjectDir(),
                    title: window.languageJSON.menu.openProject,
                    filter: '.ict'
                })
                .then(projFile => {
                    if (!projFile) {
                        return;
                    }
                    window.signals.trigger('resetAll');
                    window.loadProject(projFile);
                });
            });
        };
        this.openExample = () => {
            alertify.confirm(window.languageJSON.common.reallyexit, () => {
                window.showOpenDialog({
                    defaultPath: require('./data/node_requires/resources/projects').getExamplesDir(),
                    title: window.languageJSON.menu.openProject,
                    filter: '.ict'
                })
                .then(projFile => {
                    if (!projFile) {
                        return;
                    }
                    window.signals.trigger('resetAll');
                    window.loadProject(projFile);
                });
            });
        };

        this.showLicense = () => {
            this.showLicense = true;
            this.update();
        };

        this.toggleSounds = () => {
            localStorage.disableSounds = (localStorage.disableSounds || 'off') === 'off' ? 'on' : 'off';
        };

        this.toggleLigatures = () => {
            localStorage.codeLigatures = localStorage.codeLigatures === 'off' ? 'on' : 'off';
            window.signals.trigger('codeFontUpdated');
        };
        this.toggleDenseCode = () => {
            localStorage.codeDense = localStorage.codeDense === 'off' ? 'on' : 'off';
            window.signals.trigger('codeFontUpdated');
        };

        this.zoomIn = () => {
            const win = nw.Window.get();
            let zoom = win.zoomLevel + 0.5;
            if (Number.isNaN(zoom) || !zoom || !Number.isFinite(zoom)) {
                zoom = 0;
            } else if (zoom > 5) {
                zoom = 5;
            }
            win.zoomLevel = zoom;

            localStorage.editorZooming = zoom;
        };
        this.zoomOut = () => {
            const win = nw.Window.get();
            let zoom = win.zoomLevel - 0.5;
            if (Number.isNaN(zoom) || !zoom || !Number.isFinite(zoom)) {
                zoom = 0;
            } else if (zoom < -3) {
                zoom = -3;
            }
            win.zoomLevel = zoom;

            localStorage.editorZooming = zoom;
        };