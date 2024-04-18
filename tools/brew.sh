#!/bin/sh

TAP=jolelievre/homebrew-repo
LOCAL_TAP_PATH=$(brew --repository)/Library/Taps/$TAP

function clean_local_tap() {
    echo "Cleaning local path $LOCAL_TAP_PATH"
    rm -fR $LOCAL_TAP_PATH
}

function init_local_tap() {
    if test -d $LOCAL_TAP_PATH; then
        echo "Local tap $LOCAL_TAP_PATH already initialised"
        return
    fi

    echo "Install local tap $TAP"
    brew tap $TAP
    if test $? == 0; then
        echo "Tab successfully cloned"
    else
        # Go to TAPS folder as the repository will be created and cloned at the same time
        pushd $(brew --repository)/Library/Taps/
        gh auth login
        gh repo create $TAP
        popd
    fi
    
    if test -f $LOCAL_TAP_PATH/README.md; then
        echo "Tap repository seems already initialised"
        return
    fi

    echo "Create new repository tap"
    brew tap-new $TAP

    # Set upstream to main branch
    pushd $LOCAL_TAP_PATH
    git branch --unset-upstream
    git add .
    git commit -m "Initialized with template files"
    git remote -v
    git push origin main -u
    popd
}

# install_old_brew_package icu4c 64.2
function install_old_brew_package() {
    local package_name=$1
    local package_version=$2

    if test -d "/opt/homebrew/opt/$package_name@$package_version"; then
        echo "Seems like $package_name version $package_version is already installed"
        return
    fi

    init_local_tap
    echo "Extract $package_name version $package_version to $TAP"
    brew extract --version=$package_version $package_name $TAP

    local_formula="$TAP/$package_name@$package_version"
    echo "Install formula $local_formula"
    brew install $local_formula
}

# get_package_commit_version icu4c 64.2
function get_package_commit_version() {
    local package_name=$1
    local package_version=$2

    pushd $(brew --prefix)/Homebrew/Library/Taps/homebrew/homebrew-core/Formula
    local version_commit=`git --no-pager log -n 1 --grep $package_version --format="%H" --follow $package_name.rb`

    echo $version_commit

    popd
}
