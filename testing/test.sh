test_file () {

t_url=$1
t_code=$2
result=$(curl -o /dev/null -s  -w "%{http_code}\n" -I --proxy "http://localhost:8081" "$url")


x="$1 ==> Result: $result , Expected: $t_code" 
if  [[ "$result" = "$t_code" ]]; then
    printf "\033[1;32m ✔ $x\n\033[0m"
    ((Passed+=1))
else
    printf "\033[1;31m ✘ $x\n\033[0m"
    ((Failed+=1))
fi 

}

Passed=0
Failed=0



curl -s -I http://localhost:8081
Test if proxy working
if  curl -s -I http://localhost:8081 > /dev/null;
then 
printf "\033[1;32m ✔ Proxy Is Working\n\033[0m"
else 
printf "\033[1;31m ✘ Proxy is not working\n\033[0m" 
exit 7
fi

# Test URLs from CSV file 
while read line
do
   url=$(echo "$line" | cut -d "," -f 1)
   statusCode=$(echo "$line" | cut -d "," -f 2)
   test_file "$url" "$statusCode"
done < ./testing/input.csv

Total=$(($Passed+$Failed))
printf "\n\033[1;35m ------------------ Result -----------------------\n"

printf "   \033[1;33m Total: $Total\n   \033[1;32m ✔ Passed: $Passed\n   \033[1;31m ✘ Failed: $Failed  \n\n"

if [ $Failed -gt 0 ]
then
    exit 50
fi
