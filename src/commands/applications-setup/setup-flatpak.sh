#!/bin/sh -e

. ../common-script.sh

setup_flatpak() {
    echo "Install Flatpak if not already installed..."
    if ! command_exists flatpak; then
        case "$PACKAGER" in
            pacman)
                $ESCALATION_TOOL "$PACKAGER" -S --needed --noconfirm flatpak
                echo "Flatpak installed and remote setup automatically by pacman."
                ;;
            apt-get|nala)
                $ESCALATION_TOOL "$PACKAGER" install -y flatpak
                ;;
            dnf)
                $ESCALATION_TOOL "$PACKAGER" install -y flatpak # Fedora should have flatpak already installed, this is just a failsafe
                ;;
            zypper)
                $ESCALATION_TOOL "$PACKAGER" install -y flatpak
                ;;
            yum)
                $ESCALATION_TOOL "$PACKAGER" install -y flatpak
                ;;
            xbps-install)
                $ESCALATION_TOOL "$PACKAGER" install -S flatpak
                ;;
            nix-env)
                $ESCALATION_TOOL "$PACKAGER" -iA nixpkgs.flatpak
                ;;
            *)
                echo "Unsupported package manager: $PACKAGER"
                exit 1
                ;;
        esac
    else
        echo "Flatpak is already installed."
    fi

    if [ "$PACKAGER" != "pacman" ]; then # Since pacman handles this automatically i deicded to skip it for pacman
        echo "Setting up Flatpak repositories..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi

    if [ "$PACKAGER" = "apt-get" ] || [ "$PACKAGER" = "nala" ]; then
        echo "Would you like to install graphical store plugins for Flatpak? Select your DE or click Skip to ignore"
        options=("GNOME" "KDE Plasma" "Skip")
        select opt in "${options[@]}"; do
            case $opt in
                "GNOME")
                    $ESCALATION_TOOL "$PACKAGER" install -y gnome-software-plugin-flatpak
                    break
                    ;;
                "KDE Plasma")
                    $ESCALATION_TOOL "$PACKAGER" install -y plasma-discover-backend-flatpak
                    break
                    ;;
                "Skip")
                    echo "Skipping graphical store plugin installation."
                    break
                    ;;
                *)
                    echo "Invalid option $REPLY"
                    ;;
            esac
        done
    fi
}

checkEnv
setup_flatpak
