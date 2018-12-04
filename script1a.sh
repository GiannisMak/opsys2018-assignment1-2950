#!/bin/bash
touch up12950 #A file that contains the URLs with blank lines deleted because wget can not work
sed '/^[[:space:]]*$/d' $1 > up12950 #Deletion if the blank spaces and to up1.
if [ ! -d sites2950 ]; then
    touch temp2950
    mkdir -p sites2950;
    while IFS='' read -r line || [[ -n "$line" ]]; do #Reading the URLs' file line by line.
    #Taking the first character of the URL to check if the line is a comment.
    tempChar=$(echo $line | head -c 1)
        if [ ! "$tempChar" == "#" ]; then
            #filename is the file that the HTML will be saved. Name of this file is the URL
            #without special characters.
            filename=$(echo $line | tr -dc '[:alnum:]\n\r')
            wget -qO sites2950/$filename $line
            if [ ! 0 -eq $? ]; then #Checking if wget was succesful
                echo "$line FAILED" >> /dev/stderr
            else
                echo "$line INIT"
            fi
        fi
    done < up12950
    rm temp2950
else
    while IFS='' read -r line || [[ -n "$line" ]]; do
        filename=$(echo $line | tr -dc '[:alnum:]\n\r')
        tempChar=$(echo $line | head -c 1)
        if [ ! "$tempChar" == "#" ]; then
            #Checking if it is the first time reading this URL
            if [ ! -f sites2950/$filename ]; then 
                wget -qO sites2950/$filename $line
                if [ ! 0 -eq $? ]; then #Checking if wget was succesful
                    echo "$line FAILED" >> /dev/stderr
                else
                    echo "$line INIT"
                fi
            else
                #temp is the file that it is going to be compared with the file that already 
                #exists for the URL.
                touch sites2950/temp2950
                wget -qO sites2950/temp2950 $line
                if [ ! 0 -eq $? ]; then #Checking if wget was succesful
                        echo "$line FAILED" >> /dev/stderr
                        echo "FAILED" >> sites2950/$filename
                else
                    if ! diff -q sites2950/temp2950 sites2950/$filename > /dev/null; then
                        #Copying the file if there is difference.
                        cp  sites2950/temp2950 sites2950/$filename 
                        echo "$line"
                    fi
                fi
            fi
        fi
    done < up12950
fi
rm up12950
    
