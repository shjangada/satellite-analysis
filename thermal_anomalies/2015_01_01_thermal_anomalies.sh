#!/bin/bash

GREP_OPTIONS=''

cookiejar=$(mktemp cookies.XXXXXXXXXX)
netrc=$(mktemp netrc.XXXXXXXXXX)
chmod 0600 "$cookiejar" "$netrc"
function finish {
  rm -rf "$cookiejar" "$netrc"
}

trap finish EXIT
WGETRC="$wgetrc"

prompt_credentials() {
    # echo "Enter your Earthdata Login or other provider supplied credentials"
    # read -p "Username (patil1pd): " username
    # username=${username:-patil1pd}
    # read -s -p "Password: " password
    echo "machine urs.earthdata.nasa.gov login patil1pd password thePUNK#1" >> $netrc
    echo
}

exit_with_error() {
    echo
    echo "Unable to Retrieve Data"
    echo
    echo $1
    echo
    echo "https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2325.006.2015294085302.hdf"
    echo
    exit 1
}

prompt_credentials
  detect_app_approval() {
    approved=`curl -s -b "$cookiejar" -c "$cookiejar" -L --max-redirs 5 --netrc-file "$netrc" https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2325.006.2015294085302.hdf -w %{http_code} | tail  -1`
    if [ "$approved" -ne "302" ]; then
        # User didn't approve the app. Direct users to approve the app in URS
        exit_with_error "Please ensure that you have authorized the remote application by visiting the link below "
    fi
}

setup_auth_curl() {
    # Firstly, check if it require URS authentication
    status=$(curl -s -z "$(date)" -w %{http_code} https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2325.006.2015294085302.hdf | tail -1)
    if [[ "$status" -ne "200" && "$status" -ne "304" ]]; then
        # URS authentication is required. Now further check if the application/remote service is approved.
        detect_app_approval
    fi
}

setup_auth_wget() {
    # The safest way to auth via curl is netrc. Note: there's no checking or feedback
    # if login is unsuccessful
    touch ~/.netrc
    chmod 0600 ~/.netrc
    credentials=$(grep 'machine urs.earthdata.nasa.gov' ~/.netrc)
    if [ -z "$credentials" ]; then
        cat "$netrc" >> ~/.netrc
    fi
}

fetch_urls() {
  if command -v curl >/dev/null 2>&1; then
      setup_auth_curl
      while read -r line; do
        # Get everything after the last '/'
        filename="${line##*/}"

        # Strip everything after '?'
        stripped_query_params="${filename%%\?*}"

        curl -f -b "$cookiejar" -c "$cookiejar" -L --netrc-file "$netrc" -g -o $stripped_query_params -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
      done;
  elif command -v wget >/dev/null 2>&1; then
      # We can't use wget to poke provider server to get info whether or not URS was integrated without download at least one of the files.
      echo
      echo "WARNING: Can't find curl, use wget instead."
      echo "WARNING: Script may not correctly identify Earthdata Login integrations."
      echo
      setup_auth_wget
      while read -r line; do
        # Get everything after the last '/'
        filename="${line##*/}"

        # Strip everything after '?'
        stripped_query_params="${filename%%\?*}"

        wget --load-cookies "$cookiejar" --save-cookies "$cookiejar" --output-document $stripped_query_params --keep-session-cookies -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
      done;
  else
      exit_with_error "Error: Could not find a command-line downloader.  Please install curl or wget"
  fi
}

fetch_urls <<'EDSCEOF'
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2325.006.2015294085302.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2320.006.2015294085254.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2315.006.2015294085238.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2310.006.2015294085250.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2305.006.2015294085238.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2300.006.2015294085337.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2145.006.2015294085332.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2140.006.2015294085254.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2135.006.2015294085258.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2130.006.2015294085315.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2125.006.2015294085241.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2005.006.2015294085314.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.2000.006.2015294085241.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.1955.006.2015294085246.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.1950.006.2015294085247.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.1945.006.2015294085320.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.1825.006.2015294085115.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.1820.006.2015294084930.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.1815.006.2015294084925.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.0015.006.2015294084925.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.0010.006.2015294085337.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.0005.006.2015294085323.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD14.006/2015.01.01/MOD14.A2015001.0000.006.2015294084930.hdf
EDSCEOF
