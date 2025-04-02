;
; Zona IESCASTILLODELUNA.ES
;
@  IN SOA   ns1 hostmaster (
               1     ; Serial
          604800     ; Refresh
           86400     ; Retry
         2419200     ; Expire
           86400 )   ; Negative Cache TTL
;
@        IN    TXT   "Ejemplo de definición de la zona IESCASTILLODELUNA.ES"
               NS    ns1
               NS    ns2
               MX    10 mail
ns1      IN    A     192.168.255.1
mail     IN    A     192.168.255.10
smtp     IN    CNAME mail
pop3     IN    CNAME mail
imap     IN    CNAME mail
www      IN    A     192.168.255.20
; La máquina externo.iescastillodeluna.es está en otra red
externo  IN    A     80.80.80.80
ftp      IN    CNAME www
*        IN    CNAME www
