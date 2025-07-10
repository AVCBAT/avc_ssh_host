#!/bin/bash

# Script simple para listar solo la estructura de proyectos Docker
# Ejecutar: ssh -p 2222 avctrust@10.0.0.10 'bash -s' < list-docker-projects.sh

echo "🔍 PROYECTOS DOCKER EN /volume1/docker"
echo "======================================"

cd /volume1/docker 2>/dev/null || {
    echo "❌ Error: No se puede acceder a /volume1/docker"
    exit 1
}

echo "📁 Directorio base: $(pwd)"
echo ""

echo "📂 PROYECTOS ENCONTRADOS:"
echo "-------------------------"
for dir in */; do
    if [ -d "$dir" ]; then
        project_name=${dir%/}
        echo "• $project_name"
        
        # Mostrar algunos detalles clave
        details=""
        [ -f "$dir/docker-compose.yml" ] && details="$details[docker-compose]"
        [ -f "$dir/Dockerfile" ] && details="$details[dockerfile]"
        [ -f "$dir/package.json" ] && details="$details[nodejs]"
        [ -f "$dir/requirements.txt" ] && details="$details[python]"
        
        if [ -n "$details" ]; then
            echo "  $details"
        fi
    fi
done

echo ""
echo "📊 Total de directorios: $(find . -maxdepth 1 -type d | wc -l | awk '{print $1-1}')"
echo ""

# Mostrar contenedores activos si Docker está disponible
if command -v docker &> /dev/null; then
    echo "🐳 CONTENEDORES ACTIVOS:"
    echo "------------------------"
    docker ps --format "• {{.Names}} ({{.Image}}) - {{.Status}}"
    echo ""
fi

echo "✅ Listado completado"
