#改变工作目录
Push-Location
$curpwd = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location -Path $curpwd

#加载配置文件及加载函数库
. ./config.ps1
. ./machine.ps1

#检查存放数据的repo是否下载，如果没下载则下载下来
Write-Debug $DB_PATH
If (-not (Test-Path $DB_PATH)){
    new-item -path $DB_PATH -itemtype "directory" -force
}
$repo_dir = (Resolve-Path $DB_PATH).Path 
$repo_dir = $repo_dir -replace '\\','/'
Write-Host $repo_dir
$repo_git_dir = $repo_dir + "/.git";
if (-not (Test-Path $repo_git_dir)){
	$git_cmd = "git clone $DB_REPO $repo_dir"
}else{
	$git_cmd = "git --git-dir=$repo_git_dir pull origin master" 
}
Write-Debug $git_cmd
sh --login -c "$git_cmd"

#第一次运行程序则生成此机器的UUID和配置文件等
if (($MACHINE_UUID -eq $null) -or ($MACHINE_UUID.trim() -eq "")){
	$MACHINE_UUID = create_machine $DB_PATH $MACHINE_NAME
	$MACHINE_UUID | %{ Write-Debug $_ }
	set_config_value ".\config.ps1" "MACHINE_UUID" "$MACHINE_UUID"
}
#检查repo中是否已经有相关UUID文件
$machine_path = "$DB_PATH\$MACHINE_UUID"
if (-not (Test-Path $machine_path)){
	Pop-Location
	throw "错误：",$MACHINE_UUID,"在配置文件中存在，但是在数据库中却没有找到。"
	exit 1
}

#在repo中提取执行任务
#向repo中写入本机的在线状态
report_status "$machine_path\report.log"


Pop-Location

