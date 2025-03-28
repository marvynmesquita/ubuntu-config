#!/bin/bash

# Pasta de backup
BACKUP_DIR="backup_ubuntu"
mkdir -p "$BACKUP_DIR"

echo "Exportando lista de pacotes instalados..."
dpkg --get-selections > "$BACKUP_DIR/pacotes_instalados.txt"

echo "Exportando repositórios..."
cp /etc/apt/sources.list "$BACKUP_DIR/sources.list.backup"
cp -r /etc/apt/sources.list.d "$BACKUP_DIR/sources.list.d.backup"

echo "Exportando configurações completas do GNOME..."
dconf dump / > "$BACKUP_DIR/gnome-settings.dconf"

echo "Exportando configurações específicas da dock e tema..."
dconf dump /org/gnome/shell/ > "$BACKUP_DIR/gnome-shell-settings.dconf"
dconf dump /org/gnome/shell/extensions/ > "$BACKUP_DIR/gnome-extensions-settings.dconf"

echo "Exportando URLs das extensões do GNOME..."
EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"
> "$BACKUP_DIR/extensoes_gnome.txt"  # Limpa o arquivo antes de escrever

if [ -d "$EXTENSIONS_DIR" ]; then
    for extension in "$EXTENSIONS_DIR"/*; do
        metadata_file="$extension/metadata.json"
        if [ -f "$metadata_file" ]; then
            extension_url=$(grep -oP '"url":\s*"\K[^"]+' "$metadata_file")
            if [ -n "$extension_url" ]; then
                echo "$extension_url" >> "$BACKUP_DIR/extensoes_gnome.txt"
            else
                echo "Extensão em $extension não tem URL nos metadados." >> "$BACKUP_DIR/extensoes_gnome.txt"
            fi
        fi
    done
    echo "URLs exportadas para $BACKUP_DIR/extensoes_gnome.txt"
else
    echo "Nenhuma extensão do GNOME encontrada."
fi

echo "Exportando arquivos personalizados..."
cp ~/.bashrc "$BACKUP_DIR/bashrc.backup"
cp /etc/fstab "$BACKUP_DIR/fstab.backup"

echo "Backup concluído! Arquivos salvos em $BACKUP_DIR."
