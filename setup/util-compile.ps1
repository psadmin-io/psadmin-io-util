# Compiling psadmin-io-util

# Functions
Function Invoke-CmdScript([string] $script, [string] $parameters) {
	# Used to export env vars set in sourced cmd file
	$tempFile = [IO.Path]::GetTempFileName()
	cmd /c " $script $parameters && set > $tempFile "
	Get-Content $tempFile | Foreach-Object {
		if($_ -match "^(.*?)=(.*)$")
		{
			Set-Content "env:\$($matches[1])" $matches[2]
		}
	}
	Remove-Item $tempFile
}

# validate environment variables
#$Env:DPK_BASE 
#$Env:PS_CUST_HOME
#$Env:PS_PIA_HOME
#$Env:WL_HOME
#$Env:UTIL_DIR

# compile
Invoke-CmdScript "$Env:WL_HOME\server\bin\setWLSEnv.cmd"
$Env:CLASSPATH+="$Env:PS_PIA_HOME\applications\peoplesoft\PORTAL.war\WEB-INF\classes;"
[Void][System.IO.Directory]::CreateDirectory("$Env:PS_CUST_HOME\class") 
javac $(Get-ChildItem -Path $Env:UTIL_DIR\src\main\java -Filter *.java -Recurse | % {$_.Fullname}) -d $Env:PS_CUST_HOME\class