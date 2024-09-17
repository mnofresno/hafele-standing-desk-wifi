.PHONY: all

all: transpile_html build curl_upload

all_usb: transpile_html build usb_upload

transpile_html:
	bash firmware/transpile_html.sh

build:
	bash firmware/build.sh

curl_upload:
	bash firmware/curl_upload.sh $(TARGET_IP)

usb_upload:
	bash firmware/usb_upload.sh $(TARGET_DEVICE)
