#! /bin/bash

# Solicitar privilegios de sudo al inicio
sudo -v

echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/99-temp-install


while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--desktop)
            # Instalacion de escritorio
            DESKTOP_PRESET="true"
        ;;
        -l|--laptop)
            # Instalacion de escritorio
            LAPTOP_PRESET="true"
        ;;
    esac
done


# Detectar la distro que se esta utilizano
distro=$(grep "^PRETTY_NAME" /etc/os-release | cut -d "=" -f 2- | sed 's/"//g')

# Lanzar una excepcion si no se usa un Arch Based
if [[ "$distro" != "Arch Linux" && "$distro" != "CachyOS" ]]; then
    echo "Este script solo funciona en Arch o Cachy"
    return 1
fi

# Verificar Arch
if [[ "$distro" == "Arch Linux"  ]]; then
    isArch="true"
fi

# Verificar Cachy
if [[ "$distro" == "CachyOS"  ]]; then
    isCachy="true"
fi


echo -e "\e[34m ###################################################################################### \e[0m"
echo -e "\e[34m ###################################################################################### \e[0m"
echo -e "\e[34m ### ╻┏┓╻┏━┓╺┳╸┏━┓╻  ┏━┓┏━╸╻┏━┓┏┓╻   ┏┓ ┏━┓┏━┓╻┏━╸┏━┓                               ### \e[0m"
echo -e "\e[34m ### ┃┃┗┫┗━┓ ┃ ┣━┫┃  ┣━┫┃  ┃┃ ┃┃┗┫   ┣┻┓┣━┫┗━┓┃┃  ┣━┫                               ### \e[0m"
echo -e "\e[34m ### ╹╹ ╹┗━┛ ╹ ╹ ╹┗━╸╹ ╹┗━╸╹┗━┛╹ ╹   ┗━┛╹ ╹┗━┛╹┗━╸╹ ╹                               ### \e[0m"
echo -e "\e[34m ###################################################################################### \e[0m"
echo -e "\e[34m ###################################################################################### \e[0m"




# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Sincronizancion inicial de DB
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ] Actualizando DB de paquetes pacman \e[0m"
echo -e "\e[32m ################################# \e[0m"

# TODO : RECUERDAME!
sudo pacman -Syu --noconfirm


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Descargar reflector y definir mirrors
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ] Descargando Reflector \e[0m"
echo -e "\e[32m ################################# \e[0m"

sudo pacman -S reflector wget --needed --noconfirm

echo -e "\e[33m ################################# \e[0m"
echo -e "\e[33m ### [ Warn ] Actualizando lista de mirrors \e[0m"
echo -e "\e[33m ################################# \e[0m"

# TODO : RECUERDAME!
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar Mega
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ] Instalando MEGA \e[0m"
echo -e "\e[32m ################################# \e[0m"

wget https://mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst -P ~/ && sudo pacman -U --needed --noconfirm "$HOME/megasync-x86_64.pkg.tar.zst"

sudo pacman -Syu --needed --noconfirm


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar herramientas de compilacion basicas
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Instalando paquetes basicos de compilacion \e[0m"
echo -e "\e[32m ################################# \e[0m"

sudo pacman -S --needed --noconfirm base-devel linux-headers git rust 


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Configurar pacman 
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Aplicando configuraciones de pacman \e[0m"
echo -e "\e[32m ################################# \e[0m"

enable_pacman_option() {
    local option=$1
    if grep -q "^#$option" "/etc/pacman.conf"; then
        sudo sed -i "s/^#$option/$option/" "/etc/pacman.conf"
        echo "[+] Opción '$option' habilitada."
    else
        echo "[!] La opción '$option' ya está activa o no se encontró."

        if ! grep -q "$option" "/etc/pacman.conf"; then

            sudo sed -i "/^# Misc options/a ILoveCandy" "/etc/pacman.conf"
            echo "[+] opcion $option agregada!."
        fi
    fi
}

enable_pacman_option "Color"
enable_pacman_option "VerbosePkgLists"
enable_pacman_option "ILoveCandy"

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar Paru (Solo Arch)
if [[ "$isArch" == "true"  ]]; then

    echo -e "\e[32m ################################# \e[0m"
    echo -e "\e[32m ### [ Info ]  Instalando paru \e[0m"
    echo -e "\e[32m ################################# \e[0m"

    mkdir ./tmp
    git clone https://aur.archlinux.org/paru.git ./tmp/paru
    cd ./tmp/paru
    makepkg -si --noconfirm
    cd ../../

fi


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar y configurar fish como shell default
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Instalando fish  \e[0m"
echo -e "\e[32m ################################# \e[0m"

sudo pacman -S --needed --noconfirm fish 


echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Configurando fish como shell por defecto  \e[0m"
echo -e "\e[32m ################################# \e[0m"

sudo usermod -s /bin/fish $USER


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar paquetes de configuracion basica de fish
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Instalando paquetes de ayudas de shell  \e[0m"
echo -e "\e[32m ################################# \e[0m"

sudo pacman -S --needed --noconfirm eza bat rclone openfortivpn openssh udisks2 starship


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar Terminales basicas
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Instalando terminales  \e[0m"
echo -e "\e[32m ################################# \e[0m"

sudo pacman -S --needed --noconfirm kitty alacritty


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar librerias de compilacion
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Instalando librerias de compilacion  \e[0m"
echo -e "\e[32m ################################# \e[0m"
sudo pacman -S --needed --noconfirm gcc cmake ninja make 

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar paquetes basicos
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Instalando paquetes basicos de sistema  \e[0m"
echo -e "\e[32m ################################# \e[0m"
sudo pacman -S --needed --noconfirm jdk21-openjdk \
                                    jdk25-openjdk \
                                    jdk-openjdk \
                                    power-profiles-daemon \
                                    steam \
                                    mangohud \
                                    gamescope \
                                    noto-fonts \
                                    noto-fonts-cjk \
                                    noto-fonts-emoji \
                                    noto-fonts-extra \
                                    ttf-noto-nerd \
                                    flatpak \
                                    alsa-utils \
                                    keepassxc \
                                    fakeroot \
                                    arch-install-scripts \
                                    tealdeer \
                                    gst-plugins-good \
                                    gst-plugins-bad \
                                    gst-plugins-ugly \
                                    gst-libav \
                                    nvtop \
                                    btop \
                                    vlc \
                                    vlc-plugins-all \
                                    android-tools \
                                    totem \
                                    picard \
                                    yt-dlp \
                                    firefox \
                                    fastfetch \
                                    blender \
                                    fuse2 \
                                    fuse3 \
                                    gparted \
                                    kdiskmark


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar paquetes basicos
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Instalando drivers graficos \e[0m"
echo -e "\e[32m ################################# \e[0m"
sudo pacman -S --needed --noconfirm intel-media-driver

if [[ "$DESKTOP_PRESET" == "false"  ]]; then

    sudo pacman -S --needed --noconfirm intel-media-driver \
                                        libva-intel-driver \
                                        mesa \
                                        vulkan-intel \
                                        vulkan-nouveau \
                                        vulkan-radeon \
                                        xf86-video-amdgpu \
                                        xf86-video-ati \
                                        xf86-video-nouveau \
                                        xorg-server \
                                        xorg-xinit \
                                        xorg-xhost 

fi

if [[ "$LAPTOP_PRESET" == "true"  ]]; then

    if [[ "$isArch" == "true"  ]]; then

        paru -S --needed --noconfirm    nvidia-580xx-dkms \
                                        dkms \
                                        xorg-server \
                                        xorg-xinit \
                                        nvidia-580xx-utils \
                                        opencl-nvidia-580xx \
                                        lib32-nvidia-580xx-utils \
                                        lib32-opencl-nvidia-580xx \
                                        nvidia-580xx-settings

    fi

    if [[ "$isCachy" == "true"  ]]; then

        sudo pacman -S --needed --noconfirm nvidia-580xx-dkms \
                                            dkms \
                                            xorg-server \
                                            xorg-xinit \
                                            nvidia-580xx-utils \
                                            opencl-nvidia-580xx \
                                            lib32-nvidia-580xx-utils \
                                            lib32-opencl-nvidia-580xx \
                                            nvidia-580xx-settings

    fi

fi

if [[ "$DESKTOP_PRESET" == "true"  ]]; then

    sudo pacman -S --needed --noconfirm mesa \
                                        lib32-mesa \
                                        xf86-video-amdgpu \
                                        xf86-video-ati \
                                        vulkan-radeon \
                                        lib32-vulkan-radeon \
                                        xorg-server \
                                        xorg-xinit \
                                        xorg-xhost 

fi


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Cargando cache de tealdeer
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Inicializando cache de tealdeer  \e[0m"
echo -e "\e[32m ################################# \e[0m"
tldr --update


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar paquetes de la AUR que solo estan en cachy
if [[ "$isCachy" == "true"  ]]; then

    echo -e "\e[32m ################################# \e[0m"
    echo -e "\e[32m ### [ Info ]  Instalando paquetes que solo estan en cachy \e[0m"
    echo -e "\e[32m ################################# \e[0m"

    sudo pacman -S --needed --noconfirm fresh-editor brave-bin vesktop

fi


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar paquetes de la AUR que no estan en los repos de Arch
if [[ "$isArch" == "true"  ]]; then

    echo -e "\e[32m ################################# \e[0m"
    echo -e "\e[32m ### [ Info ]  Instalando paquetes que solo estan en la AUR \e[0m"
    echo -e "\e[32m ################################# \e[0m"

    paru -S --needed --noconfirm fresh-editor-bin brave-bin vesktop

fi


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar paquetes basicos de la aur
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Instalando paquetes de la AUR \e[0m"
echo -e "\e[32m ################################# \e[0m"

paru -S --needed --noconfirm visual-studio-code-bin


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Instalar paquetes basicos de flatpak 
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Instalando paquetes de flatpak \e[0m"
echo -e "\e[32m ################################# \e[0m"

flatpak install -y flathub net.davidotek.pupgui2
flatpak install -y flathub org.vinegarhq.Sober
flatpak install -y flathub com.stremio.Stremio
flatpak install -y flathub it.mijorus.gearlever


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Configurar directorios home
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Configurando directorios home \e[0m"
echo -e "\e[32m ################################# \e[0m"

cat <<EOF > ~/.config/user-dirs.dirs
XDG_DESKTOP_DIR="\$HOME/Desktop"
XDG_DOWNLOAD_DIR="\$HOME/Downloads"
XDG_TEMPLATES_DIR="\$HOME/Templates"
XDG_PUBLICSHARE_DIR="\$HOME/Public"
XDG_DOCUMENTS_DIR="\$HOME/Documents"
XDG_MUSIC_DIR="\$HOME/Music"
XDG_PICTURES_DIR="\$HOME/Pictures"
XDG_VIDEOS_DIR="\$HOME/Videos"
XDG_PROJECTS_DIR="\$HOME/Projects"
EOF

cat <<EOF > ~/.config/user-dirs.locale
en_US
EOF

rm -rf ~/Escritorio ~/Documentos ~/Descargas ~/Música ~/Imágenes ~/Vídeos ~/Público ~/Plantillas ~/Proyectos

mkdir -p ~/Desktop ~/Downloads ~/Templates ~/Public ~/Documents ~/Music ~/Pictures ~/Videos ~/Projects 


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Quitar auto-ganancia de microfono
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Quitando auto-ganancia de microfono \e[0m"
echo -e "\e[32m ################################# \e[0m"

cat <<EOF > ~/.config/wireplumber/wireplumber.conf.d/99-stop-auto-gain.conf
monitor.alsa.rules = [
  {
    matches = [
      {
        -- Esto aplica a todas las fuentes de audio (micrófonos)
        node.name = "~alsa_input.*"
      }
    ],
    actions = {
      update-props = {
        -- Evita que PulseAudio/PipeWire cambie el volumen por software
        ["channelmix.upmix"] = false,
        ["session.suspend-on-idle"] = false,
        -- Bloquea el volumen para que no sea manipulado externamente
        ["node.pause-on-idle"]      = false,
      }
    }
  }
]
EOF

systemctl --user restart pipewire wireplumber


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Configurar dot configs
echo -e "\e[32m ################################# \e[0m"
echo -e "\e[32m ### [ Info ]  Instalando y configurando chezmoi \e[0m"
echo -e "\e[32m ################################# \e[0m"

sudo pacman -S --needed --noconfirm chezmoi

cat <<EOF > ~/.config/chezmoi/chezmoi.toml
[edit]
    command = "fresh"
EOF

chezmoi init --apply https://github.com/KernelOso/dotFiles.git

sudo rm /etc/sudoers.d/99-temp-install