#!/bin/bash

mkdir -p public
touch ./public/.nojekyll
rsync -av images public/
rsync -av render public/
rsync -av site_libs public/
rsync index.html render public/
ORGANIZATION=$1
REPO=$2


sed -i "s/{{organization}}/$ORGANIZATION/g" "./public/index.html"
sed -i "s/{{repo}}/$REPO/g" "./public/index.html"

temp_file=$(mktemp)  # Create a temporary file

# Loop through files in the ./render directory
for file in ./render/*; do
    # Extracting the filename without the directory path and extension
    filename=$(basename "$file")
    filename_no_extension="${filename%.*}"

    # Creating the section with the filename and appending to the temporary file
    echo "<div class=\"quarto-layout-row quarto-layout-valign-top\"><div class=\"quarto-layout-cell quarto-layout-cell-subref\" style=\"flex-basis: 100%; justify-content: center\" ><div id=\"fig-${filename_no_extension}\" class=\"quarto-figure quarto-figure-center anchored\" ><figure class=\"figure\"><p><img src=\"/$REPO/render/${filename}/${filename}.png\" class=\"img-fluid figure-img\" data-ref-parent=\"fig-figure3.1\" /></p><p></p><figcaption class=\"figure-caption\"> ${filename_no_extension} </figcaption><p></p></figure></div></div></div>" >> "$temp_file"
done

template_file="./public/index.html"
sed -i "s/{{section}}/$(sed 's:/:\\/:g' $temp_file | tr -d '\n')/g" "$template_file"
