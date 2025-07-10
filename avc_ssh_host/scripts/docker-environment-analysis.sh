#!/bin/bash

# =================================================================
# SCRIPT PARA ANÁLISIS DEL ENTORNO DOCKER Y ARQUITECTURA DEL NAS
# Ubicación: /home/avctrust/docker/avc_ssh_host/scripts/
# Uso: ./docker-environment-analysis.sh
# =================================================================

echo "🏗️  ANÁLISIS DEL ENTORNO DOCKER Y ARQUITECTURA NAS"
echo "=================================================="
echo "Fecha: $(date)"
echo "Host: $(hostname)"
echo "Usuario: $(whoami)"
echo ""

# =================================================================
# DETECCIÓN DEL ENTORNO
# =================================================================
echo "🔍 DETECCIÓN DEL ENTORNO DE EJECUCIÓN"
echo "====================================="

if [ -f /.dockerenv ]; then
    echo "🐳 ENTORNO: Contenedor Docker"
    echo "   Container ID: $(hostname)"
    echo "   Docker Environment File: /.dockerenv"
    
    echo ""
    echo "📦 Información del contenedor:"
    echo "   Hostname: $(hostname)"
    echo "   Filesystem raíz:"
    mount | grep docker | head -3 | while read line; do
        echo "     $line"
    done
    
    echo ""
    echo "🔗 Interfaces de red del contenedor:"
    if command -v ip >/dev/null 2>&1; then
        ip addr show | grep -E "(inet |UP)" | head -10 | while read line; do
            echo "     $line"
        done
    fi
else
    echo "🖥️  ENTORNO: Host NAS Synology"
    echo "   Sistema nativo del NAS"
fi

echo ""

# =================================================================
# ARQUITECTURA DEL SISTEMA
# =================================================================
echo "🏛️  ARQUITECTURA DEL SISTEMA"
echo "============================"

echo "📋 Información del sistema:"
echo "   OS: $(uname -s)"
echo "   Kernel: $(uname -r)"
echo "   Arquitectura: $(uname -m)"
echo "   Hostname: $(hostname)"

if [ -f /etc/os-release ]; then
    echo "   Distribución:"
    grep -E "(NAME|VERSION)" /etc/os-release | sed 's/^/     /'
fi

echo ""
echo "💾 Recursos del sistema:"
echo "   CPU cores: $(nproc 2>/dev/null || echo 'N/A')"

if command -v free >/dev/null 2>&1; then
    echo "   Memoria:"
    free -h | sed 's/^/     /'
fi

echo ""
echo "💿 Almacenamiento:"
df -h | head -10 | sed 's/^/   /'

echo ""

# =================================================================
# ESTRUCTURA DE PROYECTOS DOCKER
# =================================================================
echo "📂 ESTRUCTURA DE PROYECTOS DOCKER"
echo "=================================="

DOCKER_BASE_DIR="/home/avctrust/docker"
if [ -d "$DOCKER_BASE_DIR" ]; then
    echo "📁 Directorio base: $DOCKER_BASE_DIR"
    cd "$DOCKER_BASE_DIR"
    
    total_dirs=$(find . -maxdepth 1 -type d | wc -l)
    total_dirs=$((total_dirs - 1))  # Excluir directorio actual
    
    echo "📊 Estadísticas:"
    echo "   Total de directorios: $total_dirs"
    echo "   Con docker-compose.yml: $(find . -maxdepth 2 -name 'docker-compose.yml' | wc -l)"
    echo "   Con Dockerfile: $(find . -maxdepth 2 -name 'Dockerfile' | wc -l)"
    echo "   Con package.json: $(find . -maxdepth 2 -name 'package.json' | wc -l)"
    echo "   Con requirements.txt: $(find . -maxdepth 2 -name 'requirements.txt' | wc -l)"
    
    echo ""
    echo "📦 Proyectos principales:"
    for project in */; do
        if [ -d "$project" ]; then
            project_name=${project%/}
            
            # Saltar directorios especiales
            if [[ "$project_name" == "@eaDir" || "$project_name" == "#recycle" || "$project_name" == "New folder" ]]; then
                continue
            fi
            
            echo "   📁 $project_name"
            
            # Verificar tipo de proyecto
            features=""
            [ -f "$project/docker-compose.yml" ] && features="$features docker-compose"
            [ -f "$project/Dockerfile" ] && features="$features dockerfile"
            [ -f "$project/package.json" ] && features="$features nodejs"
            [ -f "$project/requirements.txt" ] && features="$features python"
            
            if [ -n "$features" ]; then
                echo "      Tecnologías:$features"
            fi
            
            # Tamaño del proyecto
            size=$(du -sh "$project" 2>/dev/null | cut -f1)
            echo "      Tamaño: $size"
        fi
    done
else
    echo "❌ No se puede acceder a $DOCKER_BASE_DIR"
fi

echo ""

# =================================================================
# ANÁLISIS DE DOCKER
# =================================================================
echo "🐳 ANÁLISIS DEL ENTORNO DOCKER"
echo "==============================="

if command -v docker >/dev/null 2>&1; then
    echo "✅ Docker está disponible"
    
    echo ""
    echo "📊 Estado de Docker:"
    docker version 2>/dev/null | head -10 | sed 's/^/   /' || echo "   Error al obtener versión de Docker"
    
    echo ""
    echo "🏃 Contenedores en ejecución:"
    running_containers=$(docker ps -q 2>/dev/null | wc -l)
    total_containers=$(docker ps -a -q 2>/dev/null | wc -l)
    echo "   Activos: $running_containers"
    echo "   Total: $total_containers"
    
    if [ "$running_containers" -gt 0 ]; then
        echo ""
        echo "📋 Contenedores activos:"
        docker ps --format "   {{.Names}} ({{.Image}}) - {{.Status}}" 2>/dev/null | head -10
    fi
    
    echo ""
    echo "🖼️  Imágenes Docker:"
    image_count=$(docker images -q 2>/dev/null | wc -l)
    echo "   Total de imágenes: $image_count"
    
    if [ "$image_count" -gt 0 ]; then
        echo "   Principales imágenes:"
        docker images --format "   {{.Repository}}:{{.Tag}} ({{.Size}})" 2>/dev/null | head -5
    fi
    
else
    echo "❌ Docker no está disponible desde este contexto"
    echo "   Para análisis completo, conectarse al host NAS:"
    echo "   ssh -p 2222 avctrust@10.0.0.10"
fi

echo ""

# =================================================================
# CONFIGURACIÓN DE RED
# =================================================================
echo "🌐 CONFIGURACIÓN DE RED"
echo "======================="

echo "🔗 Interfaces de red:"
if command -v ip >/dev/null 2>&1; then
    ip addr show | grep -E "(^\d+:|inet )" | sed 's/^/   /'
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig | grep -E "(^\w+:|inet )" | sed 's/^/   /'
else
    echo "   Comandos de red no disponibles"
fi

echo ""
echo "🚪 Puertas de enlace:"
if command -v ip >/dev/null 2>&1; then
    ip route | grep default | sed 's/^/   /'
elif command -v route >/dev/null 2>&1; then
    route -n | grep "^0.0.0.0" | sed 's/^/   /'
fi

echo ""

# =================================================================
# ANÁLISIS DE SEGURIDAD BÁSICO
# =================================================================
echo "🔒 ANÁLISIS DE SEGURIDAD BÁSICO"
echo "==============================="

echo "🔑 Usuarios del sistema:"
if [ -f /etc/passwd ]; then
    # Mostrar solo usuarios con shell válido
    grep -E "(/bin/bash|/bin/sh|/bin/zsh)$" /etc/passwd | cut -d: -f1 | sed 's/^/   /' | head -5
fi

echo ""
echo "🔐 Servicios SSH:"
if command -v ss >/dev/null 2>&1; then
    ssh_services=$(ss -tlnp | grep :22 | wc -l)
elif command -v netstat >/dev/null 2>&1; then
    ssh_services=$(netstat -tlnp 2>/dev/null | grep :22 | wc -l)
else
    ssh_services="N/A"
fi
echo "   Servicios en puerto 22: $ssh_services"

echo ""

# =================================================================
# RECOMENDACIONES
# =================================================================
echo "💡 RECOMENDACIONES Y COMANDOS ÚTILES"
echo "===================================="

echo "🔍 Para análisis detallado del host NAS:"
echo "   ssh -p 2222 avctrust@10.0.0.10"
echo "   sudo docker ps --format 'table {{.Names}}\t{{.Ports}}'"
echo "   sudo netstat -tlnp | grep LISTEN"

echo ""
echo "📊 Para monitoreo continuo:"
echo "   watch -n 5 'docker ps'"
echo "   htop"
echo "   iotop"

echo ""
echo "🧹 Para mantenimiento:"
echo "   docker system prune"
echo "   docker image prune"
echo "   docker volume prune"

echo ""
echo "📁 Estructura de scripts de análisis:"
echo "   /home/avctrust/docker/avc_ssh_host/scripts/"
echo "   /home/avctrust/docker/avc_ssh_host/docs/"

echo ""
echo "✅ ANÁLISIS DEL ENTORNO COMPLETADO"
echo "=================================="

# Crear archivo de resumen si estamos en el directorio correcto
if [ -w "." ]; then
    {
        echo "# RESUMEN DEL ENTORNO - $(date)"
        echo "Host: $(hostname)"
        echo "Usuario: $(whoami)"
        echo "Entorno: $([ -f /.dockerenv ] && echo 'Docker Container' || echo 'NAS Host')"
        echo "Docker disponible: $(command -v docker >/dev/null 2>&1 && echo 'Sí' || echo 'No')"
        echo "Proyectos Docker: $(find /home/avctrust/docker -maxdepth 2 -name 'docker-compose.yml' 2>/dev/null | wc -l)"
    } > environment_summary.txt
    echo "📄 Resumen guardado en: environment_summary.txt"
fi
