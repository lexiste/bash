for i in {1..50}
do
   echo -n "."
   # print all lines with Set-Cookie with the cookie name and value
   #curl -v --silent https://www.ralphlauren.co.uk/register.jsp 2>&1 | grep 'Set-Cookie' | awk '{print $2 $3}' >> rluk.browser_id.values
   curl -v --silent https://www.ralphlauren.fr/orderlogin.jsp 2>&1 | grep 'Set-Cookie' | awk '{print $2 $3}' >> rlfr.orderlogin.values
   # print all the lines with Set-Cookie, but just the value of the cookie
   #curl -v --silent https://www.ralphlauren.co.uk/register.jsp 2>&1 | grep 'Set-Cookie' | awk -F= '{print $2}' | awk -F; '{print $1}' >> rluk.browser_id.values
done
echo "\n50 passes logged to rluk.broswer_id.valuesn\n"

