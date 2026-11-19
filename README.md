# scrcpy 5.0.1 para Fedora x86_64

![scrcpy](https://img.shields.io/badge/scrcpy-v5.0.1-orange)
![Platform](https://img.shields.io/badge/Platform-x86__64-blue)
![Fedora](https://img.shields.io/badge/Fedora-42+-green)
![License](https://img.shields.io/badge/License-Apache%202.0-blue)

Paquete `.rpm` de **scrcpy 5.0.1** compilado para **Fedora x86_64 (64 bits)**.

---

## 📋 Requisitos

- **Fedora 42** o superior (x86_64)
- Dependencias de ejecución: `SDL3`, `ffms2`, `libusb1`, `libavdevice-free`, `libdrm`

---

## 🚀 Instalación rápida

```bash
# Descargar el RPM desde el Release más reciente
sudo dnf install ./scrcpy-5.0.1-1.*.x86_64.rpm
```

---

## ✅ Verificación

```bash
scrcpy --version
# Salida esperada: scrcpy 5.0.1
```

---

## 🔨 Recompilar desde cero

Usa el script `build_scrcpy_fedora.sh` incluido en este repositorio:

```bash
chmod +x build_scrcpy_fedora.sh
./build_scrcpy_fedora.sh
```

El script **detecta automáticamente la última versión estable** desde la API de GitHub y la compila.

---

## 📄 Licencia

scrcpy es software libre bajo la [licencia Apache 2.0](https://github.com/Genymobile/scrcpy/blob/master/LICENSE).

---

## 📞 Contacto

- **Autor:** Jose Andres Mamani Mollericona
- **GitHub:** [@JOSSEL01](https://github.com/JOSSEL01)
- **Repositorio:** [fedora-scrcpy-x64](https://github.com/JOSSEL01/fedora-scrcpy-x64)
