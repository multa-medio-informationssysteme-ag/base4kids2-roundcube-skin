Roundcube Webmail Skin "Base4Kids 2 Elastic"
============================================

This skin package contains modifications of the Roundcube's Elastic skin.
It can be used, modified and redistributed according to
the terms described in the LICENSE section.

For information about building or modifying Roundcube skins please visit
https://github.com/roundcube/roundcubemail/wiki/Skins


LICENSE
-------

The contents of this folder can be redistributed and/or modified
under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.


INSTALLATION
------------

All styles are written using LESS syntax. Thus it needs to be compiled
using the `lessc` command line tool. This comes with the `nodejs-less`
RPM package which depends on nodejs.

First create a skin folder in the Roundcube skins directory as a copy
of the Elastic skin:

```
    $ cp -r roundcubemail/skins/elastic roundcubemail/skins/base4kids
    $ cp -r roundcubemail-skin-elastic/kolab/* roundcubemail/skins/base4kids
```

Then you can compile css of the skin in a usual way:

```
    $ cd roundcubemail/skins/base4kids
    $ lessc -x styles/styles.less > styles/styles.css
    $ lessc -x styles/print.less > styles/print.css
    $ lessc -x styles/embed.less > styles/embed.css
```

Css for external plugins need to be rebuild too, e.g. Kolab plugins.

```
    $ cd roundcubemail-plugins-kolab/plugins/libkolab
    $ cp -r skins/elastic skins/base4kids
    $ sed -i 's/"elastic"/"base4kids"/g' skins/base4kids/libkolab.less
    $ lessc --relative-urls -x skins/base4kids/libkolab.less > skins/base4kids/styles.css
```

References to image files from the included CSS files can be appended
with cache-buster marks to avoid browser caching issues after updating.

Run `bin/updatecss.sh --dir skins/base4kids` before packaging the skin
or after installing it on the destination system.
