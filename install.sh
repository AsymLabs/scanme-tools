#!/usr/bin/env bash

# install.sh: installs scanner system for an HP AIO type, this could be used
# to install other systems with minor modifications, ie epsom or brother for
# example.  Originally developed for older HP 1220 AIO scanner/printers used
# with a 32 Bit Arch Linux systemd machine on XFCE.  It could be used on just
# about any Gnome/systemd based OS, however, with a little work. Designed to
# integrate into the Gnome menu/desktop.

# Note that should another printer driver be used,  changes will be required
# for the array 'packages' under section 'VARIABLES'. The array contains the
# means of verifying dependencies,  and it is used by function 'check_deps'.

# Importantly, the scanner device may change, to get the correct device, do
# 'hp-check -t' and use the device beginning with the string:  'hpoj:mlc:..'
# Copy and paste the correct device in the script file:  'scanme' under the
# section 'ENVIRONMENT', for variable 'device='. See the script 'scanme' for
# more information.

# This must be run as sudo or root.  Any existing files are copied over as
# '(filename).scanmesave'.  Lastly, the installation attempts to start and
# enable the ptal server under systemctl in a sort of crude manner.  If it
# fails then manual intervention will be needed.

# Created by: G R Summers.  Copyright (C) Applied Numerics Ltd. (Asymlabs),
# Great Britain, 2014.  A warrantee is neither implied nor expressed.  Use
# at your own risk.  See LICENSE file for terms and conditions of usage.

# Version 0.21 : Last edited by G R Summers : 2014-02-10

##  ENVIRONMENT

# Arch Linux/XFCE/Systemd-based - may vary for other systems.
declare -A paths    # paths['source file']='destination path'.

# For sysinit (not systemd) comment out 'ptal.service' below.
paths['ptal.service']='/etc/systemd/system'
paths['dll.conf']='/etc/sane.d'
paths['scanme']='/usr/local/bin'
paths['scanme.desktop']='/usr/share/applications'
paths['scansh.svg']='/usr/share/pixmaps'
paths['scansh.png']='/usr/share/pixmaps'
paths['scansh-grn.svg']='/usr/share/pixmaps'
paths['scansh-grn.png']='/usr/share/pixmaps'
paths['scansh-red.svg']='/usr/share/pixmaps'
paths['scansh-red.png']='/usr/share/pixmaps'

# Link to image of choice.
readonly scanmepnglink='/usr/share/pixmaps/scanme.png'
readonly scanmepngfile='/usr/share/pixmaps/scansh-red.png'
readonly scanmesvglink='/usr/share/pixmaps/scanme.svg'
readonly scanmesvgfile='/usr/share/pixmaps/scansh-red.svg'

## DEPENDENCIES

# Note that we use 'yad' instead of 'zenity' for GUI goodness. Also Bash, sed
# and awk are/may be used.

# Dependencies:
#
#   awk           (awk)
#   sed           (sed)
#   mktemp        (mktemp)          sometimes mktemp is not available.
#   yad           (yad)             instead of Zenity,  advantageous.
#   cups          (cupstestppd)
#   sane          (scanimage)
#   hplip         (hp-check)        this is printer/scanner specific.
#   hpoj          (ptal-devid)      this is printer/scanner specific.
#   tiff2pdf      (tiff2pdf)
#   ghostscript   (gs)
#   evince        (evince)

declare -A packages
packages[awk]='awk'
packages[sed]='sed'
packages[mktemp]='mktemp'
packages[yad]='yad'
packages[cups]='cupstestppd'
packages[sane]='scanimage'
packages[hplip]='hp-check'
packages[hpoj]='ptal-devid'
packages[tiff2pdf]='tiff2pdf'
packages[ghostscript]='gs'

## FUNCTIONS

# log 'message' [die|pause] [err_code]
function log(){
local state='OK'
local code='0'
if [[ -n "$2" ]]
then
  state="$(echo "$2" | tr '[a-z]' '[A-Z]' )"
fi
if [[ -n $3 ]]
then
  code=$3
fi
case "$state" in
  'DIE')
    echo "$1 ..." 1>&2 &&
    exit $code
  ;;
  'PAUSE')
    echo "$1 ..." 1>&2
    sleep 3
    ;;
  *)
    echo "$1 ..." 1>&2
  ;;
esac
}

# trap_handler
function trap_handler(){
  echo
  log "Cannot interrupt (un)installation" pause
  echo
}

# check_sudo
function check_sudo(){
  (( $UID )) && log "Must have sudo (su) user priviledges" die 1
}

# check_deps
function check_deps(){
  for package in ${!packages[@]}
  do
    if ! hash "${packages[$package]}" &>/dev/null
    then
      log "Package '$package' is not installed" die 1
    fi
  done
}

# install_file 'target_directory' 'file-name'
function install_file(){

  local save='.scanmesave'
  local target="${1}/${2}"
  local backup="${target}${save}"

  # 1. Check target directory.
  if [[ ! -d "$1" ]]
  then
    log "Directory '$1' not found" die 1
  fi

  # 2. Check source file.
  if [[ ! -f "$2" ]]
  then
    log "File source '$2' not found" die 1
  fi

  # 3  Make backed up files.
  if [[ -f "$backup"  ]]
  then
    log "File '$backup' already exists"
  else

    # Check target file and location /etc.
    if [[ -f "$target" && "$target" == */etc* ]]
    then
      mv "$target" "$backup" &>/dev/null &&
        log "File '$backup' is created" ||
        log "File '$backup' not created" die 1
    fi
  fi

  # 4. Install files to target.
  cp "$2" "$target" &>/dev/null &&
    log "File '$2' installed to '$target'" ||
    log "File '$2' could not be installed" die 1

}

# uninstall_file 'target_directory' 'file-name'
function uninstall_file(){

  local save='.scanmesave'
  local target="${1}/${2}"
  local backup="${target}${save}"

  # 1. Check target directory.
  if [[ -d "$1" ]]
  then

    # 2. Check backup file.
    if [[ -f "$target" && -f "$backup" ]]
    then

      # A. Reinstate backed up files in /etc.
      mv "$backup" "$target" &>/dev/null &&
        log "File '$target' was uninstalled" ||
        log "File '$target' could not be uninstalled" die 1

    else

      # B. Remove installed files in /usr.
      if [[ -f "$target" && "$target" == */usr* ]]
      then
        rm -f "$target" &>/dev/null &&
          log "File '$target' was uninstalled" ||
          log "File '$target' was not uninstalled"
      else
        log "File '$target' cannot be uninstalled"
      fi

    fi

  fi

}

## MAIN

# We leave INT and QUIT open.
trap 'trap_handler' HUP TERM
check_sudo
check_deps

# Check options.
case "$1" in

  install)

    # Install files.
    for file in ${!paths[@]}
    do
      install_file "${paths[$file]}" "$file"
    done

    # Create png image links.
    if [[ ! -f "$scanmepnglink" && -f "$scanmepngfile" ]]
    then
      ln -s "$scanmepngfile" "$scanmepnglink" &>/dev/null &&
        log "Link to '$scanmepngfile' is created" ||
        log "Link to '$scanmepngfile' could not be created" die 1
    fi

    # Create png image links.
    if [[ ! -f "$scanmesvglink" && -f "$scanmesvgfile" ]]
    then
      ln -s "$scanmesvgfile" "$scanmesvglink" &>/dev/null &&
        log "Link to '$scanmesvgfile' is created" ||
        log "Link to '$scanmesvgfile' could not be created" die 1
    fi

    # Enable ptal
    if systemctl status ptal &>/dev/null
    then
      log "Service 'ptal' is already running"
    else
      systemctl stop cups &>/dev/null &&
      systemctl start ptal &>/dev/null &&
      systemctl start cups &>/dev/null &&
      systemctl enable ptal &>/dev/null &&
      log "Service 'ptal' is enabled" ||
      log "Service 'ptal' could not be enabled" die 1
    fi
  ;;
  uninstall)

    # Uninstall files.
    for file in ${!paths[@]}
    do
      uninstall_file "${paths[$file]}" "$file"
    done

    # Remove png links (they are broken now).
    if [[ -f "$scanmepnglink" ]]
    then
      unlink "$scanmepnglink" &>/dev/null &&
        log "Link '$scanmepnglink' is removed" ||
        log "Link '$scanmepnglink' could not be removed" die 1
    fi

    # Remove svg links (they are broken now).
    if [[ -f "$scanmesvglink" ]]
    then
      unlink "$scanmesvglink" &>/dev/null &&
        log "Link '$scanmesvglink' is removed" ||
        log "Link '$scanmesvglink' could not be removed" die 1
    fi

    # Disable ptal
    if systemctl status ptal &>/dev/null
    then
      log "Service 'ptal' is already running"
      systemctl stop ptal &>/dev/null &&
      systemctl disable ptal &>/dev/null &&
      log "Service 'ptal' is disabled" ||
      log "Service 'ptal' could not be disabled" die 1
    else
      log "Service ptal is not running"
      systemctl disable ptal &>/dev/null &&
      log "Service 'ptal' is disabled" ||
      log "Service 'ptal' could not be disabled" die 1
    fi
  ;;
  *)

    # Help message.
    log "Usage: $0 {install|uninstall}" die 1
  ;;
esac

# End install.sh
