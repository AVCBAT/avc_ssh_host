#!/bin/bash

# SCRIPT MAESTRO DE ANÁLISIS COMPLETO DEL ENTORNO DOCKER
# Ejecuta todos los análisis y genera un reporte consolidado
# Uso: ssh -p 2222 avctrust@10.0.0.10 'bash -s' < master-docker-analysis.sh

echo "🔥 ANÁLISIS MAESTRO DEL ENTORNO DOCKER"
echo "======================================"
echo "Iniciando análisis completo del NAS Synology..."
echo "Fecha: $(date)"
echo ""

# Configuraciones
DOCKER_BASE_DIR="/volume1/docker"
REPORT_DIR="/tmp/docker_analysis_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$REPORT_DIR"

echo "📁 Directorio de reportes: $REPORT_DIR"
echo ""

# 1. INFORMACIÓN DEL SISTEMA
echo "🖥️  RECOPILANDO INFORMACIÓN DEL SISTEMA..."
{
    echo "# INFORMACIÓN DEL SISTEMA"
    echo "========================"
    echo "Fecha: $(date)"
    echo "Hostname: $(hostname)"
    echo "Usuario: $(whoami)"
    echo "Arquitectura: $(uname -a)"
    echo ""
    echo "## Uso de disco:"
    df -h | head -10
    echo ""
    echo "## Memoria:"
    free -h
    echo ""
    echo "## Procesos Docker:"
    ps aux | grep docker | head -5
    echo ""
} > "$REPORT_DIR/system_info.txt"

# 2. ANÁLISIS DE PROYECTOS
echo "📂 ANALIZANDO ESTRUCTURA DE PROYECTOS..."
{
    echo "# ANÁLISIS DE PROYECTOS DOCKER"
    echo "=============================="
    cd "$DOCKER_BASE_DIR" 2>/dev/null || exit 1
    
    echo "Directorio base: $(pwd)"
    echo "Total de elementos: $(ls -1 | wc -l)"
    echo ""
    
    echo "## Proyectos por tipo:"
    echo "### Con docker-compose.yml:"
    find . -maxdepth 2 -name "docker-compose.yml" | wc -l
    echo ""
    
    echo "### Con Dockerfile:"
    find . -maxdepth 2 -name "Dockerfile" | wc -l
    echo ""
    
    echo "### Con package.json (Node.js):"
    find . -maxdepth 2 -name "package.json" | wc -l
    echo ""
    
    echo "### Con requirements.txt (Python):"
    find . -maxdepth 2 -name "requirements.txt" | wc -l
    echo ""
    
    echo "## Listado detallado:"
    for dir in */; do
        if [ -d "$dir" ]; then
            project_name=${dir%/}
            echo "### $project_name"
            echo "Ruta: $DOCKER_BASE_DIR/$project_name"
            
            # Verificar archivos clave
            features=""
            [ -f "$dir/docker-compose.yml" ] && features="$features docker-compose"
            [ -f "$dir/Dockerfile" ] && features="$features dockerfile"
            [ -f "$dir/package.json" ] && features="$features nodejs"
            [ -f "$dir/requirements.txt" ] && features="$features python"
            [ -f "$dir/.env" ] && features="$features env-vars"
            
            echo "Características:$features"
            
            # Tamaño del directorio
            size=$(du -sh "$dir" 2>/dev/null | cut -f1)
            echo "Tamaño: $size"
            echo ""
        fi
    done
} > "$REPORT_DIR/projects_analysis.txt"

# 3. ANÁLISIS DE PUERTOS
echo "🌐 ANALIZANDO CONFIGURACIÓN DE PUERTOS..."
{
    echo "# ANÁLISIS DE PUERTOS"
    echo "===================="
    
    echo "## Puertos del sistema en uso:"
    netstat -tlnp 2>/dev/null | grep LISTEN | sort -t: -k2 -n
    echo ""
    
    echo "## Configuraciones en docker-compose:"
    cd "$DOCKER_BASE_DIR"
    for project in */; do
        if [ -d "$project" ] && [ -f "$project/docker-compose.yml" ]; then
            project_name=${project%/}
            ports=$(grep -E '^\s*-?\s*"?[0-9]+:[0-9]+' "$project/docker-compose.yml" 2>/dev/null)
            if [ -n "$ports" ]; then
                echo "### $project_name:"
                echo "$ports" | sed 's/^[[:space:]]*/  /'
                echo ""
            fi
        fi
    done
} > "$REPORT_DIR/ports_analysis.txt"

# 4. ESTADO DE CONTENEDORES
echo "🐳 VERIFICANDO ESTADO DE CONTENEDORES..."
{
    echo "# ESTADO DE CONTENEDORES DOCKER"
    echo "==============================="
    
    if command -v docker &> /dev/null; then
        echo "## Contenedores activos:"
        docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        
        echo "## Todos los contenedores:"
        docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
        echo ""
        
        echo "## Uso de recursos:"
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
        echo ""
        
        echo "## Imágenes Docker:"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    else
        echo "Docker no está disponible desde este contexto"
    fi
} > "$REPORT_DIR/containers_status.txt"

# 5. ANÁLISIS DEL PROYECTO BEHAVIOURAL DRAGON PRO
echo "🐉 ANALIZANDO PROYECTO BEHAVIOURAL DRAGON PRO..."
{
    echo "# BEHAVIOURAL DRAGON PRO - ANÁLISIS ESPECÍFICO"
    echo "=============================================="
    
    project_dir="$DOCKER_BASE_DIR/behavioural_dragon_pro"
    if [ -d "$project_dir" ]; then
        cd "$project_dir"
        echo "Directorio del proyecto: $(pwd)"
        echo ""
        
        echo "## Archivos principales:"
        ls -la | grep -E '\.(json|yml|yaml|js|jsx|md|env)$'
        echo ""
        
        echo "## Configuración docker-compose:"
        if [ -f "docker-compose.yml" ]; then
            echo "### Servicios configurados:"
            grep -E '^[[:space:]]*[a-zA-Z0-9_-]+:' docker-compose.yml | sed 's/:.*//g' | sed 's/^[[:space:]]*/- /'
            echo ""
            
            echo "### Puertos configurados:"
            grep -E 'ports:|[0-9]+:[0-9]+' docker-compose.yml
            echo ""
        fi
        
        echo "## package.json:"
        if [ -f "package.json" ]; then
            echo "### Scripts disponibles:"
            grep -A10 '"scripts"' package.json | grep '"' | sed 's/^[[:space:]]*/  /'
            echo ""
        fi
        
        echo "## Estado de archivos importantes:"
        important_files=("README.md" "IMPLEMENTATION_GUIDE.md" "docker-compose.yml" "Dockerfile" "package.json")
        for file in "${important_files[@]}"; do
            if [ -f "$file" ]; then
                echo "✅ $file - $(stat -c%y "$file")"
            else
                echo "❌ $file - No encontrado"
            fi
        done
    else
        echo "❌ Proyecto behavioural_dragon_pro no encontrado en $project_dir"
    fi
} > "$REPORT_DIR/behavioural_dragon_analysis.txt"

# 6. GENERAR REPORTE CONSOLIDADO
echo "📊 GENERANDO REPORTE CONSOLIDADO..."
{
    echo "# REPORTE CONSOLIDADO - ANÁLISIS DOCKER NAS SYNOLOGY"
    echo "=================================================="
    echo "Generado: $(date)"
    echo "Host: $(hostname)"
    echo "Directorio de análisis: $REPORT_DIR"
    echo ""
    
    echo "## RESUMEN EJECUTIVO"
    echo "==================="
    project_count=$(find "$DOCKER_BASE_DIR" -maxdepth 1 -type d | wc -l)
    project_count=$((project_count - 1))
    compose_count=$(find "$DOCKER_BASE_DIR" -name "docker-compose.yml" | wc -l)
    dockerfile_count=$(find "$DOCKER_BASE_DIR" -name "Dockerfile" | wc -l)
    
    echo "- Total de proyectos: $project_count"
    echo "- Proyectos con docker-compose: $compose_count"
    echo "- Proyectos con Dockerfile: $dockerfile_count"
    
    if command -v docker &> /dev/null; then
        running_containers=$(docker ps -q | wc -l)
        total_containers=$(docker ps -a -q | wc -l)
        echo "- Contenedores ejecutándose: $running_containers"
        echo "- Total de contenedores: $total_containers"
    fi
    
    echo ""
    echo "## ARCHIVOS GENERADOS"
    echo "===================="
    ls -la "$REPORT_DIR"
    echo ""
    
    echo "## ACCESO A REPORTES"
    echo "==================="
    echo "Para ver los reportes completos:"
    echo "cat $REPORT_DIR/system_info.txt"
    echo "cat $REPORT_DIR/projects_analysis.txt"
    echo "cat $REPORT_DIR/ports_analysis.txt"
    echo "cat $REPORT_DIR/containers_status.txt"
    echo "cat $REPORT_DIR/behavioural_dragon_analysis.txt"
    echo ""
    
} > "$REPORT_DIR/consolidated_report.txt"

# 7. MOSTRAR RESULTADOS
echo ""
echo "✅ ANÁLISIS COMPLETADO"
echo "======================"
echo "📁 Reportes generados en: $REPORT_DIR"
echo ""

echo "📋 RESUMEN RÁPIDO:"
echo "------------------"
cat "$REPORT_DIR/consolidated_report.txt"

echo ""
echo "🔍 Para ver reportes detallados:"
echo "cat $REPORT_DIR/consolidated_report.txt"
echo ""

echo "🧹 Para limpiar reportes temporales:"
echo "rm -rf $REPORT_DIR"
echo ""

echo "🎯 ANÁLISIS MAESTRO COMPLETADO"
echo "==============================="
