import sys

connect(sys.argv[1],sys.argv[2],sys.argv[3]);
edit()
cd('Servers/PIA/WebServer/PIA/WebServerLog/PIA')
startEdit()
set('LoggingEnabled',true)
set('LogFileFormat','extended')
set('ELFFields',sys.argv[4])
save()
activate()
disconnect();
exit();