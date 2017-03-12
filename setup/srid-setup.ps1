# deploying srid

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
#$Env:DPK_BASE="e:\psoft"
#$Env:PS_CUST_HOME="$Env:DPK_BASE\pt\ps_cust_home"
#$Env:PS_PIA_HOME="$Env:PS_CFG_HOME\webserv\peoplesoft" 
#$Env:WL_HOME="$Env:DPK_BASE\pt\bea\wlserver"
#$Env:WLSADMIN="system"
#$Env:WLSPASS="Passw0rd"
#$Env:WLSCONN="t3://localhost:8000"
#$Env:ELF_FIELDS="date time cs-method cs-uri sc-status cs-username cs(user-agent) s-ip c-ip time-taken bytes cs(X-Forwarded-For)"
#$Env:UTIL_DIR

# add to WLS lib
#jar cf $Env:PS_PIA_HOME\lib\io-psadmin-util-elf.jar $Env:PS_CUST_HOME\class\SRIDLogField.class
Copy-Item $Env:PS_CUST_HOME\class\SRIDLogField.class $Env:PS_PIA_HOME\lib\SRIDLogField.class
javac $Env:PS_PIA_HOME\lib\SRIDLogField.class
jar cf $Env:PS_PIA_HOME\lib\psadmin-io-util-elf.jar $Env:PS_PIA_HOME\lib\SRIDLogField.class

# copy classes
Copy-Item $Env:PS_CUST_HOME\class\io  $Env:PS_PIA_HOME\applications\peoplesoft\PORTAL.war\WEB-INF\classes\io -Recurse -Force

# add filter to web.xml
$path = "$Env:PS_PIA_HOME\applications\peoplesoft\PORTAL.war\WEB-INF\web.xml"
$xml = [xml] (Get-Content $path)
# filter
$test = $xml."web-app".filter | Where-Object {$_."filter-name" -eq "SRIDAttributeFilter"}
if (!$test) {
	$xmlFilter = $xml.CreateElement("filter",$xml.DocumentElement.NamespaceURI)
	
	$xmlFilterName = $xml.CreateElement("filter-name",$xml.DocumentElement.NamespaceURI)
	$text = $xml.CreateTextNode("SRIDAttributeFilter")
	$xmlFilterName.AppendChild($text)
	$xmlFilter.AppendChild($xmlFilterName)
	
	$xmlFilterClass = $xml.CreateElement("filter-class",$xml.DocumentElement.NamespaceURI)
	$text = $xml.CreateTextNode("io.psadmin.SRIDAttributeFilter")
	$xmlFilterClass.AppendChild($text)
	$xmlFilter.AppendChild($xmlFilterClass)
	
	$xmlAsync = $xml.CreateElement("async-supported",$xml.DocumentElement.NamespaceURI)
	$text = $xml.CreateTextNode("true")
	$xmlAsync.AppendChild($text)
	$xmlFilter.AppendChild($xmlAsync)
	
	$xmlInitParam = $xml.CreateElement("init-param",$xml.DocumentElement.NamespaceURI)
	$xmlParamName = $xml.CreateElement("param-name",$xml.DocumentElement.NamespaceURI)
	$text = $xml.CreateTextNode("logFence")
	$xmlParamName.AppendChild($text)
	$xmlInitParam.AppendChild($xmlParamName)
	$xmlParamValue = $xml.CreateElement("param-value",$xml.DocumentElement.NamespaceURI)
	$text = $xml.CreateTextNode("0")
	$xmlParamValue.AppendChild($text)
	$xmlInitParam.AppendChild($xmlParamName)
	$xmlInitParam.AppendChild($xmlParamValue)
	$xmlFilter.AppendChild($xmlInitParam)
		
	$xml."web-app".InsertBefore($xmlFilter,$xml."web-app".listener)
	
	$xmlFilter = $xml.CreateElement("filter-mapping",$xml.DocumentElement.NamespaceURI)
	
	$xmlFilterName = $xml.CreateElement("filter-name",$xml.DocumentElement.NamespaceURI)
	$text = $xml.CreateTextNode("SRIDAttributeFilter")
	$xmlFilterName.AppendChild($text)
	$xmlFilter.AppendChild($xmlFilterName)
	
	$xmlUrl = $xml.CreateElement("url-pattern",$xml.DocumentElement.NamespaceURI)
	$text = $xml.CreateTextNode("/*")
	$xmlUrl.AppendChild($text)
	$xmlFilter.AppendChild($xmlUrl)
	
	$xmlDisp = $xml.CreateElement("dispatcher",$xml.DocumentElement.NamespaceURI)
	$text = $xml.CreateTextNode("REQUEST")
	$xmlDisp.AppendChild($text)
	$xmlFilter.AppendChild($xmlDisp)
	
	$xmlDisp = $xml.CreateElement("dispatcher",$xml.DocumentElement.NamespaceURI)
	$text = $xml.CreateTextNode("FORWARD")
	$xmlDisp.AppendChild($text)
	$xmlFilter.AppendChild($xmlDisp)
	
	$xmlDisp = $xml.CreateElement("dispatcher",$xml.DocumentElement.NamespaceURI)
	$text = $xml.CreateTextNode("INCLUDE")
	$xmlDisp.AppendChild($text)
	$xmlFilter.AppendChild($xmlDisp)
	
	$xmlDisp = $xml.CreateElement("dispatcher",$xml.DocumentElement.NamespaceURI)
	$text = $xml.CreateTextNode("ERROR")
	$xmlDisp.AppendChild($text)
	$xmlFilter.AppendChild($xmlDisp)
	
	$xml."web-app".InsertBefore($xmlFilter,$xml."web-app".listener)
		
	$xml.Save($path)
}

# wlst access log setup
Invoke-CmdScript "$Env:WL_HOME\server\bin\setWLSEnv.cmd"
java weblogic.WLST $Env:UTIL_DIR\setup\srid-wlst.py $Env:WLSADMIN $Env:WLSPASS $Env:WLSCONN $Env:ELF_FIELDS

Write-Host "Deployment complete, restart PIA to take effect." 


