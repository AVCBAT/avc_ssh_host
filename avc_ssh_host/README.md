# AVC SSH Host - Proyecto Principal Docker

## 📋 Descripción
Este es el proyecto principal de gestión Docker del NAS Synology. Contiene scripts de análisis, documentación y herramientas para monitorear todo el entorno Docker.

## 📁 Estructura del Proyecto

```
/home/avctrust/docker/avc_ssh_host/
├── scripts/                    # Scripts de análisis y monitoreo
│   ├── docker-master-analysis.sh
│   ├── docker-ports-analysis.sh
│   ├── docker-environment-analysis.sh
│   └── README.md
├── docs/                      # Documentación completa
│   ├── ARCHITECTURE_DOCKER_NAS.md
│   ├── COMPLETE_DOCKER_ANALYSIS.md
│   └── [documentos adicionales]
├── analysis/                  # Reportes generados
├── data/                     # Datos del proyecto SSH
├── docker-compose.yml        # Configuración Docker
├── Dockerfile               # Imagen Docker
└── README.md               # Este archivo
```

## 🎯 Propósito Principal

Este proyecto centraliza todas las herramientas de análisis y monitoreo para el entorno Docker del NAS, proporcionando:

1. **Scripts de análisis unificados** para todos los proyectos
2. **Documentación centralizada** del entorno
3. **Herramientas de monitoreo** automatizadas
4. **Detección de conflictos** entre proyectos

## 🚀 Uso Rápido

### Análisis Completo del Entorno
```bash
cd /home/avctrust/docker/avc_ssh_host/scripts
./docker-master-analysis.sh
```

### Análisis de Puertos
```bash
./docker-ports-analysis.sh
```

### Análisis del Entorno
```bash
./docker-environment-analysis.sh
```

## 🌐 Entorno del Sistema

### Información del NAS
- **Host:** AVCServer (NAS Synology)
- **SSH:** ssh -p 2222 avctrust@10.0.0.10
- **Proyectos Docker:** 41 total
- **Ubicación real:** /volume1/docker/ (desde SSH)
- **Ubicación contenedor:** /home/avctrust/docker/

### Proyectos Docker Principales
- **behavioural_dragon_pro** - Aplicación web Node.js
- **avc_ai_terminal** - Terminal AI Python
- **avc_api** - API Python
- **avc_remote_hub** - Hub de conectividad
- **Y 37 proyectos adicionales**

## 📊 Análisis del Entorno

### Estado Actual (Última verificación)
- ✅ 41 proyectos Docker identificados
- ✅ 29 proyectos con docker-compose
- ✅ Scripts de análisis implementados
- ⚠️ 4 conflictos de puertos detectados
- ✅ Documentación centralizada

### Puertos Importantes
| Puerto | Proyecto | Servicio |
|--------|----------|----------|
| 2229 | avc_ssh_host | SSH Container |
| 3000 | behavioural_dragon_pro | Frontend |
| 8081 | behavioural_dragon_pro | Backend |
| 8086 | avc_ai_terminal | API |
| 8377 | avc_code_server | VS Code |

## 🔧 Scripts Disponibles

### Scripts Principales
1. **docker-master-analysis.sh** - Análisis completo del entorno
2. **docker-ports-analysis.sh** - Análisis detallado de puertos
3. **docker-environment-analysis.sh** - Análisis de arquitectura

### Funcionalidades
- ✅ Detección automática de entorno (contenedor vs host)
- ✅ Análisis de todos los proyectos Docker
- ✅ Detección de conflictos de puertos
- ✅ Generación de reportes detallados
- ✅ Recomendaciones de optimización

## 📚 Documentación

### Documentos Principales
- **ARCHITECTURE_DOCKER_NAS.md** - Arquitectura completa del entorno
- **COMPLETE_DOCKER_ANALYSIS.md** - Análisis detallado actual
- **README.md** (scripts/) - Documentación de scripts

### Reportes Automáticos
Los scripts generan reportes en `/tmp/docker_*_analysis_*/`:
- system_info.txt
- projects_analysis.txt  
- ports_analysis.txt
- containers_analysis.txt
- consolidated_report.txt

## 🔄 Mantenimiento

### Ejecución Recomendada
- **Diaria:** Verificación rápida con docker-environment-analysis.sh
- **Semanal:** Análisis completo con docker-master-analysis.sh
- **Mensual:** Revisión de documentación y limpieza

### Comandos de Mantenimiento
```bash
# Limpiar reportes antiguos
rm -rf /tmp/docker_*_analysis_*

# Verificar permisos
chmod +x /home/avctrust/docker/avc_ssh_host/scripts/*.sh

# Actualizar desde proyecto actual
# (Los scripts se mantienen actualizados aquí)
```

## 🌍 Acceso Remoto

### Desde VS Code (Contenedor)
```bash
cd /home/avctrust/docker/avc_ssh_host/scripts
./docker-master-analysis.sh
```

### Desde Host NAS (SSH)
```bash
ssh -p 2222 avctrust@10.0.0.10
cd /volume1/docker/avc_ssh_host/scripts
./docker-master-analysis.sh
```

## ⚠️ Consideraciones Importantes

1. **Centralización:** Todos los scripts están centralizados aquí para uso en cualquier proyecto
2. **Detección de entorno:** Los scripts detectan automáticamente si están ejecutándose en contenedor o host
3. **Permisos:** Algunos análisis requieren ejecutarse desde el host NAS
4. **Conflictos:** Se detectan automáticamente conflictos de puertos entre proyectos

## 🆘 Solución de Problemas

### Script no ejecutable
```bash
chmod +x /home/avctrust/docker/avc_ssh_host/scripts/SCRIPT_NAME.sh
```

### No se encuentra directorio
```bash
# Verificar que estás en la ubicación correcta
pwd
ls -la /home/avctrust/docker/avc_ssh_host/
```

### Docker no disponible
```bash
# Ejecutar desde host NAS
ssh -p 2222 avctrust@10.0.0.10
```

## 📈 Futuras Mejoras

1. Monitoreo automatizado con cron
2. Alertas por email en caso de problemas
3. Dashboard web para visualización
4. API para consulta de estado remoto
5. Integración con herramientas de CI/CD

---

**Proyecto mantenido por:** AVCTrust  
**Última actualización:** 10 de julio de 2025  
**Ubicación:** `/home/avctrust/docker/avc_ssh_host/`  
**Contacto:** Para soporte, revisar documentación en `/docs/`
