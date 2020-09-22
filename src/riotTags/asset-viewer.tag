asset-viewer
    .flexfix
        .flexrow.flexfix-header
            .asset-viewer-Breadcrumbs.Breadcrumbs
                .flexrow
                    h1(onclick="{() => navigateTo(assetsRoot)}") {voc.assetsFolder}
                    virtual(each="{crumb in pathToBreadcrumbs(currentSubfolder)}")
                        svg.feather
                            use(xlink:href="data/icons.svg#chevron-right")
                        h1(onclick="{() => navigateTo(crumb.path)}") {crumb.name}
                    svg.featheract(onclick="{navigateUp}")
                        use(xlink:href="data/icons.svg#chevron-up")
            .filler
            button
                svg.featheract(onclick="{openCreateFolderDialog}")
                    use(xlink:href="data/icons.svg#folder-plus")
                    span {voc.createFolder}
            button
                svg.featheract(onclick="{openCreateAssetDialog}")
                    use(xlink:href="data/icons.svg#plus")
                    span {voc.createAsset}
        .flexfix-body.asset-viewer-Items
            .aCard(
                if="{!searchResults}"
                each="{asset in currentItems}"
                oncontextmenu="{opts.contextmenu(asset)}"
                onlong-press="{opts.contextmenu(asset)}"
                onclick="{opts.click(asset)}"
                class="{selected: selectedItems.indexOf(asset) !== -1}"
                no-reorder
            )
                img.anAssetImage(if="{parent.opts.thumbnails}" src="{parent.opts.thumbnails(asset)}")
                span.anAssetName {parent.opts.names? parent.opts.names(asset) : asset.name}
                span.anAssetDate(if="{asset.lastmod}") {niceTime(asset.lastmod)}
        .flexfix-footer.flexrow
            .filler
            button.inline.square(onclick="{switchLayout}")
                svg.feather
                    use(xlink:href="data/icons.svg#{localStorage[opts.namespace? (opts.namespace+'Layout') : 'defaultAssetLayout'] === 'list'? 'grid' : 'list'}")
            button.inline.square(
                onclick="{switchSort('date')}"
                class="{selected: sort === 'date' && !searchResults}"
            )
                svg.feather
                    use(xlink:href="data/icons.svg#clock")
            button.inline.square(
                onclick="{switchSort('name')}"
                class="{selected: sort === 'name' && !searchResults}"
            )
                svg.feather
                    use(xlink:href="data/icons.svg#sort-alphabetically")
            .aSearchWrap
                input.inline(type="text" onkeyup="{fuseSearch}")
                svg.feather
                    use(xlink:href="data/icons.svg#search")

    script.
        const path = require('path'),
              fs = require('fs-extra');
        const assetsRoot = path.join(this.opts.root, 'assets');
        this.assetsRoot = assetsRoot;

        this.namespace = 'assetViewer';
        this.mixin(window.riotVoc);

        this.currentSubfolder = assetsRoot;
        this.currentItems = [];
        this.selectedItems = [];

        /**
         * Returns `true` if path1 is inside path2
         */
        const isInside = (path1, path2) => path.relative(path2, path1).indexOf('..') !== 0;
        /**
         * Returns `true` if path1 is inside project's `assets` directory.
         */
        const isInAssets = path1 => isInside(path1, assetsRoot);

        /**
         * Gets a path and creates an array of items ready to be displayed in UI
         */
        this.pathToBreadcrumbs = path1 => {
            const breadcrumbs = [/*{ // The first item is in riot markup already
                name: this.voc.assetsFolder,
                path: assetsRoot
            }*/];
            const pathPieces = path.normalize(path.relative(assetsRoot, path1))
                .split(path.delimiter);
            let accumulatedPath = assetsRoot;
            for (let i = 0; i < pathPieces.length; i++) {
                accumulatedPath = path.join(accumulatedPath, pathPieces[i]);
                breadcrumbs.push({
                    name: pathPieces[i],
                    path: accumulatedPath
                });
            }
        };
            .map(piece );

        this.navigateTo = async path1 => {
            try {
                if (!isInAssets(path1)) {
                    throw new Error(`Path ${path1} is not inside the project's content directory.`)
                }
                const stat = await fs.lstat(path1);
                if (!stat.isDirectory()) {
                    throw new Error(`Path ${path1} is not a directory.`)
                }
            } catch (e) {
                console.error(`[asset-viewer] Attempt to navigate to an invalid path ${path1}.`, e);
                return;
            }
            this.currentSubfolder = path1;
            this.rescanFolder();
        };
        this.navigateBy = subpath => this.navigateTo(path.join(this.currentSubfolder, currentSubfolder));
        this.navigateUp = () => this.navigateTo(path.joing(this.currentSubfolder, '..'));

        this.rescanFolder = async () {
            this.selectedItems = [];
            this.update();
        };