#! /bin/bash

branch="cm-11.0"
remote="CyanogenMod"
urlstart="https://github.com/CyanogenMod/android_"
urlend=".git"
gitstart="git@github.com:os2sd/android_"
#gitstart="https://github.com/os2sd/android_"
gitend=".git"

path=(
bionic
build
dalvik
bootable/recovery
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

#############


# Read array $path lenght
repos=$(echo ${#path[@]} )

read -r -p "Do you wish to add remotes? [y/N] " response
response=${response,,}  
if [[ $response =~ ^(yes|y)$ ]]
then
for ((i = 0; i < $repos; i++)) 
do
echo "Adding remote ${remote} to ${path[i]}"
# Generate url from $path
url="${urlstart}$(echo ${path[i]} | sed 's.\/._.g')${urlend}"
git -C ${path[i]} remote remove ${remote}
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
echo "Fetching ${path[i]}"
git -C ${path[i]} fetch ${remote} 
done
echo
fi

read -r -p "Do you wish to change branches? [y/N] " response
response=${response,,}  
if [[ $response =~ ^(yes|y)$ ]]
then
for ((i = 0; i < $repos; i++)) 
do
echo "Changing ${path[i]} branch  to $branch"
git -C ${path[i]} branch temp
git -C ${path[i]} checkout temp
git -C ${path[i]} branch -D $branch
git -C ${path[i]} branch $branch
git -C ${path[i]} checkout $branch
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
echo "Pushing ${path[i]} changes"
git="${gitstart}$(echo ${path[i]} | sed 's.\/._.g')${gitend}"
git -C ${path[i]} push ${git} ${branch}
done
fi

exit
