#!/usr/bin/php
<?php

# Nagios Monitor for IP List Gist
# Version 1.0
# Author: Trey Simmons
# Latest Version Tested: 1.0
# Lowest PHP Version Tested: 5.3.3

define('STATE_OK', 0);
define('STATE_WARNING', 1);
define('STATE_CRITICAL', 2);
define('STATE_UNKNOWN', 3);

define('VERSION_FILE', "previous_version");

# Set up cURL call
$handle = curl_init("https://gist.github.com/ervinb/ecab6ca35ec87ed0cadf");
curl_setopt($handle, CURLOPT_FAILONERROR, true);
curl_setopt($handle, CURLOPT_CONNECTTIMEOUT, 15);
curl_setopt($handle, CURLOPT_RETURNTRANSFER, true);

# Get IP list file from Gist
$ipList = curl_exec($handle);

# Handle errors from cURL call
if(curl_errno($handle) || $ipList === false) {
  echo "Curl Error: " . curl_error($handle);
  echo "CRITICAL: cURL command failed. Current Version couldn't be retrieved.";
};

# Isolate Gist revision ID 
$hrefRegex = "(?<=raw\/).*(?=\/ips.txt)";
preg_match("/$hrefRegex/", $ipList, $version);

$revisionID = $version[0];

curl_close($handle);

# Execute Nagios Check
if(is_readable(VERSION_FILE)) {
  $previousVersion = file_get_contents(VERSION_FILE);
  if($previousVersion === $revisionID) {
    # Issue Success if IP list is up-to-date
    echo "OK: Gist containing IP list has not been updated.\n";

    exit(STATE_OK);
  }else{
    # Issue Warning if Revision ID will be updated (IP list is not current)
    echo "WARNING: The IP list version appears to have changed from ${previousVersion} to ${revisionID}. Save file has been updated to newest version.\n";
    file_put_contents(VERSION_FILE, $revisionID);

    exit(STATE_WARNING);
  };
}else{
  if(file_exists(VERSION_FILE)) {
    # Issue Critical if there is problem with file and IP list can't be checked
    echo "CRITICAL: The file cannot be opened. Please check the status of this file.\n";

    exit(STATE_CRITICAL);
  }else{
    # Issue Unknown if no version file exists on server
    file_put_contents(VERSION_FILE, $revisionID); 
    chmod(VERSION_FILE, 0766);
    echo "UNKNOWN: No save file was found. The current version has been saved for future use.\n";

    exit(STATE_UNKNOWN);
  };
};

?>
