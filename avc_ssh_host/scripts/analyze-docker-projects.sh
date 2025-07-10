#!/bin/bash

# Script para analizar todos los proyectos Docker en el NAS
# Ejecutar en el host NAS: ssh -p 2222 avctrust@10.0.0.10

echo "=================================================="
echo "ANÁLISIS DE PROYECTOS DOCKER EN NAS SYNOLOGY"
echo "=================================================="
echo "Fecha: $(date)"
echo "Host: $(hostname)"
echo "Usuario: $(whoami)"
echo ""

# Verificar si estamos en el host o en contenedor
if [ -f /.dockerenv ]; then
    echo "⚠️  ADVERTENCIA: Este script está ejecutándose dentro de un contenedor Docker"
    echo "   Para analizar el host NAS real, conéctate por SSH:"
    echo "   ssh -p 2222 avctrust@10.0.0.10"
    echo ""
fi

DOCKER_BASE_DIR="/volume1/docker"

echo "🔍 ESTRUCTURA DE PROYECTOS DOCKER"
echo "=================================="
echo "Directorio base: $DOCKER_BASE_DIR"
echo ""

if [ ! -d "$DOCKER_BASE_DIR" ]; then
    echo "❌ Error: No se puede acceder a $DOCKER_BASE_DIR"
    exit 1
fi

echo "📁 LISTADO DE PROYECTOS:"
echo "------------------------"
cd "$DOCKER_BASE_DIR"
for project in */; do
    if [ -d "$project" ]; then
        project_name=${project%/}
        echo "📂 $project_name"
        
        # Verificar si tiene docker-compose.yml
        if [ -f "$project/docker-compose.yml" ]; then
            echo "   ✅ docker-compose.yml encontrado"
        else
            echo "   ❌ docker-compose.yml no encontrado"
        fi
        
        # Verificar si tiene Dockerfile
        if [ -f "$project/Dockerfile" ]; then
            echo "   ✅ Dockerfile encontrado"
        else
            echo "   ❌ Dockerfile no encontrado"
        fi
        
        # Verificar si tiene package.json (proyecto Node.js)
        if [ -f "$project/package.json" ]; then
            echo "   ✅ package.json encontrado (Node.js)"
        fi
        
        # Verificar si tiene requirements.txt (proyecto Python)
        if [ -f "$project/requirements.txt" ]; then
            echo "   ✅ requirements.txt encontrado (Python)"
        fi
        
        echo ""
    fi
done

echo ""
echo "🐳 CONTENEDORES DOCKER ACTIVOS"
echo "==============================="
if command -v docker &> /dev/null; then
    echo "📋 Listado de contenedores:"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    
    echo "📊 Estadísticas de uso:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
else
    echo "❌ Docker no está disponible o no tienes permisos"
fi

echo ""
echo "🌐 PUERTOS UTILIZADOS POR DOCKER"
echo "================================="
echo "🔍 Puertos mapeados por Docker:"
if command -v docker &> /dev/null; then
    docker ps --format "{{.Names}}: {{.Ports}}" | grep -v "^$"
else
    echo "❌ No se puede acceder a Docker"
fi

echo ""
echo "🔍 Puertos en uso en el sistema:"
netstat -tlnp 2>/dev/null | grep LISTEN | sort -n -k4 | head -20

echo ""
echo "📁 DETALLES DE CADA PROYECTO"
echo "============================="
cd "$DOCKER_BASE_DIR"
for project in */; do
    if [ -d "$project" ]; then
        project_name=${project%/}
        echo ""
        echo "🔍 PROYECTO: $project_name"
        echo "----------------------------------------"
        echo "📍 Ruta: $DOCKER_BASE_DIR/$project_name"
        
        # Mostrar contenido del directorio
        echo "📂 Archivos principales:"
        ls -la "$project" | grep -E '\.(yml|yaml|json|js|py|md|txt|sh)$' | head -10
        
        # Si tiene docker-compose.yml, mostrar servicios
        if [ -f "$project/docker-compose.yml" ]; then
            echo ""
            echo "🐳 Servicios en docker-compose.yml:"
            grep -E '^[[:space:]]*[a-zA-Z0-9_-]+:' "$project/docker-compose.yml" | sed 's/:.*//g' | sed 's/^[[:space:]]*/  - /'
            
            echo ""
            echo "🌐 Puertos configurados:"
            grep -E 'ports:|[0-9]+:[0-9]+' "$project/docker-compose.yml" | sed 's/^[[:space:]]*/  /'
        fi
    fi
done

echo ""
echo "📋 RESUMEN EJECUTIVO"
echo "===================="
project_count=$(find "$DOCKER_BASE_DIR" -maxdepth 1 -type d | wc -l)
project_count=$((project_count - 1))  # Excluir el directorio base
compose_count=$(find "$DOCKER_BASE_DIR" -name "docker-compose.yml" | wc -l)
dockerfile_count=$(find "$DOCKER_BASE_DIR" -name "Dockerfile" | wc -l)

echo "📊 Total de proyectos: $project_count"
echo "📊 Proyectos con docker-compose: $compose_count"
echo "📊 Proyectos con Dockerfile: $dockerfile_count"

if command -v docker &> /dev/null; then
    running_containers=$(docker ps -q | wc -l)
    echo "📊 Contenedores ejecutándose: $running_containers"
fi

echo ""
echo "✅ Análisis completado"
echo "=================================================="
