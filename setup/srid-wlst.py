import sys

conn_user = sys.argv[1]
conn_pass = sys.argv[2]
conn_host  = sys.argv[3]
elf_fields = sys.argv[4]
log_buffer = 0  # Set to 0 for testing

connect(conn_user, conn_pass, conn_host);
edit()
cd('Servers/PIA/WebServer/PIA/WebServerLog/PIA')
ls()
startEdit()
set('LoggingEnabled',true)
set('LogFileFormat','extended')
set('ELFFields',elf_fields)
set('BufferSizeKB',log_buffer)
ls()
save()
activate()
disconnect();
exit();