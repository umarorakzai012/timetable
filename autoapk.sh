#!/usr/bin/bash

echo s, m, or l: 

read changes

current_dir=$(pwd)

old_version=`awk -F'version: ' '{print $2}' pubspec.yaml`
old_version=(${old_version// /})
version_without_build=$(echo $old_version | cut -d'+' -f1)
digits=(${version_without_build//./ })
new_version=""

if [ "$changes" = s ]; then
    new_version="${digits[0]}.${digits[1]}.$((${digits[2]} + 1))"
elif [ "$changes" = m ]; then
    new_version="${digits[0]}.$((${digits[1]} + 1)).0"
elif [ "$changes" = l ]; then
    new_version="$((${digits[0]} + 1)).0.0"
else
    new_version=$version_without_build
fi

sed -i "s/version: $old_version/version: $new_version/" pubspec.yaml

app_name=`awk -F'android:label=' '{print $2}' android/app/src/main/AndroidManifest.xml`
app_name=(${app_name//\"/})

apk_location=build/app/outputs/apk/release
destination_apk="$current_dir/../apkFilesForMyApps/${app_name[@]}"

temp=$(mkdir -p "$destination_apk/old-versions")

cd "$destination_apk"
for f in *.apk; do mv -- "$f" "old-versions/$f"; done
cd "$current_dir"

flutter build apk

cd "$apk_location"
for f in *.apk; do cp -i "$f" "$destination_apk/${f/app/${app_name[@]}}"; done
cd "$current_dir"

flutter build apk --split-per-abi

cd "$apk_location"
for f in *.apk; do cp -i "$f" "$destination_apk/${f/app/${app_name[@]}}"; done
cd "$destination_apk"
for f in *.apk; do mv "$f" "${f/release/v$new_version}"; done
cd "$current_dir"

echo "${app_name[@]}"
echo $new_version
