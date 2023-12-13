#!/bin/bash

mkdir -p public
rsync -av images public/
rsync -av render public/
rsync index.html render public/
ORGANIZATION=$1


sed -i "s/{{organization}}/$ORGANIZATION/g" "./public/index.html"

temp_file=$(mktemp)  # Create a temporary file

# Loop through files in the ./render directory
for file in ./render/*; do
    # Extracting the filename without the directory path and extension
    filename=$(basename "$file")
    filename_no_extension="${filename%.*}"

    # Creating the section with the filename and appending to the temporary file
    echo "<section
          id=\"title-slide\"
          data-background-image=\"/render/${filename}\"
          data-background-size=\"cover\"
          class=\"quarto-title-block center\"
        >
          <h1 class=\"title\" style=\"display:none;\">${filename_no_extension}</h1>
        </section>" >> "$temp_file"
done

template_file="./public/index.html"
sed -i "s/{{section}}/$(sed 's:/:\\/:g' $temp_file | tr -d '\n')/g" "$template_file"
