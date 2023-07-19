#!/bin/bash
# This script generates documentation files under the Applications folder from all the clusters and then updates index.rst
# Example Usage: ./generateapplicationsdocumentationallclusters.sh

current_dir="$PWD" # save current directory 
cd ../ # go up one directory
repo_path="$PWD" # assign path to repo_path
cd $current_dir # cd back to current directory


clusternames=("$anvil1" "$anvil2")
export anvil1="$repo_path/Clusters/Anvil-Modulefiles/cpu-20211007"
export anvil2="$repo_path/Clusters/Anvil-Modulefiles/gpu-20211014"

# Git pull on all clusters. Uncomment to pull every time the script is run
# for name in ${clusternames[@]}; do
#     cd $name
#     git pull
# done

cd $current_dir

function generateListOfMissingFiles() {
    diff -x '*.lua' -q $applicationsfolder $luasource | grep "Only in $repo_path/Clusters/" > tempfile.txt
    awk 'NF{ print $NF }' tempfile.txt > listofmissingfiles.txt
    rm tempfile.txt
    readarray -t listofmissingfiles < listofmissingfiles.txt
}



applicationsfolder="$repo_path/Applications/"



# Remove aoc, gcc, intel, openmpi, intel-mpi, intel-oneapi-compilers, intel-oneapi-mpi, and mvapich2 since they come under Compilers and MPIs
declare -a filestoberemoved=(
[0]=aocc
[1]=gcc
[2]=intel
[3]=openmpi
[4]=impi
[5]=intel-oneapi-compilers
[6]=intel-oneapi-mpi
[7]=mvapich2
)
for filename in ${filestoberemoved[@]}; do
    rm -f "$applicationsfolder/$filename.rst"
done

# Remove listofmissingfiles
rm listofmissingfiles.txt


# Update index.rst

indexfile="/$repo_path/index.rst"
cd $repo_path

# subfoldersarray=`ls -d */`
declare -a subfoldersarray=(
[0]=FAQs/
[1]=Compilers/
[2]=MPIs/
[3]=Applications/
[4]=Biocontainers/
[5]=NGC/
)

sed -i '/.. toctree::/,$d' $indexfile

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

echo ".. toctree::" >> $indexfile
echo "   :maxdepth: 2" >> $indexfile
echo "" >> $indexfile

for eachfolder in ${subfoldersarray[@]}
do
    if [ "$eachfolder" != "Scripts/" ] && [ "$eachfolder" != "images/" ] && [ "$eachfolder" != "Clusters/" ] && [ "$eachfolder" != "Applications/" ] && [ "$eachfolder" != "Biocontainers/" ]; then
        echo "each folder : $eachfolder"
        eachfolderwithspaces="${eachfolder//_/ }"
        echo "   "${eachfolderwithspaces::-1} >> $indexfile
        subindexfile=${eachfolderwithspaces::-1}.rst
        if [ "$eachfolder" == "NGC/" ]; then
            echo "NVIDIA NGC containers" > $subindexfile
        elif [ "$eachfolder" == "ROCm/" ]; then
            echo "AMD ROCm containers" > $subindexfile
        else
            echo ${eachfolderwithspaces::-1} > $subindexfile
        fi
        echo "==============================================" >> $subindexfile
        echo ".. toctree::" >> $subindexfile
        echo "   :titlesonly:" >> $subindexfile
        echo "" >> $subindexfile
        sourcefolder="$repo_path/$eachfolder"

        echo "source folder : $sourcefolder"
        grep -rLZ "Anvil" $sourcefolder | while IFS= read -rd '' x; do rm "$x"; done
        filenamesarray=`ls "$sourcefolder"`
        for eachfile in $filenamesarray
        do
            sed -i "/\b\(Bell\|Brown\|Gilbreth\|Negishi\|Scholar\|Workbench\)\b/d" ${sourcefolder}/$eachfile
            eachfile=${eachfile::-4}
            echo "   $eachfolder""$eachfile" >> $subindexfile
        done 
    fi

    if [ "$eachfolder" == "Biocontainers/" ]; then
        svn --force -q export https://github.com/PurdueRCAC/Biocontainers/trunk/docs/source
        rm -r Biocontainers
        mv -f source Biocontainers
        echo "each folder : $eachfolder"
        eachfolderwithspaces="${eachfolder//_/ }"
        echo "   "${eachfolderwithspaces::-1} >> $indexfile
        subindexfile=${eachfolderwithspaces::-1}.rst
        echo ${eachfolderwithspaces::-1} > $subindexfile
        echo "==============================================" >> $subindexfile
        echo ".. toctree::" >> $subindexfile
        echo "   :titlesonly:" >> $subindexfile
        echo "" >> $subindexfile
        sourcefolder="$repo_path/$eachfolder"
        echo "source folder : $sourcefolder"
        foldernamesarray=`ls "$sourcefolder"`
        for eachfile in $foldernamesarray
        do
            echo "   $eachfolder""$eachfile"/"$eachfile" >> $subindexfile
        done
    fi
    
    if [ "$eachfolder" == "Applications/" ]; then
        echo "each folder : $eachfolder"
        eachfolderwithspaces="${eachfolder//_/ }"
        echo "   "${eachfolderwithspaces::-1} >> $indexfile
        subindexfile=${eachfolderwithspaces::-1}.rst
        echo ${eachfolderwithspaces::-1} > $subindexfile
        echo "==============================================" >> $subindexfile

        sourcefolder="$repo_path/$eachfolder"


        echo "source folder : $sourcefolder"
        grep -rLZ "Anvil" $sourcefolder | while IFS= read -rd '' x; do rm "$x"; done        
        # Application_category.tsv processing
        cut -f 2 Application_category.tsv > listofcategories.txt
        sort listofcategories.txt > listofcategories2.txt
        uniq listofcategories2.txt > listofcategories.txt
#       rm listofcategories2.txt
        
        readarray -t listofcategories < listofcategories.txt # Get the sorted list of all categories
        rm listofcategories.txt
        sort -t$'\t' -k2 Application_category.tsv > sortedentries.txt
        
        readarray -t sortedentries < sortedentries.txt # Get the sorted list of all entries in tsv
        rm sortedentries.txt
        
        for eachcategory in ${listofcategories[@]} # Loop through each category
        do
            # echo "each category : $eachcategory"
            echo $eachcategory >> $subindexfile
            echo "---------------------------------" >> $subindexfile
            echo ".. toctree::" >> $subindexfile
            echo "   :titlesonly:" >> $subindexfile
            echo "" >> $subindexfile
            for eachsortedentry in ${sortedentries[@]} # Loop through each entry
            do
                # echo "each sorted entry : $eachsortedentry"
                firstentry=$(echo $eachsortedentry | awk '{print $1}')
                secondentry=$(echo $eachsortedentry | awk '{print $2}')

                if [[ $eachcategory == $secondentry* ]]; then # Check if entry belongs to this category
                    echo "   $eachfolder""$firstentry" >> $subindexfile
                    echo "      $eachfolder""$firstentry" >> finishedfiles.txt
                fi
                
            done
            echo "" >> $subindexfile
        done
        filenamesarray=`ls "$sourcefolder"` # Get the list of all files in source folder
        for eachfile in $filenamesarray
        do
            sed -i "/\b\(Bell\|Brown\|Gilbreth\|Negishi\|Scholar\|Workbench\)\b/d" ${sourcefolder}/$eachfile
            sed -i '/- Anvil:/s/, /\n- /g' ${sourcefolder}/$eachfile
            sed -i 's/Anvil: //g' ${sourcefolder}/$eachfile
            eachfile=${eachfile::-4}
            echo "      $eachfolder""$eachfile" >> filesinsourcefolder.txt
        done

        # Processing to find all files that are in source folder but not in Application_category.tsv
        sort filesinsourcefolder.txt > sortedfilesinsourcefolder.txt
        rm filesinsourcefolder.txt
        sort finishedfiles.txt > sortedfinishedfiles.txt
        rm finishedfiles.txt
        diff sortedfinishedfiles.txt sortedfilesinsourcefolder.txt | grep ">" > tempfile.txt
        awk 'NF{ print $NF }' tempfile.txt > listofmissingapplications.txt
        readarray -t listofmissingapplications < listofmissingapplications.txt # List all files that are in source folder but not in Application_category.tsv
        rm tempfile.txt
        rm sortedfinishedfiles.txt
        rm sortedfilesinsourcefolder.txt
        rm listofmissingapplications.txt
        
        echo "" >> $subindexfile
        for filename in ${listofmissingapplications[@]}; do # Adding missing files to index
            echo "$filename" >> $subindexfile
        done
    fi
done
IFS=$SAVEIFS

cd "$current_dir"
