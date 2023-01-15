#!/usr/bin/env bash
if [ ! -d 'dependencies' ]; then
    mkdir 'dependencies'
    pushd 'dependencies'
    git clone 'https://github.com/ycm-core/YouCompleteMe'
    pushd 'YouCompleteMe'
    git submodule update --init --recursive
    ./install.py --ts-completer
    popd
    popd
fi

cp input.ts actual.ts
vim -n -u NONE -S test.vim actual.ts
diff expected.ts actual.ts

