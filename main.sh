#!/usr/bin/env bash

# Validate domain
if [ -z "$1" ]
then
    echo "\nPlease insert the target."
    echo "$ sh main.sh domain.com"
    exit 1;
fi

################################################
# Variables
################################################
domain=$1
reports_folder="/root/reports"
main_common_wordlist="/root/SecLists/Discovery/Web-Content/common.txt"

################################################
# VALIDATIONS
################################################

# Check folder domain
if [ ! -d $reports_folder/$domain ]; then
    mkdir -p $reports_folder/$domain;
fi

#echo "Starting a recon on $domain" | notify

################################################
# SUBDOMAINS    
################################################
if [ ! -f "$reports_folder/$domain/subdomains" ]; then
    subfinder -d $domain -v | httpx | anew $reports_folder/$domain/subdomains
fi
while IFS= read -r subdomain; do

    ################################################
    # DEFINE SUBDOMAIN FOLDER 
    ################################################
    subdomain_folder=$(sed 's|://|_|' <<< "$subdomain")

    ################################################
    # SUBDOMAIN FOLDER 
    ################################################
    if [ ! -d $reports_folder/$domain/$subdomain_folder ]; then
        mkdir -p $reports_folder/$domain/$subdomain_folder;
    fi

    ################################################
    # DIRECTORIES   
    ################################################
    if [ ! -f "$reports_folder/$domain/$subdomain_folder/dirsearch" ]; then
        dirsearch -u $subdomain -w $main_common_wordlist -o $reports_folder/$domain/$subdomain_folder/dirsearch --format=simple -x 403,301,302,508 -R 3
    fi
    
    ################################################
    # PORTS 
    ################################################
    # naabu -host $subdomain | anew $reports_folder/$domain/$subdomain_folder/ports

    ################################################
    # URLS  
    ################################################
    if [ ! -f "$reports_folder/$domain/$subdomain_folder/urls" ]; then
        gau $subdomain --blacklist css,png,jpeg,jpg,svg,gif,ttf,woff,woff2,eot,otf,ico | httpx | anew $reports_folder/$domain/$subdomain_folder/urls
    fi
    
    ################################################
    # LINKS COMPILATED
    ################################################   
    # cat $reports_folder/$domain/$subdomain_folder/dirsearch | httpx | anew $reports_folder/$domain/$subdomain_folder/links
    # cat $reports_folder/$domain/$subdomain_folder/urls | httpx | anew $reports_folder/$domain/$subdomain_folder/links

done < $reports_folder/$domain/subdomains

# cat nuclei | httpx | anew $reports_folder/$domain/$subdomain/links
# gospider -s $subdomain -o $reports_folder/$domain/$subdomain/gospider

################################################
# Scan 
################################################
# nuclei -u $subdomain -o $reports_folder/$domain/$subdomain/nuclei

################################################
# FUZZING   
################################################
# ffuf -c -w /usr/share/wordlists/dirb/small.txt -u $domain/FUZZ -recursion -o $reports_folder/$domain/ffuf
# hakrails
# hakrawler
# aquatone

#cat $reports_folder/$domain/subdomains | notify -silent -bulk

################################################
# FINISH   
################################################
#echo "Finished the recon on $domain" | notify
#echo "Report: $reports_folder/$domain/"
