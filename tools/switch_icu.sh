#!/bin/sh

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

USERNAME=$(users)
TAP=jolelievre/homebrew-repo
LOCAL_TAP_PATH=$(brew --repository)/Library/Taps/$TAP

function init_local_tap() {
    if test -d $LOCAL_TAP_PATH; then
        echo "Local tap $LOCAL_TAP_PATH already initialised"
        return
    fi

    brew tap $TAP
    brew tap-new $TAP

    pushd $TAP_PATH
    git add .
    git commit -m "Initialized with template files"
    git remote -v
    popd
}

# reset_brew_package icu4c
function reset_brew_package() {
    brew reinstall icu4c
}

# switch_brew_package icu4c 64.2
function switch_brew_package() {
    local package_name=$1
    local package_version=$2

    init_local_tap
    brew extract --version=$package_version $package_name
    local_formula="$TAP/$package_name@$package_version"
    echo "Install formula $local_formula"
    brew install $local_formula
}

# get_package_formula_url icu4c 64.2
function get_package_formula_url() {
    local package_name=$1
    local package_version=$2

    local commit_version=`get_package_commit_version $package_name $package_version`
    echo "https://raw.githubusercontent.com/Homebrew/homebrew-core/$commit_version/Formula/$package_name.rb"
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


# create_version_branch icu4c 64.2
function create_version_branch() {
    package_name=$1
    package_version=$2

    pushd $(brew --prefix)/Homebrew/Library/Taps/homebrew/homebrew-core/Formula
    version_commit=`git --no-pager log -n 1 --grep $package_version --format="%H" --follow $package_name.rb`

    echo "Create branch for package $package_name version $package_version on commit $version_commit"
    branch_name="$package_name-$icu_version"
    git checkout -b $branch_name $version_commit

    popd
}
