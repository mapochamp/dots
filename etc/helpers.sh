function log_error {
    local MSG=$1
    ERRORS=("${ERRORS[@]}" "- $MSG")
}

function report_errors {
    echo "====================================="
    echo "  Installation Complete: [${#ERRORS[@]} Errors]"
    echo "====================================="
    for msg in "${ERRORS[@]}"
    do
        echo $msg
    done
}

function print_program {
    INSTALLER=$1
    local tmp=${INSTALLER#"$DOTFILES_DIR/"}
    echo "# ${tmp%"/install"}"
}

function have_sudo {
    groups | grep sudo > /dev/null 2>&1
    if [ $? == 0 ]; then
        return 0
    else
        return 1
    fi
}

function have_pac {
    if which pacman-get > /dev/null; then
        return 0
    else
        return 1
    fi
}

function can_install {
    if [ have_sudo ] && [ have_pac ]; then
        return 0
    else
        return 1
    fi
}

function probe_capabilities {
    if [ ! have_sudo ]; then
        log_error "No sudo privilage"
    fi
    if [ ! have_pac ]; then
        log_error "No Pacman"
    fi
    if [ ! can_install ]; then
        log_error "Unable to install things"
    fi
}

function install_package {
    local PKG=$1
    dpkg-query -s $PKG > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        if [ can_install ]; then
            sudo pacman -S $PKG
            if [ $? -ne 0 ]; then
		sudo yay -S $PKG
            	if [ $? -ne 0 ]; then
                log_error "Failed to install package: $PKG"
		fi
            fi
        else
            log_error "Unable to install package: $PKG"
        fi
    else
        return
    fi
}

function user_install_python2_package {
    local PKG=$1
    pip2 list | grep $PKG > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        pip install --user -q $PKG
        if [ $? -ne 0 ]; then
            log_error "Failed to install python2 package: $PKG"
        fi
    else
        return
    fi
}

function user_install_python3_package {
    local PKG=$1
    pip3 list | grep $PKG > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        pip install --user -q $PKG
        if [ $? -ne 0 ]; then
            log_error "Failed to install python3 package: $PKG"
        fi
    else
        return
    fi
}

## POSIX Compliant replacement for readlink ########################
function _prepend_path_if_relative {
    case "$2" in
        /* ) printf '%s\n' "$2" ;;
         * ) printf '%s\n' "$1/$2" ;;
    esac
}

function _canonicalize_dir_path {
    (cd "$1" 2>/dev/null && pwd -P)
}

function _canonicalize_file_path {
    local dir file
    dir=$(dirname -- "$1")
    file=$(basename -- "$1")
    (cd "$dir" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$file")
}

function resolve_symlinks {
    local dir_context path
    path=$(readlink -- "$1")
    if [ $? -eq 0 ]; then
        dir_context=$(dirname -- "$1")
        resolve_symlinks "$(_prepend_path_if_relative "$dir_context" "$path")"
    else
        printf '%s\n' "$1"
    fi
}

function canonicalize_path {
    if [ -d "$1" ]; then
        _canonicalize_dir_path "$1"
    else
        _canonicalize_file_path "$1"
    fi
}

function realpath {
    canonicalize_path "$(resolve_symlinks "$1")"
}
####################################################################

function install_symlink {
    local SOURCE_FILE=$1
    local TARGET_FILE=$2
#    SOURCE_FILE=$(readlink -e $DOTFILES_DIR/$SOURCE_FILE)
    SOURCE_FILE=$(realpath $DOTFILES_DIR/$SOURCE_FILE)

    ln -sfv "$SOURCE_FILE" "$TARGET_FILE"
    if [ $? -ne 0 ]; then
        log_error "Symlink failure: $SOURCE_FILE -> $TARGET_FILE"
    fi
}

function bin_exists {
    command -v $1 > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        return 1
    else
        return 0
    fi
}

function install_ycm_depend{
	# YouCompleteMe dependencies
	install_package cmake
	install_package base-devel
	install_package python
	install_package python-flake8-black
	install_package nodejs
	install_package jdk-openjdk
	install_package jre-openjdk
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

function install_vim {
	install_ycm_depend
	python3 ~/.vim/plugged/YouCompleteMe/install.py
	
	# download & install plugins
	vim -E +PlugInstall +qall
	
	# build custom spellcheck dictionary
	vim -E +"mkspell ~/.dotfiles/vim/spell/en.utf-8.add" +qall
}
