#!/bin/bash


switch_file=configs_switch
config_file=configs
enabled_services=()
enabled_arguments=()
set -xe


configure_squid(){
while read -r f1 f2 f3
do
        # printf 'key: %s, value: %s\n' "$f1" "$f3" 
        # if value == 0 pass, if value == 1 set variable and export, else incorrect input
        if [[ "$f3" -eq 0 ]]
        then
            continue
        # then printf 'service %s will not be enabled \n' "$f1"
        elif [[ "$f3" -eq 1 ]]
        then 
            # printf 'service %s will be enabled \n' "$f1"
            enabled_services+=( $f1 )
            # echo $f1

        else
            printf 'incorrect value for %s \n' "$f1"
            exit 1
        fi
done <"$switch_file" 

# echo ${enabled_services[@]}
# echo "readin second file"
# while read -r f1 f2 f3
# do
#         awk -F= -v x=$i '$1==x{print $2}' configs
# done <"$config_file" 
for i in "${enabled_services[@]}";
do 
    # echo $i
    value="$(awk -F' {2,}' -v x="$i" '$1==x{print $3}' configs)" 
    enabled_arguments+=( $value )
done
echo "${enabled_arguments[@]}"

}

# read_list
configure_squid
