#!/bin/bash

set -e

# expected CLASS_LIBRARY_PROJ_DIR and TEST_PROJ_DIR environment variables
# eg. CLASS_LIBRARY_PROJ_DIR=Source/Otc.Streaming
#     TEST_PROJ_DIR=Source/Otc.Streaming.Tests

function install
{
	cd "$TRAVIS_BUILD_DIR/$CLASS_LIBRARY_PROJ_DIR"
	dotnet restore
}

function build
{
	cd "$TRAVIS_BUILD_DIR/$CLASS_LIBRARY_PROJ_DIR"
	dotnet build -c Release
}

function deploy
{
	cd "$TRAVIS_BUILD_DIR/$CLASS_LIBRARY_PROJ_DIR"
	ARTIFACTS_FOLDER=./artifacts

	if [ ! -d $ARTIFACTS_FOLDER ]
	then
		mkdir $ARTIFACTS_FOLDER
	fi

	if echo $TRAVIS_BRANCH | egrep -i 'alpha|beta' > /dev/null 2>&1
	then
		SUFFIX=$(echo $TRAVIS_BRANCH-build$TRAVIS_BUILD_NUMBER | sed 's/[^0-9A-Za-z-]//g')
		SUFFIX_ARG="--version-suffix=$SUFFIX"
	fi

	dotnet pack -c Release $SUFFIX_ARG -o $ARTIFACTS_FOLDER
	dotnet nuget push --api-key $NUGET_API_KEY $ARTIFACTS_FOLDER/*.nupkg --source $NUGET_ENDPOINT # https://api.nuget.org/v3/index.json

	rm -Rf $ARTIFACTS_FOLDER
}

function test
{
	cd $TEST_PROJ_DIR
	dotnet test
}

$@
