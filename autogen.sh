#!/bin/bash

[ -z "${datadir}" ] && datadir=/usr/share/roundcubemail/

if [ ! -x "$(which lessc 2>/dev/null)" ]; then
    echo "No lessc available. Exiting."
    exit 1
fi

find \
    ${datadir}/skins/elastic/ \
    ${datadir}/public_html/assets/skins/elastic/ \
    ${datadir}/plugins/libkolab/skins/elastic/ \
    ${datadir}/public_html/assets/plugins/libkolab/skins/elastic/ \
    -type f | sort | while read file; do
    target_dir=$(dirname ${file} | sed -e "s|${datadir}|.|g" -e 's|./public_html/assets/|./|g' -e 's|./public_html/assets/plugins/libkolab/|./|g' -e 's/elastic/base4kids/g')
    file_name=$(basename ${file})
    if [ ! -d ${target_dir} ]; then
        mkdir -p ${target_dir}
    fi
    cp -av ${file} ${target_dir}
done

sed -i -e 's/"elastic"/"base4kids"/g' \
    $(find skins/base4kids/ plugins/libkolab/skins/base4kids/ -type f)

find base4kids/ -type f | sort | while read file; do
    target_dir="./skins/$(dirname ${file})"
    file_name=$(basename ${file})
    if [ ! -d ${target_dir} ]; then
        mkdir -p ${target_dir}
    fi
    cp -av ${file} ${target_dir}
done

sed -i -e 's/"elastic"/"base4kids"/g' plugins/libkolab/skins/base4kids/libkolab.less

# Compile and compress the CSS
for file in `find . -type f -name "styles.less" -o -name "print.less" -o -name "embed.less" -o -name "libkolab.less"`; do
    lessc --relative-urls ${file} > $(dirname ${file})/$(basename ${file} .less).css

    sed -i \
        -e "s|../../../skins/base4kids/images/contactpic.png|../../../../skins/base4kids/images/contactpic.png|" \
        -e "s|../../../skins/base4kids/images/watermark.jpg|../../../../skins/base4kids/images/watermark.jpg|" \
        $(dirname ${file})/$(basename ${file} .less).css

    cat $(dirname ${file})/$(basename ${file} .less).css
done

for orig_dir in "skins/base4kids/" "plugins/libkolab/skins/base4kids/"; do
    asset_dir="public_html/assets/${orig_dir}"

    # Compress the CSS
    for file in `find ${orig_dir} -type f -name "*.css"`; do
        asset_loc=$(dirname $(echo ${file} | sed -e "s|${orig_dir}|${asset_dir}|g"))
        mkdir -p ${asset_loc}
        cat ${file} | python-cssmin > ${asset_loc}/$(basename ${file}) && \
            rm -rf ${file} || \
            mv -v ${file} ${asset_loc}/$(basename ${file})
    done || :

    # Compress the JS, but not the already minified
    for file in `find ${orig_dir} -type f -name "*.js" ! -name "*.min.js"`; do
        asset_loc=$(dirname $(echo ${file} | sed -e "s|${orig_dir}|${asset_dir}|g"))
        mkdir -p ${asset_loc}
        uglifyjs ${file} > ${asset_loc}/$(basename ${file}) && \
            rm -rf ${file} || \
            mv -v ${file} ${asset_loc}/$(basename ${file})
    done || :

    # The already minified JS can just be copied over to the assets location
    for file in `find ${orig_dir} -type f -name "*.min.js"`; do
        asset_loc=$(dirname $(echo ${file} | sed -e "s|${orig_dir}|${asset_dir}|g"))
        mkdir -p ${asset_loc}
        mv -v ${file} ${asset_loc}/$(basename ${file})
    done || :

    # Other assets
    for file in $(find ${orig_dir} -type f \
            -name "*.eot" -o \
            -name "*.gif" -o \
            -name "*.ico" -o \
            -name "*.jpg" -o \
            -name "*.mp3" -o \
            -name "*.png" -o \
            -name "*.svg" -o \
            -name "*.swf" -o \
            -name "*.tif" -o \
            -name "*.ttf" -o \
            -name "*.woff" -o \
            -name "*.woff2"
        ); do
        asset_loc=$(dirname $(echo ${file} | sed -e "s|${orig_dir}|${asset_dir}|g"))
        mkdir -p ${asset_loc}
        mv -vf ${file} ${asset_loc}/$(basename $file)
    done || :

    # Purge empty directories
    find ${orig_dir} -type d -empty -delete || :
done
