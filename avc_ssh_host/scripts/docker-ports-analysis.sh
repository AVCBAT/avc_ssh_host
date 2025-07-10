#!/bin/bash

# =================================================================
# SCRIPT PARA ANÁLISIS COMPLETO DE PUERTOS EN ENTORNO DOCKER NAS
# Ubicación: /home/avctrust/docker/avc_ssh_host/scripts/
# Uso: ./docker-ports-analysis.sh
# =================================================================

echo "🌐 ANÁLISIS COMPLETO DE PUERTOS - ENTORNO DOCKER NAS"
echo "===================================================="
echo "Fecha: $(date)"
echo "Host: $(hostname)"
echo "Usuario: $(whoami)"

# Detectar si estamos en un contenedor Docker
if [ -f /.dockerenv ]; then
    echo "🐳 ENTORNO: Contenedor Docker en NAS Synology"
    echo "   Container ID: $(hostname)"
    echo "   ⚠️  NOTA: Los puertos mostrados son del CONTENEDOR actual"
    echo "   🔗 Para puertos reales del NAS: ssh -p 2222 avctrust@10.0.0.10"
else
    echo "🖥️  ENTORNO: Host NAS Synology"
fi
echo ""

# Función para mostrar separador
separator() {
    echo "----------------------------------------"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# =================================================================
# ANÁLISIS CON NETSTAT
# =================================================================
if command_exists netstat; then
    echo "📡 ANÁLISIS CON NETSTAT"
    separator
    
    echo "🟢 PUERTOS TCP EN ESCUCHA:"
    netstat -tlnp 2>/dev/null | grep LISTEN | sort -k4 -t: -n | while read line; do
        port=$(echo "$line" | awk '{print $4}' | cut -d: -f2)
        process=$(echo "$line" | awk '{print $7}' | cut -d/ -f2)
        pid=$(echo "$line" | awk '{print $7}' | cut -d/ -f1)
        echo "  Puerto $port/tcp -> $process (PID: $pid)"
    done
    echo ""
fi

# =================================================================
# ANÁLISIS DE PROYECTOS DOCKER ESPECÍFICOS
# =================================================================
echo "📂 ANÁLISIS DE PUERTOS POR PROYECTO DOCKER"
separator

DOCKER_BASE_DIR="/home/avctrust/docker"
if [ -d "$DOCKER_BASE_DIR" ]; then
    cd "$DOCKER_BASE_DIR"
    
    echo "🔍 Proyectos con configuración de puertos:"
    for project in */; do
        if [ -d "$project" ] && [ -f "$project/docker-compose.yml" ]; then
            project_name=${project%/}
            ports=$(grep -E '^\s*-?\s*"?[0-9]+:[0-9]+' "$project/docker-compose.yml" 2>/dev/null)
            
            if [ -n "$ports" ]; then
                echo ""
                echo "📦 $project_name:"
                echo "$ports" | while read -r port_line; do
                    if [ -n "$port_line" ]; then
                        clean_port=$(echo "$port_line" | sed 's/^[[:space:]]*-[[:space:]]*//' | sed 's/"//g')
                        host_port=$(echo "$clean_port" | cut -d':' -f1)
                        container_port=$(echo "$clean_port" | cut -d':' -f2)
                        echo "    Host $host_port → Container $container_port"
                    fi
                done
            fi
        fi
    done
else
    echo "❌ No se puede acceder a $DOCKER_BASE_DIR"
fi

echo ""

# =================================================================
# DETECCIÓN DE CONFLICTOS DE PUERTOS
# =================================================================
echo "⚠️  DETECCIÓN DE CONFLICTOS DE PUERTOS"
separator

if [ -d "$DOCKER_BASE_DIR" ]; then
    cd "$DOCKER_BASE_DIR"
    
    # Crear archivo temporal con todos los puertos
    temp_ports="/tmp/docker_ports.txt"
    > "$temp_ports"
    
    for project in */; do
        if [ -d "$project" ] && [ -f "$project/docker-compose.yml" ]; then
            project_name=${project%/}
            grep -E '^\s*-?\s*"?[0-9]+:[0-9]+' "$project/docker-compose.yml" 2>/dev/null | while read -r port_line; do
                if [ -n "$port_line" ]; then
                    clean_port=$(echo "$port_line" | sed 's/^[[:space:]]*-[[:space:]]*//' | sed 's/"//g')
                    host_port=$(echo "$clean_port" | cut -d':' -f1)
                    echo "$host_port:$project_name" >> "$temp_ports"
                fi
            done
        fi
    done
    
    # Buscar duplicados
    if [ -f "$temp_ports" ]; then
        echo "🔍 Verificando conflictos..."
        duplicates=$(cut -d':' -f1 "$temp_ports" | sort | uniq -d)
        
        if [ -n "$duplicates" ]; then
            echo "🚨 CONFLICTOS DETECTADOS:"
            echo "$duplicates" | while read -r dup_port; do
                echo "  Puerto $dup_port usado por:"
                grep "^$dup_port:" "$temp_ports" | cut -d':' -f2 | sed 's/^/    - /'
            done
        else
            echo "✅ No se detectaron conflictos de puertos"
        fi
        
        rm -f "$temp_ports"
    fi
fi

echo ""

# =================================================================
# PUERTOS ESPECÍFICOS DEL ENTORNO
# =================================================================
echo "🎯 PUERTOS IMPORTANTES DEL ENTORNO"
separator

# Puertos comunes a verificar
important_ports=(22 53 80 443 3000 3306 5432 8080 8081 8443 9200)
port_descriptions=(
    "SSH"
    "DNS"
    "HTTP"
    "HTTPS"
    "Desarrollo (Node.js)"
    "MySQL/MariaDB"
    "PostgreSQL"
    "HTTP Alt"
    "HTTP Proxy"
    "HTTPS Alt"
    "Elasticsearch"
)

for i in "${!important_ports[@]}"; do
    port=${important_ports[$i]}
    desc=${port_descriptions[$i]}
    
    if command_exists lsof; then
        if lsof -i :$port 2>/dev/null | grep -q LISTEN; then
            process=$(lsof -i :$port 2>/dev/null | grep LISTEN | awk '{print $1}' | head -1)
            echo "✅ Puerto $port ($desc) -> $process"
        else
            echo "⭕ Puerto $port ($desc) -> libre"
        fi
    else
        if netstat -tln 2>/dev/null | grep ":$port " > /dev/null; then
            echo "✅ Puerto $port ($desc) -> en uso"
        else
            echo "⭕ Puerto $port ($desc) -> libre"
        fi
    fi
done

echo ""

# =================================================================
# ESTADÍSTICAS FINALES
# =================================================================
echo "📊 ESTADÍSTICAS FINALES"
separator

if command_exists netstat; then
    tcp_count=$(netstat -tln 2>/dev/null | grep LISTEN | wc -l)
    udp_count=$(netstat -uln 2>/dev/null | wc -l)
    established_count=$(netstat -tn 2>/dev/null | grep ESTABLISHED | wc -l)
    
    echo "📈 Resumen de puertos:"
    echo "   TCP en escucha: $tcp_count"
    echo "   UDP activos: $udp_count"
    echo "   Conexiones establecidas: $established_count"
fi

if [ -d "$DOCKER_BASE_DIR" ]; then
    cd "$DOCKER_BASE_DIR"
    docker_projects=$(find . -name "docker-compose.yml" | wc -l)
    echo "   Proyectos Docker configurados: $docker_projects"
fi

echo ""

# =================================================================
# COMANDOS ÚTILES
# =================================================================
echo "🔧 COMANDOS ÚTILES PARA ANÁLISIS ADICIONAL"
separator

echo "Sistema:"
echo "  netstat -tlnp | grep LISTEN     # Ver puertos en escucha"
echo "  ss -tlnp | grep LISTEN          # Ver puertos (comando moderno)"
echo "  lsof -i                         # Ver conexiones de red"
echo ""

echo "Docker:"
echo "  docker ps                       # Contenedores activos"
echo "  docker port CONTAINER           # Puertos de un contenedor"
echo "  docker-compose ps               # Estado de servicios"
echo ""

echo "NAS Host (desde SSH):"
echo "  ssh -p 2222 avctrust@10.0.0.10"
echo "  sudo netstat -tlnp | grep LISTEN"
echo ""

echo "✅ ANÁLISIS DE PUERTOS COMPLETADO"
echo "================================="
