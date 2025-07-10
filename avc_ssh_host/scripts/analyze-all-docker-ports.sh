#!/bin/bash

# Script completo para analizar todos los puertos utilizados por proyectos Docker en el NAS
# Ejecutar: ssh -p 2222 avctrust@10.0.0.10 'bash -s' < analyze-all-docker-ports.sh

echo "🌐 ANÁLISIS COMPLETO DE PUERTOS DOCKER EN NAS SYNOLOGY"
echo "======================================================"
echo "Fecha: $(date)"
echo "Host: $(hostname)"
echo ""

DOCKER_BASE_DIR="/volume1/docker"
PORTS_REPORT="/tmp/docker_ports_report.txt"

# Verificar si estamos en el host o en contenedor
if [ -f /.dockerenv ]; then
    echo "⚠️  ADVERTENCIA: Este script está ejecutándose dentro de un contenedor Docker"
    echo "   Para analizar el host NAS real, conéctate por SSH:"
    echo "   ssh -p 2222 avctrust@10.0.0.10"
    echo ""
fi

echo "🔍 PUERTOS DEL SISTEMA"
echo "======================"
echo "🌐 Puertos en uso en el NAS:"
netstat -tlnp 2>/dev/null | grep LISTEN | awk '{print $4}' | sort -t: -k2 -n | head -20

echo ""
echo "🐳 CONTENEDORES DOCKER ACTIVOS"
echo "==============================="
if command -v docker &> /dev/null; then
    echo "📋 Contenedores en ejecución:"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | head -20
    
    echo ""
    echo "🌐 Mapeo de puertos de contenedores activos:"
    docker ps --format "{{.Names}}: {{.Ports}}" | grep -v ":$" | sort
else
    echo "❌ Docker no está disponible o no tienes permisos"
fi

echo ""
echo "📂 ANÁLISIS DE CONFIGURACIONES DOCKER-COMPOSE"
echo "=============================================="

cd "$DOCKER_BASE_DIR" 2>/dev/null || {
    echo "❌ Error: No se puede acceder a $DOCKER_BASE_DIR"
    exit 1
}

# Crear reporte de puertos
echo "# REPORTE DE PUERTOS CONFIGURADOS EN DOCKER-COMPOSE" > "$PORTS_REPORT"
echo "# Generado: $(date)" >> "$PORTS_REPORT"
echo "" >> "$PORTS_REPORT"

ports_found=()

for project in */; do
    if [ -d "$project" ] && [ -f "$project/docker-compose.yml" ]; then
        project_name=${project%/}
        echo "🔍 Analizando: $project_name"
        
        # Buscar puertos en docker-compose.yml
        ports=$(grep -E '^\s*-?\s*"?[0-9]+:[0-9]+' "$project/docker-compose.yml" 2>/dev/null | sed 's/^[[:space:]]*//' | sed 's/^-[[:space:]]*//' | sed 's/"//g')
        
        if [ -n "$ports" ]; then
            echo "  📊 Puertos configurados:"
            echo "$ports" | while read -r port; do
                if [ -n "$port" ]; then
                    host_port=$(echo "$port" | cut -d':' -f1)
                    container_port=$(echo "$port" | cut -d':' -f2)
                    echo "    • $host_port → $container_port"
                    ports_found+=("$host_port")
                fi
            done
            
            # Agregar al reporte
            echo "## $project_name" >> "$PORTS_REPORT"
            echo "$ports" | while read -r port; do
                if [ -n "$port" ]; then
                    echo "$port" >> "$PORTS_REPORT"
                fi
            done
            echo "" >> "$PORTS_REPORT"
        else
            echo "  ℹ️  No se encontraron puertos configurados"
        fi
        echo ""
    fi
done

echo ""
echo "📊 RESUMEN DE PUERTOS UTILIZADOS"
echo "================================"

# Extraer todos los puertos únicos del reporte
if [ -f "$PORTS_REPORT" ]; then
    echo "🌐 Puertos configurados en docker-compose:"
    grep -E '^[0-9]+:' "$PORTS_REPORT" | cut -d':' -f1 | sort -n | uniq | while read -r port; do
        # Buscar qué proyecto usa este puerto
        project=$(grep -B5 "^$port:" "$PORTS_REPORT" | grep "^## " | tail -1 | sed 's/^## //')
        echo "  • Puerto $port → $project"
    done
    
    echo ""
    echo "📈 Estadísticas:"
    port_count=$(grep -E '^[0-9]+:' "$PORTS_REPORT" | wc -l)
    unique_ports=$(grep -E '^[0-9]+:' "$PORTS_REPORT" | cut -d':' -f1 | sort -n | uniq | wc -l)
    echo "  • Total configuraciones de puerto: $port_count"
    echo "  • Puertos únicos utilizados: $unique_ports"
    
    echo ""
    echo "⚠️  POSIBLES CONFLICTOS DE PUERTOS:"
    # Buscar puertos duplicados
    duplicates=$(grep -E '^[0-9]+:' "$PORTS_REPORT" | cut -d':' -f1 | sort | uniq -d)
    if [ -n "$duplicates" ]; then
        echo "$duplicates" | while read -r dup_port; do
            echo "  🚨 Puerto $dup_port usado por múltiples proyectos:"
            grep -B5 "^$dup_port:" "$PORTS_REPORT" | grep "^## " | sed 's/^## /    - /'
        done
    else
        echo "  ✅ No se detectaron conflictos de puertos"
    fi
fi

echo ""
echo "🔧 COMANDOS ÚTILES PARA ANÁLISIS ADICIONAL"
echo "=========================================="
echo "• Ver puertos del sistema: netstat -tlnp | grep LISTEN"
echo "• Ver contenedores activos: docker ps"
echo "• Ver logs de contenedor: docker logs <nombre_contenedor>"
echo "• Ver estadísticas: docker stats"
echo "• Parar todos los contenedores: docker stop \$(docker ps -q)"

echo ""
echo "📁 Reporte completo guardado en: $PORTS_REPORT"
echo ""
echo "✅ Análisis completado"
echo "======================================================"

# Cleanup
# rm -f "$PORTS_REPORT"
