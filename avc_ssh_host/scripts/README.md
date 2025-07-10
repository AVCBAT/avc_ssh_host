# Scripts de Análisis Docker - NAS Synology

Este directorio contiene scripts de análisis y monitoreo para el entorno Docker del NAS Synology.

## 📁 Estructura

```
/home/avctrust/docker/avc_ssh_host/
├── scripts/          # Scripts de análisis y monitoreo
├── docs/            # Documentación del entorno
├── analysis/        # Reportes generados
├── data/           # Datos del proyecto SSH
├── docker-compose.yml
└── Dockerfile
```

## 🔧 Scripts Disponibles

### Scripts Principales

#### `docker-master-analysis.sh`
**Script maestro que ejecuta todos los análisis**
- Análisis completo del entorno Docker
- Información del sistema
- Análisis de proyectos
- Análisis de puertos
- Estado de contenedores
- Genera reporte consolidado

```bash
./docker-master-analysis.sh
```

#### `docker-ports-analysis.sh`
**Análisis detallado de puertos**
- Puertos en uso del sistema
- Configuración de puertos por proyecto
- Detección de conflictos
- Puertos importantes del entorno

```bash
./docker-ports-analysis.sh
```

#### `docker-environment-analysis.sh`
**Análisis del entorno y arquitectura**
- Detección del entorno (contenedor vs host)
- Información del sistema
- Estructura de proyectos Docker
- Configuración de red
- Análisis de seguridad básico

```bash
./docker-environment-analysis.sh
```

## 🎯 Uso Recomendado

### Para Análisis Completo
```bash
# Ejecutar desde cualquier proyecto Docker
cd /home/avctrust/docker/avc_ssh_host/scripts
./docker-master-analysis.sh
```

### Para Análisis Específico de Puertos
```bash
./docker-ports-analysis.sh
```

### Para Verificar el Entorno
```bash
./docker-environment-analysis.sh
```

## 🌐 Entornos de Ejecución

### Desde Contenedor Docker (VS Code)
- Los scripts detectan automáticamente que están en un contenedor
- Muestran información del contenedor actual
- Proporcionan instrucciones para análisis del host real

### Desde Host NAS (SSH)
```bash
ssh -p 2222 avctrust@10.0.0.10
cd /volume1/docker/avc_ssh_host/scripts
./docker-master-analysis.sh
```

## 📊 Reportes Generados

Los scripts generan reportes en `/tmp/docker_*_analysis_YYYYMMDD_HHMMSS/`:

- `system_info.txt` - Información del sistema
- `projects_analysis.txt` - Análisis de proyectos Docker
- `ports_analysis.txt` - Análisis de puertos
- `containers_analysis.txt` - Estado de contenedores
- `consolidated_report.txt` - Reporte consolidado

## 🏗️ Arquitectura del Entorno

### Estructura de Proyectos Docker
El NAS contiene múltiples proyectos Docker en `/home/avctrust/docker/` (o `/volume1/docker/` desde SSH):

- **avc_ssh_host** - Proyecto principal con scripts de análisis
- **behavioural_dragon_pro** - Aplicación web Node.js
- **avc_ai_terminal** - Terminal AI con Python
- **avc_api** - API en Python
- **avc_database** - Base de datos
- Y otros 35+ proyectos

### Puertos Principales
- **22** - SSH del NAS
- **2222** - SSH externo del NAS
- **2229** - SSH del contenedor avc_ssh_host
- **3000** - Frontend Behavioural Dragon Pro
- **8081** - Backend/Nginx Behavioural Dragon Pro
- **8080-8090** - Varios servicios web
- **5000-5110** - APIs y servicios Python

## 🔧 Mantenimiento

### Hacer Scripts Ejecutables
```bash
chmod +x /home/avctrust/docker/avc_ssh_host/scripts/*.sh
```

### Limpiar Reportes Antiguos
```bash
rm -rf /tmp/docker_*_analysis_*
```

### Actualizar Scripts
Los scripts se mantienen en este directorio central para uso en todos los proyectos.

## ⚠️ Notas Importantes

1. **Entorno de Contenedor vs Host**: Los scripts detectan automáticamente el entorno
2. **Permisos Docker**: Algunos comandos Docker requieren ejecutarse desde el host NAS
3. **SSH para Análisis Completo**: Para análisis completo del host, usar SSH
4. **Conflictos de Puertos**: Los scripts detectan automáticamente conflictos entre proyectos

## 📋 Comandos Útiles Adicionales

### Docker
```bash
docker ps                           # Contenedores activos
docker ps -a                        # Todos los contenedores
docker stats                        # Estadísticas en tiempo real
docker port CONTAINER               # Puertos de un contenedor
docker-compose ps                   # Estado de servicios
```

### Sistema
```bash
netstat -tlnp | grep LISTEN         # Puertos en escucha
ss -tlnp | grep LISTEN              # Puertos (comando moderno)
lsof -i                             # Conexiones de red activas
htop                                # Monitor de procesos
```

### Desde Host NAS
```bash
ssh -p 2222 avctrust@10.0.0.10
sudo netstat -tlnp | grep LISTEN    # Puertos del host real
sudo docker ps                      # Contenedores desde host
```

## 🆘 Solución de Problemas

### Script no ejecutable
```bash
chmod +x /path/to/script.sh
```

### Docker no disponible
- Verificar que Docker esté instalado
- Ejecutar desde el host NAS si es necesario
- Verificar permisos de usuario

### Acceso denegado a directorios
- Verificar permisos de directorio
- Ejecutar con sudo si es necesario desde host
- Verificar que el directorio existe

---

**Documentación actualizada:** $(date)
**Mantenido por:** AVCTrust
**Ubicación:** `/home/avctrust/docker/avc_ssh_host/scripts/`
