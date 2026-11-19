#!/bin/bash
# ============================================
# Compilador de scrcpy para Fedora x86_64
# Genera un paquete .rpm
# Descarga automáticamente la última versión estable
# ============================================
# Autor: Jose Andres Mamani Mollericona
# GitHub: JOSSEL01
# ============================================

set -e

# ============================================
# CONFIGURACIÓN
# ============================================
OUTPUT_DIR="$HOME/scrcpy-rpm-output"
SPEC_NAME="scrcpy.spec"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Compilador de scrcpy para Fedora x64${NC}"
echo -e "${GREEN}  (Detecta última versión automáticamente)${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================
# [0/6] DETECTAR LA ÚLTIMA VERSIÓN ESTABLE
# ============================================
echo -e "\n${YELLOW}[0/6] Buscando la última versión estable de scrcpy...${NC}"

LATEST_TAG=$(curl -s https://api.github.com/repos/Genymobile/scrcpy/releases/latest \
    | grep '"tag_name":' \
    | sed -E 's/.*"v([^"]+)".*/\1/')

if [ -z "$LATEST_TAG" ]; then
    echo -e "${RED}Error: No se pudo detectar la última versión.${NC}"
    echo -e "${YELLOW}Verifica tu conexión a internet o la API de GitHub.${NC}"
    exit 1
fi

SCRCPY_VERSION="$LATEST_TAG"
echo -e "${GREEN}✓ Última versión detectada: $SCRCPY_VERSION${NC}"

# ============================================
# [1/6] INSTALAR DEPENDENCIAS
# ============================================
echo -e "\n${YELLOW}[1/6] Instalando dependencias...${NC}"

if ! dnf repolist 2>/dev/null | grep -q rpmfusion-free; then
    echo -e "${YELLOW}Habilitando RPM Fusion...${NC}"
    sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
fi

sudo dnf install -y rpm-build rpmdevtools meson gcc make wget tar curl \
    SDL3-devel ffms2-devel libusb1-devel libavdevice-free-devel \
    libdrm-devel

echo -e "${GREEN}✓ Dependencias instaladas${NC}"

# ============================================
# [2/6] PREPARAR ÁRBOL DE RPMBUILD Y FUENTES
# ============================================
echo -e "\n${YELLOW}[2/6] Preparando fuentes...${NC}"

rpmdev-setuptree
cd ~/rpmbuild/SOURCES

TARBALL="scrcpy-${SCRCPY_VERSION}.tar.gz"
if [ ! -f "$TARBALL" ]; then
    wget "https://github.com/Genymobile/scrcpy/archive/refs/tags/v${SCRCPY_VERSION}.tar.gz" -O "$TARBALL"
else
    echo -e "${GREEN}✓ Tarball ya existe${NC}"
fi

SERVER="scrcpy-server-v${SCRCPY_VERSION}"
if [ ! -f "$SERVER" ]; then
    wget "https://github.com/Genymobile/scrcpy/releases/download/v${SCRCPY_VERSION}/${SERVER}" -O "$SERVER"
else
    echo -e "${GREEN}✓ Servidor precompilado ya existe${NC}"
fi

echo -e "${GREEN}✓ Fuentes preparadas${NC}"

# ============================================
# [3/6] GENERAR ARCHIVO .SPEC (CON CORRECCIONES)
# ============================================
echo -e "\n${YELLOW}[3/6] Generando archivo .spec...${NC}"

cat > ~/rpmbuild/SPECS/$SPEC_NAME << EOF
Name:           scrcpy
Version:        ${SCRCPY_VERSION}
Release:        1%{?dist}
Summary:        Display and control your Android device
License:        Apache-2.0
URL:            https://github.com/Genymobile/scrcpy
Source0:        scrcpy-%{version}.tar.gz
Source1:        scrcpy-server-v%{version}

# Corrección para el error: Vacía %files archivo debugsourcefiles.list
%global debug_package %{nil}

BuildRequires:  meson gcc make
BuildRequires:  SDL3-devel ffms2-devel libusb1-devel libavdevice-free-devel libdrm-devel

%description
scrcpy displays and controls Android devices via USB or TCP/IP.

%prep
%autosetup -n scrcpy-%{version}

%build
%meson -Dprebuilt_server=%{SOURCE1} --buildtype=release --strip -Db_lto=true
%meson_build

%install
%meson_install

%files
%{_bindir}/scrcpy
%{_datadir}/scrcpy
%{_mandir}/man1/scrcpy.1*
%{_datadir}/applications/scrcpy*.desktop
# Comodín para todos los iconos de la app (scrcpy.png, disconnected.png, etc.)
%{_datadir}/icons/hicolor/*/apps/*.png
%{_datadir}/bash-completion/completions/scrcpy
%{_datadir}/zsh/site-functions/_scrcpy

%changelog
* $(LC_ALL=C date +'%a %b %d %Y') Jose Andres Mamani Mollericona <jossel01@github.com> - ${SCRCPY_VERSION}-1
- Build scrcpy ${SCRCPY_VERSION} for Fedora x86_64
EOF

echo -e "${GREEN}✓ .spec generado${NC}"

# ============================================
# [4/6] CONSTRUIR EL RPM
# ============================================
echo -e "\n${YELLOW}[4/6] Construyendo el paquete RPM...${NC}"
echo -e "${YELLOW}Esto puede tardar unos minutos...${NC}"

rpmbuild -ba ~/rpmbuild/SPECS/$SPEC_NAME

echo -e "${GREEN}✓ RPM construido${NC}"

# ============================================
# [5/6] COPIAR RESULTADO
# ============================================
echo -e "\n${YELLOW}[5/6] Copiando RPM a $OUTPUT_DIR...${NC}"

mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR"/scrcpy-*.rpm
find ~/rpmbuild/RPMS -name "scrcpy-*.rpm" -exec cp {} "$OUTPUT_DIR/" \;

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}¡COMPILACIÓN COMPLETADA!${NC}"
echo -e "${GREEN}========================================${NC}"
ls -lh "$OUTPUT_DIR"/scrcpy-*.rpm 2>/dev/null
echo ""
echo -e "${YELLOW}Para instalar en Fedora:${NC}"
echo "  sudo dnf install $OUTPUT_DIR/scrcpy-${SCRCPY_VERSION}-1.*.x86_64.rpm"
echo ""
