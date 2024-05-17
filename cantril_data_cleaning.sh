#/bin/bash

# Returning the error if user provides more or less than 3 arguments.
if [ "$#" -ne 3 ]; then
  echo "Error: Please provide only <homicide-rate-unodc.tsv> <life-satisfaction-vs-life-expectancy.tsv> <gdp-vs-happiness.tsv> files." > /dev/stderr
  exit 1
fi

for file; do
  case "$file" in
    *"gdp-vs-happiness.tsv"*)
      input_file1=$file
      ;;
    *"homicide-rate-unodc.tsv"*)
      input_file2=$file
      ;;
    *"life-satisfaction-vs-life-expectancy.tsv"*)
      input_file3=$file
      ;;
    *)
      echo "Error: Incorrect '$file' file." > /dev/stderr
      exit 1
      ;;
  esac
done

awk -F'\t' -v OFS='\t' '
    BEGIN { 
        # Set field separators
        FS = OFS = "\t"
    }
    # Read the first file into array a
    FNR == NR {
        a[$1 FS $3] = $0
        next
    }
    # For the second and third files, if key exists in array a, print combined lines
    ($1 FS $3) in a {
        print a[$1 FS $3], $0
    }
' "$input_file1" "$input_file2" "$input_file3" |
awk -F'\t' -v OFS='\t' '
    # Print header line and filter data based on conditions
    NR == 1 || ($3 >= 2011 && $3 <= 2021 && $2 != "") {
        print $1, $2, $3, $12, $6, $18, $4, $5
    }
' > "cantril_data_cleaning.tsv"

