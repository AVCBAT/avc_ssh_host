#!/bin/bash

# Script para ejecutar el análisis de proyectos Docker remotamente en el NAS
# Este script se ejecuta desde cualquier lugar y conecta automáticamente al NAS

echo "🔍 ANÁLISIS REMOTO DE PROYECTOS DOCKER EN NAS"
echo "=============================================="

# Configuración de conexión
NAS_HOST="10.0.0.10"
NAS_PORT="2222"
NAS_USER="avctrust"
SCRIPT_NAME="analyze-docker-projects.sh"
LOCAL_SCRIPT_PATH="./analyze-docker-projects.sh"
REMOTE_SCRIPT_PATH="/tmp/analyze-docker-projects.sh"

echo "🌐 Conectando al NAS: $NAS_USER@$NAS_HOST:$NAS_PORT"
echo ""

# Verificar si el script local existe
if [ ! -f "$LOCAL_SCRIPT_PATH" ]; then
    echo "❌ Error: No se encuentra el script $LOCAL_SCRIPT_PATH"
    echo "   Asegúrate de ejecutar este comando desde la carpeta que contiene el script"
    exit 1
fi

# Función para ejecutar comando SSH
run_ssh_command() {
    ssh -p "$NAS_PORT" "$NAS_USER@$NAS_HOST" "$1"
}

# Función para copiar archivo vía SCP
copy_file_scp() {
    scp -P "$NAS_PORT" "$1" "$NAS_USER@$NAS_HOST:$2"
}

echo "📤 Copiando script al NAS..."
if copy_file_scp "$LOCAL_SCRIPT_PATH" "$REMOTE_SCRIPT_PATH"; then
    echo "✅ Script copiado exitosamente"
else
    echo "❌ Error al copiar el script"
    exit 1
fi

echo ""
echo "🔧 Configurando permisos..."
if run_ssh_command "chmod +x $REMOTE_SCRIPT_PATH"; then
    echo "✅ Permisos configurados"
else
    echo "❌ Error al configurar permisos"
    exit 1
fi

echo ""
echo "🚀 Ejecutando análisis en el NAS..."
echo "=================================================="
run_ssh_command "$REMOTE_SCRIPT_PATH"

echo ""
echo "🧹 Limpiando archivos temporales..."
run_ssh_command "rm -f $REMOTE_SCRIPT_PATH"

echo ""
echo "✅ Análisis remoto completado"
echo "=================================================="
