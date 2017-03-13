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
#$Env:WLSADMIN="system"
#$Env:WLSPASS="Passw0rd"
#$Env:WLSCONN="t3://localhost:8000"
#$Env:ELF_FIELDS="date time cs-method cs-uri sc-status cs-username cs(user-agent) s-ip c-ip time-taken bytes cs(X-Forwarded-For)"


# compile
Invoke-CmdScript "${Env:PS_PIA_HOME}\bin\setEnv.cmd"
$Env:CLASSPATH="${Env:PS_PIA_HOME}\applications\peoplesoft\PORTAL.war\WEB-INF\classes${env:CLASSPATH}"
[Void][System.IO.Directory]::CreateDirectory("${Env:PS_CUST_HOME}\class") 
javac $(Get-ChildItem -Path $Env:UTIL_DIR\src\main\java -Filter *.java -Recurse | % {$_.Fullname}) -d $Env:PS_CUST_HOME\class