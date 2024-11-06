SELECT @@SERVERNAME AS 'Server_Name'  

--SELECT @@SERVICENAME AS 'Service_Name'

SELECT @@VERSION AS Version_Name 

SELECT @@SERVERNAME AS 'Server_Name' , @@DBTS AS 'DBTS'  

SELECT @@SERVERNAME AS 'Server_Name' , DB_NAME(3) AS 'Database Name', @@DBTS AS 'DBTS'  

exec sp_set_firewall_rule N'Allow Azure', '104.219.107.84', '104.219.107.84'
exec sp_set_firewall_rule N'Allow Azure', '172.18.15.239', '172.18.15.239'
172.18.15.239