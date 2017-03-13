#! /bin/bash

main_branch="cm-11.0"
main_remote="LineageOS"
url_start="https://github.com/LineageOS/android_"
url_end=".git"
git_start="git@github.com:os2sd/android_"
#git_start="https://github.com/os2sd/android_"
git_end=".git"
twrp_url="https://github.com/omnirom/android_bootable_recovery.git"
twrp_remote="omnirom"
twrp_branch="android-6.0"
twrp_path="bootable/recovery-twrp"

path=(
  bionic
  build
  dalvik
  $twrp_path
  external/chromium
  external/chromium_org
  external/libncurses
  external/llvm
  external/skia
  external/srec
  external/wpa_supplicant_8
  frameworks/av
  frameworks/base
  frameworks/compile/libbcc
  frameworks/compile/slang
  frameworks/native
  frameworks/rs
  frameworks/webview
  hardware/broadcom/wlan
  hardware/libhardware
  hardware/libhardware_legacy
  hardware/qcom/gps
  packages/apps/Browser
  packages/apps/Settings
  packages/apps/Trebuchet
  packages/inputmethods/LatinIME
  packages/wallpapers/Basic
  system/core
  system/netd
  vendor/cm
)

# Read array $path lenght
repos=$(echo ${#path[@]} )

read -r -p "Do you wish to add remotes? [y/N] " response
response=${response,,}
if [[ $response =~ ^(yes|y)$ ]]
then
  for ((i = 0; i < $repos; i++))
  do
    # Exception
    if [[ ${path[i]} == $twrp_path ]]; then
      url=$twrp_url
      remote=$twrp_remote
    else
      # Generate url from $path
      url="${url_start}$(echo ${path[i]} | sed 's.\/._.g')${url_end}"
      remote=$main_remote
    fi
    echo "Adding remote ${remote} to ${path[i]}"
    git -C ${path[i]} remote remove ${remote} 2> /dev/null
    git -C ${path[i]} remote add ${remote} ${url}
  done
  echo
fi

read -r -p "Do you wish to fetch remotes? [y/N] " response
response=${response,,}
if [[ $response =~ ^(yes|y)$ ]]
then
  for ((i = 0; i < $repos; i++))
  do
    # Exception
    if [[ ${path[i]} == $twrp_path ]]; then
      remote=$twrp_remote
      branch=$twrp_branch
    else
      remote=$main_remote
      branch=$main_branch
    fi
    echo "Fetching ${path[i]}"
    git -C ${path[i]} fetch ${remote} ${branch}
  done
  echo
fi

read -r -p "Do you wish to change branches? [y/N] " response
response=${response,,}
if [[ $response =~ ^(yes|y)$ ]]
then
  for ((i = 0; i < $repos; i++))
  do
    # Exception
    if [[ ${path[i]} == $twrp_path ]]; then
      branch=$twrp_branch
    else
      branch=$main_branch
    fi
    echo "Changing ${path[i]} branch to $branch"
    git -C ${path[i]} checkout -b temp
    git -C ${path[i]} branch -D $branch
    git -C ${path[i]} checkout -b $branch
    git -C ${path[i]} branch -D temp
  done
  echo
fi

read -r -p "Do you wish to merge changes? [y/N] " response
response=${response,,}
if [[ $response =~ ^(yes|y)$ ]]
then
  for ((i = 0; i < $repos; i++))
  do
    # Exception
    if [[ ${path[i]} == $twrp_path ]]; then
      remote=$twrp_remote
      branch=$twrp_branch
    else
      remote=$main_remote
      branch=$main_branch
    fi
    echo "Merging changes to ${path[i]}"
    git -C ${path[i]} merge ${remote}/${branch}
    echo
  done
fi

read -r -p "Do you wish to push changes? [y/N] " response
response=${response,,}
if [[ $response =~ ^(yes|y)$ ]]
then

  #eval `ssh-agent -s`
  #ssh-add

  for ((i = 0; i < $repos; i++))
  do
    # Exception
    if [[ ${path[i]} == $twrp_path ]]; then
      branch=$twrp_branch
    else
      branch=$main_branch
    fi
    echo "Pushing ${path[i]} changes"
    git="${gitstart}$(echo ${path[i]} | sed 's.\/._.g')${gitend}"
    git -C ${path[i]} push ${git} ${branch}
  done
fi

exit
