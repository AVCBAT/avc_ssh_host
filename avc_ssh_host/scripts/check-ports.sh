#!/bin/bash

# =================================================================
# SCRIPT PARA LISTAR PUERTOS USADOS EN NAS
# Detecta todos los puertos en uso y los procesos que los utilizan
# =================================================================

echo "🔍 ANÁLISIS DE PUERTOS EN USO - DOCKER CONTAINER EN NAS"
echo "======================================================="
echo "Fecha: $(date)"
echo "Hostname: $(hostname)"
echo "Sistema: $(uname -a)"

# Detectar si estamos en un contenedor Docker
if [ -f /.dockerenv ]; then
    echo "🐳 ENTORNO: Contenedor Docker en NAS Synology"
    echo "   Container ID: $(hostname)"
    echo "   Filesystem: $(mount | grep docker | head -1 | awk '{print $1}')"
else
    echo "🖥️  ENTORNO: Sistema nativo"
fi
echo ""

# Función para mostrar una línea separadora
separator() {
    echo "----------------------------------------"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# =================================================================
# OPCIÓN 1: NETSTAT (Más detallado y tradicional)
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
    
    echo "🔵 PUERTOS UDP EN ESCUCHA:"
    netstat -ulnp 2>/dev/null | while read line; do
        if [[ $line == *":"* ]] && [[ $line != "Active"* ]] && [[ $line != "Proto"* ]]; then
            port=$(echo "$line" | awk '{print $4}' | cut -d: -f2)
            process=$(echo "$line" | awk '{print $6}' | cut -d/ -f2)
            pid=$(echo "$line" | awk '{print $6}' | cut -d/ -f1)
            echo "  Puerto $port/udp -> $process (PID: $pid)"
        fi
    done
    echo ""
    
    echo "📊 CONEXIONES ESTABLECIDAS:"
    netstat -tnp 2>/dev/null | grep ESTABLISHED | wc -l | xargs echo "  Total conexiones activas:"
    echo ""
fi

# =================================================================
# OPCIÓN 2: SS (Más moderno y rápido)
# =================================================================
if command_exists ss; then
    echo "⚡ ANÁLISIS CON SS (Socket Statistics)"
    separator
    
    echo "🟢 PUERTOS TCP EN ESCUCHA:"
    ss -tlnp | grep LISTEN | sort -k4 -t: -n | while read line; do
        port=$(echo "$line" | awk '{print $4}' | cut -d: -f2)
        process_info=$(echo "$line" | grep -o 'users:(([^)]*))' | sed 's/users:((\([^)]*\)))/\1/')
        if [[ -n "$process_info" ]]; then
            echo "  Puerto $port/tcp -> $process_info"
        else
            echo "  Puerto $port/tcp -> (proceso no identificado)"
        fi
    done
    echo ""
    
    echo "🔵 PUERTOS UDP EN ESCUCHA:"
    ss -ulnp | while read line; do
        if [[ $line == *":"* ]] && [[ $line != "State"* ]]; then
            port=$(echo "$line" | awk '{print $4}' | cut -d: -f2)
            process_info=$(echo "$line" | grep -o 'users:(([^)]*))' | sed 's/users:((\([^)]*\)))/\1/')
            if [[ -n "$process_info" ]]; then
                echo "  Puerto $port/udp -> $process_info"
            else
                echo "  Puerto $port/udp -> (proceso no identificado)"
            fi
        fi
    done
    echo ""
fi

# =================================================================
# OPCIÓN 3: LSOF (Más detallado por proceso)
# =================================================================
if command_exists lsof; then
    echo "🔎 ANÁLISIS CON LSOF (List Open Files)"
    separator
    
    echo "🌐 PUERTOS DE RED POR PROCESO:"
    lsof -i -P -n | grep LISTEN | sort -k9 -t: -n | while read line; do
        process=$(echo "$line" | awk '{print $1}')
        pid=$(echo "$line" | awk '{print $2}')
        user=$(echo "$line" | awk '{print $3}')
        port_info=$(echo "$line" | awk '{print $9}')
        echo "  $port_info -> $process (PID: $pid, User: $user)"
    done
    echo ""
fi

# =================================================================
# ANÁLISIS DE PROCESOS ESPECÍFICOS
# =================================================================
echo "🔧 PROCESOS IMPORTANTES DETECTADOS"
separator

# Buscar procesos web comunes
web_processes=("nginx" "apache" "httpd" "node" "python" "java")
for process in "${web_processes[@]}"; do
    if pgrep "$process" > /dev/null; then
        echo "✅ $process está ejecutándose:"
        ps aux | grep "$process" | grep -v grep | while read line; do
            pid=$(echo "$line" | awk '{print $2}')
            cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}')
            if command_exists lsof; then
                ports=$(lsof -Pan -p "$pid" -i 2>/dev/null | grep LISTEN | awk '{print $9}' | cut -d: -f2 | sort -n | tr '\n' ',' | sed 's/,$//')
                if [[ -n "$ports" ]]; then
                    echo "    PID $pid: $cmd"
                    echo "    Puertos: $ports"
                fi
            else
                echo "    PID $pid: $cmd"
            fi
        done
        echo ""
    fi
done

# =================================================================
# RESUMEN DE PUERTOS ESPECÍFICOS DEL PROYECTO
# =================================================================
echo "🐉 PUERTOS DEL PROYECTO BEHAVIOURAL DRAGON PRO"
separator

project_ports=(3000 5173 5174 8081)
for port in "${project_ports[@]}"; do
    if command_exists lsof; then
        result=$(lsof -i :$port 2>/dev/null)
        if [[ -n "$result" ]]; then
            echo "✅ Puerto $port está en uso:"
            echo "$result" | grep -v COMMAND | while read line; do
                process=$(echo "$line" | awk '{print $1}')
                pid=$(echo "$line" | awk '{print $2}')
                user=$(echo "$line" | awk '{print $3}')
                echo "    $process (PID: $pid, User: $user)"
            done
        else
            echo "⭕ Puerto $port está libre"
        fi
    else
        if netstat -tln 2>/dev/null | grep ":$port " > /dev/null; then
            echo "✅ Puerto $port está en uso"
        else
            echo "⭕ Puerto $port está libre"
        fi
    fi
done
echo ""

# =================================================================
# ANÁLISIS DE RANGO DE PUERTOS
# =================================================================
echo "📊 ESTADÍSTICAS DE PUERTOS"
separator

if command_exists netstat; then
    tcp_count=$(netstat -tln 2>/dev/null | grep LISTEN | wc -l)
    udp_count=$(netstat -uln 2>/dev/null | wc -l)
    established_count=$(netstat -tn 2>/dev/null | grep ESTABLISHED | wc -l)
    
    echo "📈 Resumen:"
    echo "   Puertos TCP en escucha: $tcp_count"
    echo "   Puertos UDP activos: $udp_count"
    echo "   Conexiones establecidas: $established_count"
fi

# =================================================================
# PUERTOS COMUNES DEL SISTEMA
# =================================================================
echo ""
echo "🔍 VERIFICACIÓN DE PUERTOS COMUNES DEL SISTEMA"
separator

common_ports=(22 53 80 443 3306 5432 6379 27017 9200)
port_descriptions=(
    "SSH"
    "DNS"
    "HTTP"
    "HTTPS"
    "MySQL/MariaDB"
    "PostgreSQL"
    "Redis"
    "MongoDB"
    "Elasticsearch"
)

for i in "${!common_ports[@]}"; do
    port=${common_ports[$i]}
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

# =================================================================
# ANÁLISIS DEL ENTORNO DOCKER
# =================================================================
echo "🐳 INFORMACIÓN DEL CONTENEDOR DOCKER"
separator

echo "📋 Detalles del contenedor:"
if [ -f /.dockerenv ]; then
    echo "   ✅ Ejecutándose dentro de contenedor Docker"
    echo "   📦 Container ID: $(hostname)"
    echo "   🗂️  Volúmenes montados:"
    mount | grep docker | while read line; do
        echo "      - $line"
    done
    echo ""
    
    echo "🌐 Configuración de red del contenedor:"
    if command_exists ip; then
        echo "   🔗 Interfaces de red:"
        ip addr show | grep -E "(inet |UP)" | while read line; do
            echo "      $line"
        done
    fi
    echo ""
    
    echo "⚠️  IMPORTANTE: Los puertos mostrados son del CONTENEDOR, no del HOST NAS"
    echo "   Para ver puertos del NAS host, necesitas ejecutar desde el host directamente"
    echo ""
fi

# =================================================================
# DETECCIÓN DE PUERTOS MAPEADOS DESDE EL HOST
# =================================================================
echo "🔄 ANÁLISIS DE MAPEO DE PUERTOS"
separator

if [ -f /.dockerenv ]; then
    echo "💡 IMPORTANTE - Análisis desde CONTENEDOR Docker:"
    echo "   🏗️  ARQUITECTURA ACTUAL:"
    echo "      📁 Proyecto actual: /volume1/docker/behavioural_dragon_pro (DESARROLLO)"
    echo "      🐳 Docker real/producción: /volume1/docker/avc_ssh_host"
    echo "      🖥️  NAS Host Synology: 10.0.0.10:2222"
    echo ""
    echo "   ⚠️  LIMITACIONES:"
    echo "      - Los puertos mostrados son del CONTENEDOR actual"
    echo "      - Para puertos REALES del NAS host necesitas SSH"
    echo "      - Docker de producción corre en ubicación diferente"
    echo ""
    
    echo "🌐 ACCESO AL NAS HOST REAL:"
    echo "   ssh -p 2222 avctrust@10.0.0.10"
    echo ""
    
    echo "📋 COMANDOS PARA ANÁLISIS REAL EN NAS HOST:"
    echo "   # Todos los contenedores Docker y sus puertos:"
    echo "   docker ps --format 'table {{.Names}}\\t{{.Image}}\\t{{.Ports}}\\t{{.Status}}'"
    echo ""
    echo "   # Puertos del host NAS:"
    echo "   sudo netstat -tlnp | grep LISTEN | sort -k4 -t: -n"
    echo ""
    echo "   # Proyecto de producción específico:"
    echo "   cd /volume1/docker/avc_ssh_host"
    echo "   docker-compose ps"
    echo "   docker-compose logs --tail=50"
    echo ""
    echo "   # Mapeo específico de puertos Docker:"
    echo "   docker port \$(docker ps -q) | grep -v '^$'"
    echo ""
    
    echo "🚀 ¿Quieres ejecutar análisis automático en el NAS host? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "🔌 Preparando análisis del NAS host..."
        echo ""
        
        # Crear un script más completo para el host
        cat > /tmp/nas_host_complete_analysis.sh << 'EOF'
#!/bin/bash
echo "🏠 ANÁLISIS COMPLETO DEL NAS HOST SYNOLOGY"
echo "=========================================="
echo "Fecha: $(date)"
echo "Hostname: $(hostname)"
echo "Usuario: $(whoami)"
echo "IP del host: $(hostname -I | awk '{print $1}')"
echo ""

echo "🐳 CONTENEDORES DOCKER ACTIVOS:"
echo "------------------------------"
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}\t{{.Size}}'
echo ""

echo "📡 PUERTOS DEL HOST NAS EN ESCUCHA:"
echo "----------------------------------"
sudo netstat -tlnp | grep LISTEN | sort -k4 -t: -n | while read line; do
    port=$(echo "$line" | awk '{print $4}' | cut -d: -f2)
    process=$(echo "$line" | awk '{print $7}')
    echo "  Puerto $port -> $process"
done
echo ""

echo "🔗 MAPEO DETALLADO DE PUERTOS DOCKER:"
echo "------------------------------------"
for container in $(docker ps --format '{{.Names}}'); do
    echo "📦 Contenedor: $container"
    docker port "$container" 2>/dev/null | while read mapping; do
        echo "    $mapping"
    done
    echo ""
done

echo "🎯 ANÁLISIS DEL PROYECTO AVC_SSH_HOST (PRODUCCIÓN):"
echo "--------------------------------------------------"
if [ -d "/volume1/docker/avc_ssh_host" ]; then
    cd /volume1/docker/avc_ssh_host
    echo "📂 Ubicación: $(pwd)"
    echo ""
    
    if [ -f "docker-compose.yml" ]; then
        echo "📋 Estado de servicios Docker Compose:"
        docker-compose ps
        echo ""
        
        echo "🔧 Configuración de puertos en docker-compose.yml:"
        grep -n -A 3 -B 1 "ports:" docker-compose.yml 2>/dev/null || echo "   (No se encontró configuración de puertos)"
        echo ""
        
        echo "📊 Últimos logs del proyecto (últimas 20 líneas):"
        docker-compose logs --tail=20 2>/dev/null | head -50 || echo "   (Logs no disponibles)"
        echo ""
    else
        echo "⚠️  No se encontró docker-compose.yml en $(pwd)"
        echo "📁 Archivos disponibles:"
        ls -la | head -10
    fi
else
    echo "⚠️  Directorio /volume1/docker/avc_ssh_host no encontrado"
    echo "📁 Directorios Docker disponibles:"
    find /volume1/docker -maxdepth 1 -type d 2>/dev/null | head -10
fi

echo ""
echo "🌐 INFORMACIÓN DE RED DEL HOST:"
echo "------------------------------"
echo "Interfaces de red:"
ip addr show 2>/dev/null | grep -E "(inet |UP)" | while read line; do
    echo "  $line"
done
echo ""

echo "🔥 PROCESOS PRINCIPALES QUE USAN PUERTOS:"
echo "----------------------------------------"
ps aux | grep -E "(docker|nginx|apache|node|python|java)" | grep -v grep | while read line; do
    pid=$(echo "$line" | awk '{print $2}')
    cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}' | cut -c1-80)
    echo "  PID $pid: $cmd"
done

echo ""
echo "✅ ANÁLISIS COMPLETADO DESDE NAS HOST"
echo "================================================"
EOF
        
        echo "📝 Script de análisis creado: /tmp/nas_host_complete_analysis.sh"
        echo ""
        echo "🔄 Intentando copiar y ejecutar en el NAS host..."
        
        # Intentar copiar el script al NAS host
        if scp -P 2222 /tmp/nas_host_complete_analysis.sh avctrust@10.0.0.10:/tmp/ 2>/dev/null; then
            echo "✅ Script copiado exitosamente al NAS host"
            echo "🚀 Ejecutando análisis en el NAS host..."
            echo ""
            ssh -p 2222 avctrust@10.0.0.10 'chmod +x /tmp/nas_host_complete_analysis.sh && /tmp/nas_host_complete_analysis.sh'
        else
            echo "❌ Error al copiar script. Ejecuta manualmente:"
            echo "   1. Conecta al NAS: ssh -p 2222 avctrust@10.0.0.10"
            echo "   2. Copia el script desde /tmp/nas_host_complete_analysis.sh"
            echo "   3. Ejecuta el análisis"
            echo ""
            echo "🔗 Intentando conexión directa..."
            ssh -p 2222 avctrust@10.0.0.10
        fi
    else
        echo "ℹ️  Análisis automático cancelado."
        echo "💡 Para análisis manual, conéctate con:"
        echo "   ssh -p 2222 avctrust@10.0.0.10"
    fi
else
    echo "💡 Información sobre mapeo de puertos:"
    echo "   - Este script se ejecuta en el sistema nativo"
    echo "   - Para análisis completo de Docker, ve a /volume1/docker/avc_ssh_host"
fi

echo ""
echo "🎯 ANÁLISIS COMPLETADO"
echo "Usa 'sudo' para obtener información más detallada de procesos de otros usuarios"
echo "Ejemplo: sudo netstat -tlnp | grep LISTEN"
