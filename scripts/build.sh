#!/bin/bash

mkdir -p public
touch ./public/.nojekyll
rsync -av images public/
rsync -av render public/
rsync -av site_libs public/
# rsync index.html public/
cp index2.html public/index.html
ORGANIZATION=$1
REPO=$2


# sed -i "s/{{organization}}/$ORGANIZATION/g" "./public/index.html"
# sed -i "s/{{repo}}/$REPO/g" "./public/index.html"

temp_file=$(mktemp)  # Create a temporary file
temp_file_for_links=$(mktemp)  # Create a temporary file
sidebar_temp_file=$(mktemp)  # Create a temporary file

# Function to replace non-HTML characters with their HTML equivalents
html_safe() {
    local string="$1"
    # Replace characters using sed
    string=$(echo "$string" | sed -e 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'\''/\&#39;/g')
    echo "$string"
}

for dir in ./render/*; do
    if [ -d "$dir" ]; then
        dir_name=$(basename "$dir")
        html_safe_dir_name=$(html_safe "$dir_name")
        html_path="${html_safe_dir_name}.html"
        echo -n "<li class=\"sidebar-item\"><div class=\"sidebar-item-container\"><a href=\"./$html_path\" class=\"sidebar-item-text sidebar-link\" >$dir_name</a ></div></li>" >> "$sidebar_temp_file"
    fi 
done

# Loop through files in the ./render directory
for dir in ./render/*; do
    if [ -d "$dir" ]; then
        # Get the directory name
        dir_name=$(basename "$dir")
        # Convert non-HTML characters in the directory name to HTML characters
        html_safe_dir_name=$(html_safe "$dir_name")

        # Create an HTML file with the HTML-safe directory name
        template_file="./public/${html_safe_dir_name}.html"
        html_path="${html_safe_dir_name}.html"
        cp index.html "$template_file"

        sidebarItems=$(cat "$sidebar_temp_file")
        sed -i "s/{{organization}}/$ORGANIZATION/g" "$template_file"
        sed -i "s/{{organization}}/$ORGANIZATION/g" "./public/index.html"

        sed -i "s/{{repo}}/$REPO/g" "$template_file"
        sed -i "s/{{repo}}/$REPO/g" "./public/index.html"

        sed -i "s/{{source}}/$html_safe_dir_name/g" "$template_file"
        sed -i "s/{{source}}/$html_safe_dir_name/g" "./public/index.html"
        
        wc -l "$sidebar_temp_file"
        cat "$sidebar_temp_file"
        sed -i "s|{{sidebar}}|$sidebarItems|g" "$template_file"
        sed -i "s|{{sidebar}}|$sidebarItems|g" "./public/index.html"
        
        # Loop through files in the directory
        echo "" > "$temp_file"
        echo "" > "$temp_file_for_links"
        for file in "$dir/"*; do
            # if [ -f "$file" ]; then
                ls -lha "$dir"
                filename=$(basename "$file")
                filename_no_extension="${filename%.*}"
                # Creating the section with the filename and appending to the temporary file
                echo "<div class=\"quarto-layout-row quarto-layout-valign-top\"><div class=\"quarto-layout-cell quarto-layout-cell-subref\" style=\"flex-basis: 100%; justify-content: center\" ><div id=\"fig-${filename_no_extension}\" class=\"quarto-figure quarto-figure-center anchored\" ><figure class=\"figure\"><p><img src=\"/$REPO/render/${html_safe_dir_name}/${filename}/${filename}.png\" class=\"img-fluid figure-img\" data-ref-parent=\"fig-figure3.1\" /></p><p></p><figcaption class=\"figure-caption\"> ${filename_no_extension} </figcaption><p></p></figure></div></div></div>" >> "$temp_file"   
                echo "<li> <a href=\"#sec-introduction\" id=\"toc-sec-introduction\" class=\"nav-link active\" data-scroll-target=\"#fig-${filename_no_extension}\" >${filename_no_extension}</a></li>" >> "$temp_file_for_links"   

                             
            # fi
        done
        sed -i "s/{{section}}/$(sed 's:/:\\/:g' $temp_file | tr -d '\n')/g" "$template_file"
        sed -i "s/{{links}}/$(sed 's:/:\\/:g' $temp_file_for_links | tr -d '\n')/g" "$template_file"
    fi
done



## index.html
