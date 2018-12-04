#!/bin/bash
#A function that stores the URL of the site that bash sent, into filename.
copying(){
    #filename is the file that the HTML will be saved. Name of this file is the URL
    #without special characters.
    filename=$(echo $1 | tr -dc '[:alnum:]\n\r')
    wget -qO sites2950/$filename $line
    if [ ! 0 -eq $? ]; then #Checking if wget was succesful
         echo "$1 FAILED" >> /dev/stderr
    else
         echo "$1 INIT"
    fi
}

#Used to see if there is a difference between the previous time that the script ran. The new 
#version is saved into a file with the name of the URL without the special characters and adding 
#some random letters at the end of it.
copying2(){
    filename=$(echo $1 | tr -dc '[:alnum:]\n\r')
    if [ ! -f sites2950/$filename ]; then #Checking if it is the first time reading this URL
                wget -qO sites2950/$filename $1
                if [ ! 0 -eq $? ]; then #Checking if wget was succesful
                    echo "$1 FAILED" >> /dev/stderr
                else
                    echo "$1 INIT"
                fi
            else
                #Deleting the special characters and adding in the end of the name of the file
                #random letters to avoid conflict
                temp=$(echo "$filename asd" | tr -d '[:space:]\n\r')
                touch sites2950/$temp
                wget -qO sites2950/$temp $1
                if [ ! 0 -eq $? ]; then #Checking if wget was succesful
                        echo "$line FAILED" >> /dev/stderr
                        echo "FAILED" >> sites2950/$filename
                else
                    if ! diff -q sites2950/$temp sites2950/$filename > /dev/null; then
                        #Copying the file if there is difference.
                        cp  sites2950/$temp sites2950/$filename 
                        echo "$line"
                    fi
                fi
                rm sites2950/$temp
            fi
}

touch up2950 #A file that contains the URLs with blank lines deleted because wget can not work
sed '/^[[:space:]]*$/d' $1 > up2950 #Deletion of the blank spaces and enters and copy to up2950.
if [ ! -d sites2950 ]; then
    mkdir -p sites2950;
    echo -e "$(<up2950 )" |
    {
    while IFS='' read -r line || [[ -n "$line" ]]; do #Reading the URLs' file line by line.
        #Wait is used to terminate the program succesfully.
        tempChar=$(echo $line | head -c 1)
        if [ ! "$tempChar" == "#" ]; then
            copying $line&
        fi
    done
    wait
    }
else
    echo -e "$(<up2950 )" |
    {
    #By using & at the end of while, all of the URLs are checked in the same time
    #wait is used to terminate the program succesfully.
    while IFS='' read -r line || [[ -n "$line" ]]; do
        tempChar=$(echo $line | head -c 1)
        if [ ! "$tempChar" == "#" ]; then
            copying2 $line &
        fi
    done
    wait
    }
fi
rm up2950
    
