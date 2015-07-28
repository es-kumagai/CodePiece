#
# To create zip archive,
# Write following script to post action script of Archive action of CodePiece scheme.
#
#	sh "${PROJECT_DIR}/Resources/Scripts/ArchiveZip.sh"
#


## Get Bundle Version.

InfoPlistFile="${SRCROOT}/${INFOPLIST_FILE}"
BuildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${InfoPlistFile}")

## Define Paths.

SourcePath="${BUILT_PRODUCTS_DIR}"
DestinationPath="${ARCHIVE_PATH}/.."
TargetName="CodePiece_build-${BuildNumber}"
ArchiveName="${TargetName}.zip"
TargetPath="${DestinationPath}/${TargetName}"
ArchivePath="${DestinationPath}/${ArchiveName}"

AppPath="${ARCHIVE_PRODUCTS_PATH}/Applications/${FULL_PRODUCT_NAME}"

## Report Paths before executing.

echo "Source Path : ${SourcePath}"
echo "Destination Path : ${DestinationPath}"
echo "Target Path : ${TargetPath}"
echo "Archive Path : ${ArchivePath}"

## Ready for executing.

cd "${DestinationPath}"

if [ -e "${TargetName}" ]
then
	rm -rf "${TargetName}"
fi

if [ -e "${ArchiveName}" ]
then
	rm -f "${ArchiveName}"
fi

## Executing

mkdir -vp "${TargetPath}"

cp -rf "${AppPath}" "${TargetPath}"
cp -f "${SourcePath}/README.md" "${TargetPath}"
cp -f "${SourcePath}/CHANGELOG.md" "${TargetPath}"
cp -rf "${SourcePath}/ss" "${TargetPath}"

zip -vr "${ArchiveName}" "${TargetName}"
