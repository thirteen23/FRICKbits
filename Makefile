#
# Makefile for Frickbits.
#
# This relies on several additional tools (xctool).
#
# To install xctool:
# brew install -v --HEAD xctool
#

WORKSPACE=FRICKbits.xcworkspace
SCHEME=FRICKbits
XCTOOL=xctool -workspace $(WORKSPACE) -scheme $(SCHEME)
BUILD_DIR=build
CURRENT_DIR=$(shell pwd)

TESTFLIGHT_API_TOKEN_FILE=.testflight_api_token
TESTFLIGHT_API_TOKEN=$(shell cat $(HOME)/$(TESTFLIGHT_API_TOKEN_FILE) 2>/dev/null)
TESTFLIGHT_TEAM_TOKEN=
TESTFLIGHT_DISTRIBUTION_LIST=Alpha Testers

all: build

archive:
	@mkdir -p $(BUILD_DIR)
	# TODO: we're using Debug configuration so Tweaks appears in the TestFlight build
	$(XCTOOL) archive -archivePath $(BUILD_DIR)/$(SCHEME) -configuration Debug

build:
	$(XCTOOL) build

clean:
	@rm -rf $(BUILD_DIR)
	$(XCTOOL) clean

ipa: archive
	@zip -r $(BUILD_DIR)/$(SCHEME).app.dSYM.zip $(BUILD_DIR)/$(SCHEME).xcarchive/dSYMs/$(SCHEME).app.dSYM
	xcrun -sdk iphoneos PackageApplication -v $(BUILD_DIR)/$(SCHEME).xcarchive/Products/Applications/$(SCHEME).app -o $(CURRENT_DIR)/$(BUILD_DIR)/$(SCHEME).ipa

test:
	$(XCTOOL) test -sdk iphonesimulator

testflight: verify_testflight_dotfile ipa
	@$(eval TEMPFILE := $(shell mktemp -t build_notes))
	@vi $(TEMPFILE)
	curl http://testflightapp.com/api/builds.json \
	-F file=@$(BUILD_DIR)/$(SCHEME).ipa \
	-F dsym=@$(BUILD_DIR)/$(SCHEME).app.dSYM.zip \
	-F api_token='$(TESTFLIGHT_API_TOKEN)' \
	-F team_token='$(TESTFLIGHT_TEAM_TOKEN)' \
	-F distribution_lists='$(TESTFLIGHT_DISTRIBUTION_LIST)' \
	-F notify=True \
	-F notes=@$(TEMPFILE)

verify_testflight_dotfile:
	@test -f $(HOME)/$(TESTFLIGHT_API_TOKEN_FILE) || { echo "$(HOME)/$(TESTFLIGHT_API_TOKEN_FILE) does not exist. Exiting."; exit 1; }



