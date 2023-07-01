#!/bin/bash

if ! [ -x "$(command -v ifconfig)" ]; then
    echo 'Error: ifconfig is not installed.' >&2
    exit 1
else
    echo 'ifconfig is installed.'
fi

show_interface_info() {
    ifconfig -a
}

configure_ip_and_mask_temporarily() {
    interface=$1
    ip=$2
    mascara=$3

    if [ -z "$interface" ]; then
        echo "interface is empty."
        exit 1
    fi

    if [ -z "$ip" ]; then
        echo "ip is empty."
        exit 1
    fi

    if [ -z "$mascara" ]; then
        echo "mascara is empty."
        exit 1
    fi

    ifconfig $interface $ip netmask $mascara
    echo "interface '$interface' has been configured with the $ip and mask $mascara."
}

enable_interface() {
    interface=$1
    if [ -z "$interface" ]; then
        echo "interface is empty"
        exit 1
    fi

    if ! ifconfig $interface up >/dev/null 2>&1; then
        echo "Error: Failed to enable the interface '$interface'." >&2
        exit 1
    fi

    echo "interface '$interface' has been enabled."
}

disable_interface() {
    interface=$1
    if [ -z "$interface" ]; then
        echo "interface is empty"
        exit 1
    fi

    if ! ifconfig $interface down >/dev/null 2>&1; then
        echo "Error: Failed to disable the interface '$interface'." >&2
        exit 1
    fi

    echo "interface '$interface' has been disabled."
}

configure_ip_and_mask_permamently() {
    interface=$1
    ip=$2
    mascara=$3

    if [ -z "$interface" ]; then
        echo "interface is empty."
        exit 1
    fi

    if [ -z "$ip" ]; then
        echo "ip is empty."
        exit 1
    fi

    if [ -z "$mascara" ]; then
        echo "mascara is empty."
        exit 1
    fi

    if [ ! -d "/etc/network" ]; then
        echo "Error: /etc/network does not exist." >&2
        exit 1
    else
        cp /etc/network/interfaces /etc/network/interfaces.backup
    fi

    sh -c "cat <<EOF >> /etc/network/interfaces
iface $interface inet static
    address $ip
    netmask $mascara
EOF"

    sudo service networking restart
}

get_dhcp_ip() {
    interface=$1

    if [ -z "$interface" ]; then
        echo "interface is empty."
        exit 1
    fi

    dhclient $interface

    echo "interface '$interface' has been configured with the dhcp."
}

show_table_routes() {
    ip route show table main
}

add_gateway() {
    ip=$1

    if [ -z "$ip" ]; then
        echo "ip is empty."
        exit 1
    fi

    ip route add default via $ip

    echo "gateway '$ip' has been added."
}

delete_gateway() {
    ip=$1

    if [ -z "$ip" ]; then
        echo "ip is empty."
        exit 1
    fi

    ip route del default via $ip

    echo "gateway '$ip' has been deleted."
}

menu="
Gerência de Rede
Escolha uma das opções abaixo: 
1 – Informações das Interfaces de Rede
2 – Configurar o IP e a Máscara de forma temporária
3 – Habilitar Interface de Rede
4 – Desabilitar Interface de Rede
5 – Configurar as configurações de rede de forma permanente
6 – Obter IP via DHCP
7 – Tabela de Rotas
8 – Adicionar Gateway
9 – Deletar gateway
10 – Sair
"

echo "$menu"
while true; do
    read -p "Digite a opção desejada: " option
    case $option in
    1)
        show_interface_info
        exit 1
        ;;
    2)
        read -p "Digite o nome da interface: " interface
        read -p "Digite o IP: " ip
        read -p "Digite a máscara: " mascara
        configure_ip_and_mask_temporarily $interface $ip $mascara
        ;;
    3)
        read -p "Digite o nome da interface: " interface
        enable_interface $interface
        ;;
    4)
        read -p "Digite o nome da interface: " interface
        disable_interface $interface
        ;;
    5)
        read -p "Digite o nome da interface: " interface
        read -p "Digite o IP: " ip
        read -p "Digite a máscara: " mascara
        configure_ip_and_mask_permamently $interface $ip $mascara
        ;;
    6)
        read -p "Digite o nome da interface: " interface
        get_dhcp_ip $interface
        ;;
    7)
        show_table_routes
        ;;
    8)
        read -p "Digite o IP: " ip
        add_gateway $ip
        ;;
    9)
        read -p "Digite o IP: " ip
        delete_gateway $ip
        ;;
    10)
        exit 0
        ;;
    s)
        echo "$menu"
        ;;
    *)
        echo "Opção inválida"
        exit 1
        ;;

    esac
done
