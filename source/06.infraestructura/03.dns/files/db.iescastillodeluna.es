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
ns1      IN    A     80.80.80.81
ns2      IN    A     80.80.80.91
mail     IN    A     194.179.100.201
;
$TTL  300
;
smtp     IN    CNAME mail
pop3     IN    CNAME mail
imap     IN    CNAME mail
www      IN    A     80.80.80.80
ftp      IN    CNAME www
*        IN    CNAME www
