#!/bin/bash
s_version="v1.5"
# echo "Java data collection script $s_version started."
date=$(date '+%Y-%m-%d %H:%M:%S')
# date_f=$(date '+%Y-%m-%d_%H%M%S')
date_f=$(date '+%F')
# output_file="/repository/shared/javaAudit/Java-reports-`date +%F`/$(hostname)-java-installations_$date_f.csv"
output_file="/repository/shared/javaAudit/Java_Reports/nonprod-java-installations_$date_f.csv"
os_name=$(uname -s)
os_details=$(uname -a)
java_version=""

mkdir -p /repository/shared/javaAudit/Java-reports-`date +%F`/

# Function to get first-level directories from root
get_directories() {
    find / -maxdepth 1 -type d -print 2>/dev/null
}

# Function to search for an executable file in the given directories
search_executable() {
    local executable_name="$1"
    local directories=($(get_directories))

    for dir in "${directories[@]}"; do
	if [[ $dir != "/" && $dir != "/proc" && $dir != "/.snapshots" ]]; then
	    find "$dir" -type f -name "$executable_name" -executable
        fi
    done
}

# A function to collect the "java -version" command output
function getJavaVersion(){
 if [[ -x $java_path ]]; then
    java_version="$("$java_path" -version 2>&1 | tr '\n' ',' | awk '{print substr($0, 1, length($0)-1)}')"
  else
    java_version="File is not an executable!"
  fi
}

# A function to write output to the file
function writeOutputFile(){
  getJavaVersion
  echo "\"$(hostname)\";\"$java_path\";\"$date\";\"$1\";\"$java_version\"" >> "$output_file"
}

# echo "Java script version: $s_version" > "$output_file"
# echo "Date and Time: $date" >> "$output_file"
# echo "Detected OS type: [$os_name]" >> "$output_file"
# echo "Detected OS specs: [$os_details]" >> "$output_file"

# echo "\"Server_Name\";\"Java_Installation_Path\";\"Collection_Date\";\"Collection_Type\";\"Java_Version\"" >> "$output_file"

if [[ "$os_name" == "Linux" ]]; then

  while read -r java_path; do
	date=$(date '+%Y-%m-%d %H:%M:%S:%3N')
	writeOutputFile "java_exec_scan"
  done < <( search_executable "java" )
  
elif [[ "$os_name" == "SunOS" ]]; then

  while read -r java_path; do
    if test -x "$java_path"; then
	date=$(date '+%Y-%m-%d %H:%M:%S:%3N')
	writeOutputFile "java_exec_scan"
    fi
  done < <( find / -name java -type f 2>/dev/null )
  
else

  echo "Java data collection script was not tested on [$os_name] OS."
  echo "Using default Find parameters to collect the data."
  echo "In case of errors please reach out to us for support."
  while read -r java_path; do
	date=$(date '+%Y-%m-%d %H:%M:%S:%3N')
	writeOutputFile "java_full_scan"
  done < <( find / -name java -type f )
 
fi

# echo "Java data collected and saved to $output_file"
# echo "Script execution finished"