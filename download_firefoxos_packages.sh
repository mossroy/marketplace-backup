#!/bin/bash
API_ROOT_URL=https://marketplace.firefox.com
SEARCH_REQUEST=/api/v2/apps/search/?dev=firefoxos

# See https://firefox-marketplace-api.readthedocs.io/en/latest/topics/apps.html

OUT_DIR=`pwd`/output

function download_json {
    echo "Downloading $1 to $OUT_DIR$2.json"
    curl -sS $1 | jq . > $OUT_DIR$2.json
}

OFFSET=0
rm -f $OUT_DIR/listing.json
while [ $SEARCH_REQUEST != "null" ]; do
	download_json $API_ROOT_URL$SEARCH_REQUEST /listing-$OFFSET
	# Get the URL request for next page
	SEARCH_REQUEST=$(jq -r .meta.next $OUT_DIR/listing-$OFFSET.json)
	# Put the JSON of each app in a separate line, and append all of them in a single file
	jq -r -c ".objects[]" $OUT_DIR/listing-$OFFSET.json >>$OUT_DIR/listing.json
	OFFSET=$[ $OFFSET + 25 ]
done

while read -r LINE; do
	ID=`echo $LINE | jq -r .id`
	SLUG=`echo $LINE | jq -r .slug`
	PACKAGE_PATH=`echo $LINE | jq -r .package_path`
	echo "ID=$ID SLUG=$SLUG PACKAGE_PATH=$PACKAGE_PATH"
	APP_OUT_DIR="$OUT_DIR/$ID-$SLUG"
	mkdir -p "$APP_OUT_DIR"
	# Copy JSON
	echo $LINE > "$APP_OUT_DIR/info.json"
	# Download package
	if [ $PACKAGE_PATH != "null" ]; then
		wget --no-verbose --timestamping --directory-prefix="$APP_OUT_DIR" $PACKAGE_PATH 
	fi
	# Download icon
	echo $LINE | jq -r .icons.\"128\" | grep -v null | while read -r ICON_URL; do
		wget --no-verbose --timestamping --directory-prefix="$APP_OUT_DIR" $ICON_URL
	done
	# Download screenshots
	APP_THUMBNAILS_OUT_DIR="$APP_OUT_DIR/thumbnails"
	APP_SCREENSHOTS_OUT_DIR="$APP_OUT_DIR/screenshots"
	mkdir -p "$APP_THUMBNAILS_OUT_DIR"
	mkdir -p "$APP_SCREENSHOTS_OUT_DIR"
	echo $LINE | jq -r .previews[].thumbnail_url | grep -v null | while read -r THUMBNAIL_URL; do
		wget --no-verbose --timestamping --directory-prefix="$APP_THUMBNAILS_OUT_DIR" $THUMBNAIL_URL &
	done
	echo $LINE | jq -r .previews[].image_url | grep -v null | while read -r IMAGE_URL; do
		wget --no-verbose --timestamping --directory-prefix="$APP_SCREENSHOTS_OUT_DIR" $IMAGE_URL &
	done
	# Download manifest.webapp
	MANIFEST_URL=`echo $LINE | jq -r .manifest_url`
	if [ $MANIFEST_URL != "null" ]; then
		wget --no-verbose --timestamping --directory-prefix="$APP_OUT_DIR" $MANIFEST_URL &
	fi
done < "$OUT_DIR/listing.json"
