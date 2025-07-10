#!/bin/bash

# =================================================================
# SCRIPT PARA ANALIZAR ARQUITECTURA: CONTENEDOR DOCKER EN NAS
# =================================================================

echo "🏗️  ANÁLISIS DE ARQUITECTURA - CONTENEDOR EN NAS SYNOLOGY"
echo "=========================================================="
echo "Fecha: $(date)"
echo ""

# =================================================================
# VERIFICACIÓN DEL ENTORNO
# =================================================================
echo "🔍 VERIFICACIÓN DEL ENTORNO ACTUAL"
echo "=================================="

echo "📍 Ubicación actual:"
echo "   PWD: $(pwd)"
echo "   Usuario: $(whoami)"
echo "   Hostname: $(hostname)"

if [ -f /.dockerenv ]; then
    echo "   🐳 CONFIRMADO: Estamos en un contenedor Docker"
    echo "   📦 Container ID: $(hostname)"
else
    echo "   🖥️  Estamos en el sistema host"
fi
echo ""

# =================================================================
# INFORMACIÓN DEL CONTENEDOR
# =================================================================
if [ -f /.dockerenv ]; then
    echo "🐳 INFORMACIÓN DEL CONTENEDOR DOCKER"
    echo "===================================="
    
    echo "📋 Detalles del contenedor:"
    echo "   Hostname del contenedor: $(hostname)"
    echo "   Container ID corto: $(hostname | cut -c1-12)"
    
    echo ""
    echo "🗂️  Sistema de archivos:"
    echo "   Root filesystem:"
    mount | grep ' / ' | head -1
    
    echo ""
    echo "   Montajes de Docker detectados:"
    mount | grep docker | head -5 | while read line; do
        echo "   - $line"
    done
    
    echo ""
    echo "🌐 Configuración de red del contenedor:"
    if command_exists ip; then
        echo "   Interfaces:"
        ip link show | grep -E "^[0-9]" | while read line; do
            echo "   - $line"
        done
        
        echo ""
        echo "   Direcciones IP:"
        ip addr show | grep "inet " | while read line; do
            echo "   - $line"
        done
    else
        echo "   (comando 'ip' no disponible)"
    fi
    
    echo ""
    echo "🚪 Gateway y rutas:"
    if [ -f /proc/net/route ]; then
        echo "   Gateway por defecto:"
        route -n 2>/dev/null | grep "^0.0.0.0" || echo "   (no detectado)"
    fi
fi

# =================================================================
# PROCESOS Y PUERTOS DENTRO DEL CONTENEDOR
# =================================================================
echo ""
echo "⚙️  PROCESOS ACTIVOS EN EL CONTENEDOR"
echo "===================================="

echo "🔧 Procesos principales:"
ps aux | head -10 | while read line; do
    echo "   $line"
done

echo ""
echo "🌐 Puertos en escucha (dentro del contenedor):"
if command_exists netstat; then
    netstat -tln 2>/dev/null | grep LISTEN | while read line; do
        port=$(echo "$line" | awk '{print $4}' | cut -d: -f2)
        echo "   Puerto $port/tcp"
    done
else
    echo "   (netstat no disponible)"
fi

# =================================================================
# CONEXIÓN AL HOST NAS
# =================================================================
echo ""
echo "🏠 CONEXIÓN AL HOST NAS"
echo "======================"

echo "💡 Para obtener información del NAS host desde este contenedor:"
echo ""
echo "1. 📋 Ver todos los contenedores Docker en el NAS:"
echo "   Ejecutar en el HOST NAS: docker ps -a"
echo ""
echo "2. 🔗 Ver mapeo de puertos de este contenedor:"
echo "   Ejecutar en el HOST NAS: docker port $(hostname)"
echo ""
echo "3. 🌐 Ver puertos del HOST NAS:"
echo "   Ejecutar en el HOST NAS: netstat -tlnp | grep LISTEN"
echo ""
echo "4. 📊 Ver recursos del sistema NAS:"
echo "   Ejecutar en el HOST NAS: docker stats $(hostname)"

# =================================================================
# COMANDOS PARA EJECUTAR EN EL HOST NAS
# =================================================================
echo ""
echo "🎯 COMANDOS RECOMENDADOS PARA EL HOST NAS"
echo "========================================="

cat << 'EOF'

# Conectarse por SSH al NAS host (desde tu PC Windows):
ssh usuario@IP_DEL_NAS

# Una vez en el host NAS, ejecutar:

# 1. Ver contenedores Docker activos:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 2. Ver puertos mapeados de este contenedor específico:
docker port CONTAINER_NAME_OR_ID

# 3. Ver todos los puertos en uso en el HOST NAS:
sudo netstat -tlnp | grep LISTEN

# 4. Ver procesos y recursos del NAS:
top
df -h
free -h

# 5. Ver información de Docker:
docker info
docker system df

# 6. Ver logs de este contenedor:
docker logs CONTAINER_NAME_OR_ID

EOF

# =================================================================
# DETECTAR PROYECTO BEHAVIOURAL DRAGON PRO
# =================================================================
echo ""
echo "🐉 PROYECTO BEHAVIOURAL DRAGON PRO"
echo "=================================="

if [ -f "/home/avctrust/docker/behavioural_dragon_pro/package.json" ]; then
    echo "✅ Proyecto detectado en: /home/avctrust/docker/behavioural_dragon_pro/"
    
    echo ""
    echo "📦 Información del proyecto:"
    if command_exists node; then
        echo "   Node.js: $(node --version)"
    fi
    if command_exists npm; then
        echo "   npm: $(npm --version)"
    fi
    
    echo ""
    echo "🔍 Puertos configurados en el proyecto:"
    if [ -f "/home/avctrust/docker/behavioural_dragon_pro/.env" ]; then
        grep -E "(PORT|VITE.*PORT)" /home/avctrust/docker/behavioural_dragon_pro/.env | while read line; do
            echo "   $line"
        done
    fi
    
    echo ""
    echo "📊 Procesos Node.js activos:"
    ps aux | grep node | grep -v grep | while read line; do
        echo "   $line"
    done
    
else
    echo "❌ Proyecto no encontrado en la ubicación esperada"
fi

echo ""
echo "✅ ANÁLISIS COMPLETADO"
echo ""
echo "🎯 RESUMEN:"
echo "==========="
echo "- Estás ejecutando comandos DENTRO de un contenedor Docker"
echo "- El contenedor está corriendo en tu NAS Synology"
echo "- Para ver puertos del NAS host, necesitas SSH directo al NAS"
echo "- Los puertos mostrados aquí son solo del contenedor, no del host"
