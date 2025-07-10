#!/bin/bash

# =================================================================
# SCRIPT AVANZADO PARA DETECTAR PUERTOS EN NAS
# Incluye detección de contenedores Docker y procesos host
# =================================================================

echo "🔍 ANÁLISIS COMPLETO DE PUERTOS - NAS SYSTEM"
echo "============================================="
echo "Fecha: $(date)"
echo "Hostname: $(hostname)"
echo "Sistema: $(uname -a)"
echo ""

# Detectar si estamos en un contenedor
if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    echo "🐳 DETECTADO: Ejecutándose dentro de un contenedor Docker"
    IN_CONTAINER=true
else
    echo "🖥️  DETECTADO: Ejecutándose en host nativo"
    IN_CONTAINER=false
fi
echo ""

# =================================================================
# FUNCIÓN PARA DETECTAR PROCESOS Y PUERTOS
# =================================================================
check_port_usage() {
    echo "📡 ANÁLISIS DETALLADO DE PUERTOS"
    echo "================================"
    
    # Usar netstat si está disponible
    if command -v netstat >/dev/null 2>&1; then
        echo "🟢 PUERTOS TCP EN ESCUCHA (netstat):"
        netstat -tlnp 2>/dev/null | grep LISTEN | sort -k4 -t: -n | while IFS= read -r line; do
            proto=$(echo "$line" | awk '{print $1}')
            address=$(echo "$line" | awk '{print $4}')
            port=$(echo "$address" | rev | cut -d: -f1 | rev)
            pid_process=$(echo "$line" | awk '{print $7}')
            
            if [[ "$pid_process" == "-" ]]; then
                echo "  Puerto $port/tcp -> (sin permisos para ver proceso)"
            else
                pid=$(echo "$pid_process" | cut -d/ -f1)
                process=$(echo "$pid_process" | cut -d/ -f2)
                echo "  Puerto $port/tcp -> $process (PID: $pid)"
            fi
        done
        echo ""
        
        echo "🔵 PUERTOS UDP EN ESCUCHA (netstat):"
        netstat -ulnp 2>/dev/null | grep -v "Active\|Proto" | while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                address=$(echo "$line" | awk '{print $4}')
                port=$(echo "$address" | rev | cut -d: -f1 | rev)
                pid_process=$(echo "$line" | awk '{print $6}')
                
                if [[ "$pid_process" == "-" ]]; then
                    echo "  Puerto $port/udp -> (sin permisos para ver proceso)"
                else
                    pid=$(echo "$pid_process" | cut -d/ -f1)
                    process=$(echo "$pid_process" | cut -d/ -f2)
                    echo "  Puerto $port/udp -> $process (PID: $pid)"
                fi
            fi
        done
        echo ""
    fi
    
    # Usar ss como alternativa
    if command -v ss >/dev/null 2>&1; then
        echo "⚡ PUERTOS TCP EN ESCUCHA (ss):"
        ss -tlnp 2>/dev/null | grep LISTEN | while IFS= read -r line; do
            address=$(echo "$line" | awk '{print $4}')
            port=$(echo "$address" | rev | cut -d: -f1 | rev)
            users=$(echo "$line" | grep -o 'users:(([^)]*))' | sed 's/users:((\([^)]*\)))/\1/')
            
            if [[ -n "$users" ]]; then
                echo "  Puerto $port/tcp -> $users"
            else
                echo "  Puerto $port/tcp -> (proceso no identificado)"
            fi
        done
        echo ""
    fi
}

# =================================================================
# VERIFICAR PUERTOS ESPECÍFICOS DEL PROYECTO
# =================================================================
check_project_ports() {
    echo "🐉 ESTADO DE PUERTOS DEL PROYECTO"
    echo "================================="
    
    declare -A project_ports=(
        [3000]="Backend API (Node.js/Express)"
        [5173]="Frontend Dev Server (Vite)"
        [5174]="Frontend Dev Server Alt (Vite)"
        [8080]="HTTP Alternativo"
        [8081]="Frontend Docker (Nginx)"
        [3306]="MariaDB/MySQL"
        [22]="SSH"
        [80]="HTTP"
        [443]="HTTPS"
    )
    
    for port in "${!project_ports[@]}"; do
        desc="${project_ports[$port]}"
        
        # Verificar con múltiples métodos
        is_used=false
        process_info=""
        
        # Método 1: netstat
        if command -v netstat >/dev/null 2>&1; then
            if netstat -tln 2>/dev/null | grep -q ":$port "; then
                is_used=true
                process_info=$(netstat -tlnp 2>/dev/null | grep ":$port " | awk '{print $7}' | head -1)
            fi
        fi
        
        # Método 2: ss
        if ! $is_used && command -v ss >/dev/null 2>&1; then
            if ss -tln 2>/dev/null | grep -q ":$port "; then
                is_used=true
                process_info=$(ss -tlnp 2>/dev/null | grep ":$port " | grep -o 'users:(([^)]*))' | head -1)
            fi
        fi
        
        # Método 3: lsof
        if ! $is_used && command -v lsof >/dev/null 2>&1; then
            if lsof -i :$port 2>/dev/null | grep -q LISTEN; then
                is_used=true
                process_info=$(lsof -i :$port 2>/dev/null | grep LISTEN | awk '{print $1}' | head -1)
            fi
        fi
        
        if $is_used; then
            echo "✅ Puerto $port ($desc) -> EN USO"
            if [[ -n "$process_info" ]]; then
                echo "    Proceso: $process_info"
            fi
        else
            echo "⭕ Puerto $port ($desc) -> LIBRE"
        fi
    done
    echo ""
}

# =================================================================
# VERIFICAR PROCESOS ACTIVOS RELACIONADOS
# =================================================================
check_active_processes() {
    echo "🔧 PROCESOS RELACIONADOS CON EL PROYECTO"
    echo "========================================"
    
    # Buscar procesos específicos
    processes=("node" "nginx" "apache" "mysql" "mariadb" "docker" "vite")
    
    for proc in "${processes[@]}"; do
        if pgrep "$proc" >/dev/null 2>&1; then
            echo "✅ $proc está ejecutándose:"
            ps aux | grep "$proc" | grep -v grep | head -3 | while IFS= read -r line; do
                pid=$(echo "$line" | awk '{print $2}')
                cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}' | cut -c1-80)
                echo "    PID $pid: $cmd..."
            done
            echo ""
        else
            echo "⭕ $proc no está ejecutándose"
        fi
    done
}

# =================================================================
# VERIFICAR CONECTIVIDAD DE RED
# =================================================================
check_network_connectivity() {
    echo "🌐 PRUEBAS DE CONECTIVIDAD"
    echo "========================="
    
    # Test URLs importantes
    test_urls=(
        "localhost:3000"
        "localhost:5173"
        "localhost:5174"
        "192.169.145.43:3306"
        "10.0.0.10:3000"
    )
    
    for url in "${test_urls[@]}"; do
        host=$(echo "$url" | cut -d: -f1)
        port=$(echo "$url" | cut -d: -f2)
        
        if timeout 2 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
            echo "✅ $url -> ACCESIBLE"
        else
            echo "❌ $url -> NO ACCESIBLE"
        fi
    done
    echo ""
}

# =================================================================
# GENERAR RESUMEN EJECUTIVO
# =================================================================
generate_summary() {
    echo "📊 RESUMEN EJECUTIVO"
    echo "==================="
    
    # Contar puertos en uso
    if command -v netstat >/dev/null 2>&1; then
        tcp_listening=$(netstat -tln 2>/dev/null | grep LISTEN | wc -l)
        udp_active=$(netstat -uln 2>/dev/null | grep -v "Active\|Proto" | wc -l)
        tcp_established=$(netstat -tn 2>/dev/null | grep ESTABLISHED | wc -l)
        
        echo "📈 Estadísticas de red:"
        echo "   - Puertos TCP en escucha: $tcp_listening"
        echo "   - Sockets UDP activos: $udp_active"
        echo "   - Conexiones TCP establecidas: $tcp_established"
    fi
    
    # Estado del contenedor
    if $IN_CONTAINER; then
        echo "🐳 Entorno: Contenedor Docker"
        echo "   - Algunos puertos pueden estar mapeados al host"
        echo "   - Para ver puertos del host: docker port <container_id>"
    else
        echo "🖥️  Entorno: Host nativo"
    fi
    
    echo ""
    echo "💡 RECOMENDACIONES:"
    echo "   - Para ver todos los procesos: sudo netstat -tlnp"
    echo "   - Para monitoreo en tiempo real: watch -n 2 'netstat -tln'"
    echo "   - Para ver puertos Docker: docker ps --format 'table {{.Names}}\t{{.Ports}}'"
}

# =================================================================
# EJECUTAR TODAS LAS VERIFICACIONES
# =================================================================
main() {
    check_port_usage
    check_project_ports
    check_active_processes
    check_network_connectivity
    generate_summary
    
    echo ""
    echo "🎯 ANÁLISIS COMPLETADO - $(date)"
    echo "Para más detalles, ejecuta con sudo para ver todos los procesos"
}

# Ejecutar función principal
main
