#!/bin/bash

# (0) Activamos reenvio de paquetes, de esta forma habilitamos la capacidad de
# enrutamiento del sistema operativoi (por defecto es 0, deshabilitado)
sysctl -w net.ipv4.ip_forward=1

# (1) Se eliminan reglas de iptables previas que hubiera y cadenas definidas por el usuario
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# (2) se establecen politicas "duras" por defecto, es decir solo lo que se autorice
#explicitamente podra ingresar o salir del equipo
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
#iptables -I INPUT -j LOG --log-prefix "INPUT DROP: " --log-level 6
#iptables -I FORWARD -j LOG --log-prefix "FORWARD DROP: " --log-level 6

# (3) a la interface lo (localhost) se le permite todo
iptables -I INPUT -i lo -j ACCEPT
iptables -I OUTPUT -o lo -j ACCEPT

# (4) las siguientes reglas permiten salir del equipo
# (output) conexiones nuevas que nosotros solicitamos, conexiones establecidas
# y conexiones relacionadas, y deja entrar (input) solo conexiones establecidas
# y relacionadas.
iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -I FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -I OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# (5) Permitimos el ping hacia el servidor
iptables -I INPUT -p icmp -j ACCEPT

# (6) REGLAS

# Aceptamos acceso al puerto tcp/22 (servicio ssh)
iptables -I INPUT -p tcp --dport 22 -j ACCEPT
