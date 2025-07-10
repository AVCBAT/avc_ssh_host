#!/bin/bash

# =================================================================
# SCRIPT PARA ANÁLISIS DEL NAS HOST (Synology)
# Ejecutar este script DIRECTAMENTE en el NAS, no en el contenedor
# =================================================================

echo "🏠 ANÁLISIS DEL NAS HOST SYNOLOGY"
echo "================================="
echo "Fecha: $(date)"
echo "Hostname: $(hostname)"
echo "Sistema: $(uname -a)"
echo ""

# Verificar que estamos en el host, no en el contenedor
if [ -f /.dockerenv ]; then
    echo "❌ ERROR: Este script debe ejecutarse en el HOST NAS, no en el contenedor"
    echo "   Conéctate al NAS con: ssh -p 2222 avctrust@10.0.0.10"
    exit 1
else
    echo "✅ Ejecutándose en el HOST NAS"
fi

echo ""

# =================================================================
# ANÁLISIS DE CONTENEDORES DOCKER
# =================================================================
echo "🐳 CONTENEDORES DOCKER ACTIVOS"
echo "==============================="

if command -v docker >/dev/null 2>&1; then
    echo "📦 Contenedores en ejecución:"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    
    echo "🔄 MAPEO DETALLADO DE PUERTOS:"
    docker ps --format "{{.Names}}" | while read container; do
        echo "📋 Contenedor: $container"
        docker port "$container" 2>/dev/null | while read mapping; do
            echo "   🔗 $mapping"
        done
        echo ""
    done
    
    echo "🌐 REDES DOCKER:"
    docker network ls
    echo ""
    
else
    echo "❌ Docker no está disponible o no tienes permisos"
fi

# =================================================================
# PUERTOS DEL HOST NAS
# =================================================================
echo "🖥️  PUERTOS DEL HOST NAS"
echo "========================"

echo "🟢 PUERTOS TCP EN ESCUCHA:"
if command -v netstat >/dev/null 2>&1; then
    netstat -tlnp 2>/dev/null | grep LISTEN | sort -k4 -t: -n | while read line; do
        port=$(echo "$line" | awk '{print $4}' | cut -d: -f2)
        process=$(echo "$line" | awk '{print $7}' | cut -d/ -f2)
        pid=$(echo "$line" | awk '{print $7}' | cut -d/ -f1)
        echo "  Puerto $port/tcp -> $process (PID: $pid)"
    done
elif command -v ss >/dev/null 2>&1; then
    ss -tlnp | grep LISTEN | sort -k4 -t: -n | while read line; do
        port=$(echo "$line" | awk '{print $4}' | cut -d: -f2)
        process_info=$(echo "$line" | grep -o 'users:(([^)]*))' | sed 's/users:((\([^)]*\)))/\1/')
        echo "  Puerto $port/tcp -> $process_info"
    done
else
    echo "❌ Ni netstat ni ss están disponibles"
fi
echo ""

# =================================================================
# SERVICIOS SYNOLOGY ESPECÍFICOS
# =================================================================
echo "🔧 SERVICIOS SYNOLOGY"
echo "====================="

synology_ports=(
    "22:SSH"
    "80:HTTP (DSM)"
    "443:HTTPS (DSM)"
    "5000:DSM HTTP"
    "5001:DSM HTTPS"
    "5432:PostgreSQL"
    "3306:MariaDB/MySQL"
    "9200:Elasticsearch"
    "6379:Redis"
    "27017:MongoDB"
    "8080:Aplicaciones Web"
    "8081:Tu Proyecto"
    "3000:Node.js/React"
    "5173:Vite Dev Server"
    "2222:SSH Alternativo"
)

for port_desc in "${synology_ports[@]}"; do
    port=$(echo "$port_desc" | cut -d: -f1)
    desc=$(echo "$port_desc" | cut -d: -f2)
    
    if command -v lsof >/dev/null 2>&1; then
        if lsof -i :$port 2>/dev/null | grep -q LISTEN; then
            process=$(lsof -i :$port 2>/dev/null | grep LISTEN | awk '{print $1}' | head -1)
            echo "✅ Puerto $port ($desc) -> $process"
        else
            echo "⭕ Puerto $port ($desc) -> libre"
        fi
    elif netstat -tln 2>/dev/null | grep ":$port " > /dev/null; then
        echo "✅ Puerto $port ($desc) -> en uso"
    else
        echo "⭕ Puerto $port ($desc) -> libre"
    fi
done

echo ""

# =================================================================
# ANÁLISIS DE PROCESOS WEB
# =================================================================
echo "🌐 PROCESOS WEB Y APLICACIONES"
echo "==============================="

web_processes=("nginx" "apache" "httpd" "node" "python" "java" "docker" "containerd")
for process in "${web_processes[@]}"; do
    if pgrep "$process" > /dev/null; then
        echo "✅ $process está ejecutándose:"
        ps aux | grep "$process" | grep -v grep | head -3 | while read line; do
            pid=$(echo "$line" | awk '{print $2}')
            cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}')
            echo "    PID $pid: $cmd"
        done
        echo ""
    fi
done

# =================================================================
# VERIFICACIÓN ESPECÍFICA DEL PROYECTO
# =================================================================
echo "🐉 VERIFICACIÓN DEL PROYECTO BEHAVIOURAL DRAGON PRO"
echo "==================================================="

echo "🔍 Buscando contenedores relacionados con el proyecto:"
docker ps --filter "name=behavioural" --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}" 2>/dev/null || echo "No se encontraron contenedores con 'behavioural' en el nombre"

echo ""
echo "🔍 Verificando puertos específicos del proyecto en el HOST:"
project_ports=(3000 5173 5174 8081)
for port in "${project_ports[@]}"; do
    if command -v lsof >/dev/null 2>&1; then
        result=$(lsof -i :$port 2>/dev/null)
        if [[ -n "$result" ]]; then
            echo "✅ Puerto $port está en uso en el HOST:"
            echo "$result" | grep -v COMMAND | while read line; do
                process=$(echo "$line" | awk '{print $1}')
                pid=$(echo "$line" | awk '{print $2}')
                user=$(echo "$line" | awk '{print $3}')
                echo "    $process (PID: $pid, User: $user)"
            done
        else
            echo "⭕ Puerto $port está libre en el HOST"
        fi
    fi
done

echo ""

# =================================================================
# INFORMACIÓN DEL SISTEMA
# =================================================================
echo "💻 INFORMACIÓN DEL SISTEMA NAS"
echo "==============================="

echo "📊 Uso de recursos:"
echo "   CPU: $(cat /proc/loadavg)"
echo "   Memoria: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo "   Disco: $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5" usado)"}')"

echo ""
echo "🌐 Configuración de red:"
ip addr show | grep -E "(inet |UP)" | head -10

echo ""
echo "🎯 ANÁLISIS DEL HOST COMPLETADO"
echo ""
echo "📝 PRÓXIMOS PASOS:"
echo "   1. Revisa los puertos mapeados de Docker"
echo "   2. Verifica si tu proyecto está accesible desde:"
echo "      - http://10.0.0.10:8081 (si está mapeado)"
echo "      - http://10.0.0.10:3000 (si está mapeado)"
echo "      - http://10.0.0.10:5173 (si está mapeado)"
echo "   3. Si no hay mapeo, configúralo en docker-compose.yml"
