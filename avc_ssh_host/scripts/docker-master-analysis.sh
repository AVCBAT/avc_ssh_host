#!/bin/bash

# =================================================================
# SCRIPT MAESTRO PARA ANÁLISIS COMPLETO DEL ENTORNO DOCKER NAS
# Ubicación: /home/avctrust/docker/avc_ssh_host/scripts/
# Uso: ./docker-master-analysis.sh
# =================================================================

echo "🎯 ANÁLISIS MAESTRO DEL ENTORNO DOCKER - NAS SYNOLOGY"
echo "======================================================"
echo "Fecha: $(date)"
echo "Ejecutado desde: $(pwd)"
echo "Usuario: $(whoami)"
echo "Host: $(hostname)"
echo ""

# Configuración de rutas
SCRIPTS_DIR="/home/avctrust/docker/avc_ssh_host/scripts"
DOCS_DIR="/home/avctrust/docker/avc_ssh_host/docs"
DOCKER_BASE_DIR="/home/avctrust/docker"
REPORT_DIR="/tmp/docker_master_analysis_$(date +%Y%m%d_%H%M%S)"

# Crear directorio de reportes
mkdir -p "$REPORT_DIR"

echo "📁 CONFIGURACIÓN:"
echo "   Scripts: $SCRIPTS_DIR"
echo "   Docs: $DOCS_DIR"
echo "   Docker Base: $DOCKER_BASE_DIR"
echo "   Reportes: $REPORT_DIR"
echo ""

# Verificar si estamos en contenedor o host
if [ -f /.dockerenv ]; then
    echo "🐳 ENTORNO: Contenedor Docker"
    echo "   ⚠️  Nota: Para análisis completo del host, ejecutar desde SSH"
    echo "   ssh -p 2222 avctrust@10.0.0.10"
else
    echo "🖥️  ENTORNO: Host NAS"
fi
echo ""

# Función para ejecutar script si existe
run_script() {
    local script_name="$1"
    local description="$2"
    local script_path="$SCRIPTS_DIR/$script_name"
    
    echo "🔍 $description..."
    if [ -f "$script_path" ] && [ -x "$script_path" ]; then
        echo "   Ejecutando: $script_name"
        "$script_path" > "$REPORT_DIR/${script_name%.*}_output.txt" 2>&1
        echo "   ✅ Completado: ${script_name%.*}_output.txt"
    else
        echo "   ⚠️  Script no encontrado o no ejecutable: $script_name"
    fi
    echo ""
}

# Función para mostrar información del sistema
system_info() {
    echo "🖥️  INFORMACIÓN DEL SISTEMA" | tee "$REPORT_DIR/system_info.txt"
    echo "============================" | tee -a "$REPORT_DIR/system_info.txt"
    {
        echo "Fecha: $(date)"
        echo "Hostname: $(hostname)"
        echo "Usuario: $(whoami)"
        echo "Directorio actual: $(pwd)"
        echo "Sistema: $(uname -a)"
        echo ""
        echo "Memoria:"
        free -h 2>/dev/null || echo "Comando free no disponible"
        echo ""
        echo "Espacio en disco:"
        df -h | head -10
        echo ""
        echo "Procesos Docker:"
        ps aux | grep docker | head -5 | grep -v grep || echo "No se encontraron procesos Docker"
    } | tee -a "$REPORT_DIR/system_info.txt"
    echo ""
}

# Función para analizar proyectos Docker
analyze_projects() {
    echo "📂 ANÁLISIS DE PROYECTOS DOCKER" | tee "$REPORT_DIR/projects_analysis.txt"
    echo "===============================" | tee -a "$REPORT_DIR/projects_analysis.txt"
    
    if [ -d "$DOCKER_BASE_DIR" ]; then
        cd "$DOCKER_BASE_DIR"
        {
            echo "Directorio base: $(pwd)"
            echo "Total de elementos: $(ls -1 | wc -l)"
            echo ""
            
            echo "Proyectos con docker-compose.yml:"
            find . -maxdepth 2 -name "docker-compose.yml" | wc -l
            
            echo "Proyectos con Dockerfile:"
            find . -maxdepth 2 -name "Dockerfile" | wc -l
            
            echo "Proyectos Node.js (package.json):"
            find . -maxdepth 2 -name "package.json" | wc -l
            
            echo "Proyectos Python (requirements.txt):"
            find . -maxdepth 2 -name "requirements.txt" | wc -l
            echo ""
            
            echo "LISTADO DETALLADO DE PROYECTOS:"
            echo "==============================="
            for project in */; do
                if [ -d "$project" ]; then
                    project_name=${project%/}
                    echo "📁 $project_name"
                    
                    # Verificar características del proyecto
                    features=""
                    [ -f "$project/docker-compose.yml" ] && features="$features [docker-compose]"
                    [ -f "$project/Dockerfile" ] && features="$features [dockerfile]"
                    [ -f "$project/package.json" ] && features="$features [nodejs]"
                    [ -f "$project/requirements.txt" ] && features="$features [python]"
                    [ -f "$project/.env" ] && features="$features [env-vars]"
                    
                    if [ -n "$features" ]; then
                        echo "   Características:$features"
                    fi
                    
                    # Tamaño del proyecto
                    size=$(du -sh "$project" 2>/dev/null | cut -f1)
                    echo "   Tamaño: $size"
                    echo ""
                fi
            done
        } | tee -a "$REPORT_DIR/projects_analysis.txt"
    else
        echo "❌ No se puede acceder a $DOCKER_BASE_DIR" | tee -a "$REPORT_DIR/projects_analysis.txt"
    fi
    echo ""
}

# Función para analizar puertos
analyze_ports() {
    echo "🌐 ANÁLISIS DE PUERTOS" | tee "$REPORT_DIR/ports_analysis.txt"
    echo "======================" | tee -a "$REPORT_DIR/ports_analysis.txt"
    
    {
        echo "PUERTOS DEL SISTEMA EN USO:"
        echo "---------------------------"
        if command -v netstat &> /dev/null; then
            netstat -tlnp 2>/dev/null | grep LISTEN | sort -t: -k2 -n | head -20
        else
            echo "netstat no disponible"
        fi
        echo ""
        
        echo "CONFIGURACIONES DOCKER-COMPOSE:"
        echo "-------------------------------"
        if [ -d "$DOCKER_BASE_DIR" ]; then
            cd "$DOCKER_BASE_DIR"
            for project in */; do
                if [ -d "$project" ] && [ -f "$project/docker-compose.yml" ]; then
                    project_name=${project%/}
                    ports=$(grep -E '^\s*-?\s*"?[0-9]+:[0-9]+' "$project/docker-compose.yml" 2>/dev/null)
                    if [ -n "$ports" ]; then
                        echo "📦 $project_name:"
                        echo "$ports" | sed 's/^[[:space:]]*/  /'
                        echo ""
                    fi
                fi
            done
        fi
    } | tee -a "$REPORT_DIR/ports_analysis.txt"
    echo ""
}

# Función para analizar contenedores Docker
analyze_containers() {
    echo "🐳 ANÁLISIS DE CONTENEDORES DOCKER" | tee "$REPORT_DIR/containers_analysis.txt"
    echo "===================================" | tee -a "$REPORT_DIR/containers_analysis.txt"
    
    {
        if command -v docker &> /dev/null; then
            echo "CONTENEDORES ACTIVOS:"
            echo "--------------------"
            docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Error al obtener contenedores activos"
            echo ""
            
            echo "TODOS LOS CONTENEDORES:"
            echo "----------------------"
            docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null || echo "Error al obtener todos los contenedores"
            echo ""
            
            echo "ESTADÍSTICAS DE RECURSOS:"
            echo "-------------------------"
            docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null || echo "Error al obtener estadísticas"
            echo ""
            
            echo "IMÁGENES DOCKER:"
            echo "---------------"
            docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null || echo "Error al obtener imágenes"
        else
            echo "Docker no está disponible desde este contexto"
        fi
    } | tee -a "$REPORT_DIR/containers_analysis.txt"
    echo ""
}

# Función para generar reporte consolidado
generate_consolidated_report() {
    echo "📊 GENERANDO REPORTE CONSOLIDADO..."
    
    {
        echo "# REPORTE CONSOLIDADO - ANÁLISIS DOCKER NAS SYNOLOGY"
        echo "=================================================="
        echo "Generado: $(date)"
        echo "Host: $(hostname)"
        echo "Usuario: $(whoami)"
        echo "Directorio de trabajo: $(pwd)"
        echo ""
        
        echo "## RESUMEN EJECUTIVO"
        echo "==================="
        
        if [ -d "$DOCKER_BASE_DIR" ]; then
            cd "$DOCKER_BASE_DIR"
            project_count=$(find . -maxdepth 1 -type d | wc -l)
            project_count=$((project_count - 1))
            compose_count=$(find . -name "docker-compose.yml" | wc -l)
            dockerfile_count=$(find . -name "Dockerfile" | wc -l)
            
            echo "- Total de proyectos: $project_count"
            echo "- Proyectos con docker-compose: $compose_count"
            echo "- Proyectos con Dockerfile: $dockerfile_count"
        fi
        
        if command -v docker &> /dev/null; then
            running_containers=$(docker ps -q 2>/dev/null | wc -l)
            total_containers=$(docker ps -a -q 2>/dev/null | wc -l)
            echo "- Contenedores ejecutándose: $running_containers"
            echo "- Total de contenedores: $total_containers"
        fi
        
        echo ""
        echo "## ARCHIVOS GENERADOS"
        echo "===================="
        ls -la "$REPORT_DIR"
        echo ""
        
        echo "## INSTRUCCIONES DE USO"
        echo "======================="
        echo "Para ver reportes específicos:"
        echo "cat $REPORT_DIR/system_info.txt"
        echo "cat $REPORT_DIR/projects_analysis.txt"
        echo "cat $REPORT_DIR/ports_analysis.txt"
        echo "cat $REPORT_DIR/containers_analysis.txt"
        echo ""
        
        echo "Para limpiar reportes temporales:"
        echo "rm -rf $REPORT_DIR"
        echo ""
        
    } > "$REPORT_DIR/consolidated_report.txt"
    
    echo "✅ Reporte consolidado generado: $REPORT_DIR/consolidated_report.txt"
    echo ""
}

# EJECUCIÓN PRINCIPAL
echo "🚀 INICIANDO ANÁLISIS MAESTRO..."
echo ""

# 1. Información del sistema
system_info

# 2. Análisis de proyectos
analyze_projects

# 3. Análisis de puertos
analyze_ports

# 4. Análisis de contenedores
analyze_containers

# 5. Ejecutar scripts específicos si existen
run_script "check-ports.sh" "Análisis detallado de puertos"
run_script "analyze-environment.sh" "Análisis del entorno Docker"

# 6. Generar reporte consolidado
generate_consolidated_report

# 7. Mostrar resumen final
echo "✅ ANÁLISIS MAESTRO COMPLETADO"
echo "=============================="
echo "📁 Reportes generados en: $REPORT_DIR"
echo ""

echo "📋 RESUMEN RÁPIDO:"
echo "------------------"
if [ -f "$REPORT_DIR/consolidated_report.txt" ]; then
    head -30 "$REPORT_DIR/consolidated_report.txt"
fi

echo ""
echo "🔍 Para ver el reporte completo:"
echo "cat $REPORT_DIR/consolidated_report.txt"
echo ""

echo "🎯 ANÁLISIS COMPLETADO EXITOSAMENTE"
echo "==================================="
