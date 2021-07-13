_makeCSV_() {
  # Creates a new CSV file if one does not already exist
  # Takes passed arguments and writes them as a header line to the CSV
  # Usage '_makeCSV_ column1 column2 column3'

  # Set the location and name of the CSV File
  if [ -z "${csvLocation}" ]; then
    csvLocation="${HOME}/Desktop"
  fi
  if [ -z "${csvName}" ]; then
    csvName="$(LC_ALL=C date +%Y-%m-%d)-${FUNCNAME[1]}.csv"
  fi
  csvFile="${csvLocation}/${csvName}"

  # Overwrite existing file? If not overwritten, new content is added
  # to the bottom of the existing file
  if [ -f "${csvFile}" ]; then
    if _seekConfirmation_ "${csvFile} already exists. Overwrite?"; then
      rm "${csvFile}"
    fi
  fi
  _writeCSV_ "$@"
}

_writeCSV_() {
  # Takes passed arguments and writes them as a comma separated line
  # Usage '_writeCSV_ column1 column2 column3'

  local csvInput=("$@")
  saveIFS=$IFS
  IFS=','
  echo "${csvInput[*]}" >>"${csvFile}"
  IFS=${saveIFS}
}
