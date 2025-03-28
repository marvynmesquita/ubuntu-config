#!/bin/bash

# Pasta de backup
BACKUP_DIR="backup_ubuntu"

# Função para verificar conexão com a internet
check_internet() {
    echo "Verificando conexão com a Internet..."
    while ! ping -c 1 -W 1 google.com &> /dev/null; do
        echo "Sem conexão com a Internet. Tentando novamente em 5 segundos..."
        sleep 5
    done
    echo "Conexão com a Internet detectada!"
}

# Exibir menu amigável
menu() {
    echo "---------------------------------------"
    echo "       Restaurador do Ubuntu"
    echo "---------------------------------------"
    echo "Bem-vindo! O script irá restaurar seu sistema com base nos arquivos de backup."
    echo "Por favor, aguarde enquanto tudo é preparado."
    echo
}

# Restaurar configurações completas do GNOME
restore_gnome() {
    echo "Restaurando configurações do GNOME..."
    dconf load / < "$BACKUP_DIR/gnome-settings.dconf"
    echo "Restaurando configurações específicas da dock e tema..."
    dconf load /org/gnome/shell/ < "$BACKUP_DIR/gnome-shell-settings.dconf"
    dconf load /org/gnome/shell/extensions/ < "$BACKUP_DIR/gnome-extensions-settings.dconf"
}

# Instalar extensões do GNOME
install_gnome_extensions() {
    echo "Instalando extensões do GNOME..."
    if [ -f "$BACKUP_DIR/extensoes_gnome.txt" ]; then
        while read -r url; do
            echo "Instalando extensão: $url"
            # Substitua o comentário abaixo pelo comando adequado para instalar extensões do GNOME
            # Exemplos: Usar `gnome-extensions` CLI ou outro método
        done < "$BACKUP_DIR/extensoes_gnome.txt"
    else
        echo "Arquivo extensoes_gnome.txt não encontrado no backup."
    fi
}

# Restaurar pacotes e configurações do sistema
restore_system() {
    echo "Atualizando sistema e instalando pacotes necessários..."
    sudo apt update && sudo apt upgrade -y
    sudo dpkg --set-selections < "$BACKUP_DIR/pacotes_instalados.txt"
    sudo apt-get dselect-upgrade -y

    echo "Restaurando arquivos de configuração..."
    sudo cp "$BACKUP_DIR/fstab.backup" /etc/fstab
    cp "$BACKUP_DIR/bashrc.backup" ~/.bashrc

    echo "Restaurando repositórios..."
    sudo cp "$BACKUP_DIR/sources.list.backup" /etc/apt/sources.list
    sudo cp -r "$BACKUP_DIR/sources.list.d.backup" /etc/apt/sources.list.d
}

# Execução principal
clear
menu
check_internet
restore_system
restore_gnome
install_gnome_extensions

echo "Restauração concluída! Reinicie seu sistema para aplicar todas as alterações."
