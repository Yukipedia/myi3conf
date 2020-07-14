VBoxManage startvm Windows --type headless 2>/dev/null

sleep 30

VBoxHeadlessPID=$(ps -A | grep VBoxHeadless)
VBoxHeadlessPID=$(echo $VBoxHeadlessPID | cut -d'?' -f1)
echo "VBoxHeadlessPID: ${VBoxHeadlessPID}"
kill -9 $VBoxHeadlessPID

sleep 2
VBoxManage startvm Windows --type headless

$HOME/.rdp/work.sh

while [ $? -ne 0 ]
do
	VBoxHeadlessPID=$(ps -A | grep VBoxHeadless)
	if [ -z "$VBoxHeadlessPID" ]; then
		break
	fi
	$HOME/.rdp/work.sh
done
