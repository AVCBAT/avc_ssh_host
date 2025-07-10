# DOCUMENTACIÓN DE ARQUITECTURA - ENTORNO DOCKER NAS SYNOLOGY

## 📋 Información General

**Fecha de actualización:** 10 de julio de 2025  
**Sistema:** NAS Synology (AVCServer)  
**Usuario principal:** avctrust  
**Acceso SSH:** ssh -p 2222 avctrust@10.0.0.10  

## 🏗️ Arquitectura del Sistema

### Estructura Principal
```
NAS Synology (AVCServer)
├── /volume1/docker/                    # Proyectos Docker (host real)
│   ├── avc_ssh_host/                   # Proyecto principal con scripts
│   ├── behavioural_dragon_pro/         # Aplicación web Node.js
│   ├── avc_ai_terminal/               # Terminal AI Python
│   ├── avc_api/                       # API Python
│   └── [38+ proyectos adicionales]
├── /volume1/homes/avctrust/           # Home del usuario
└── /home/avctrust/docker/             # Montaje en contenedores
```

### Relación Desarrollo vs Producción
- **Desarrollo:** Workspace VS Code en contenedor Docker
- **Host Real:** NAS Synology con Docker nativo
- **Acceso:** SSH puerto 2222 para host real

## 📂 Proyectos Docker Identificados (41 total)

### Proyectos Principales
| Proyecto | Tecnología | Puertos | Estado |
|----------|------------|---------|--------|
| **avc_ssh_host** | Docker/Scripts | 2229→22 | Activo |
| **behavioural_dragon_pro** | Node.js | 3000, 8081→80 | Desarrollo |
| **avc_ai_terminal** | Python | 8086→5000 | Activo |
| **avc_api** | Python | 5080→5000 | Activo |
| **avc_remote_hub** | Docker | 8081→8080 | Activo |
| **avc_code_server** | VS Code | 8377→8443 | Activo |
| **deepseek** | Python | 5110→5110 | Activo |

### Proyectos con Docker Compose
- avc_autodeploy_manager
- avc_converter  
- avc_dalle_worker
- avc_database
- avc_db_mirror
- avc_dev_container
- avc_fft_streamer
- avc_gemini_bot
- avc_ha_editor
- avc_smtp
- avc_sonarqube
- avc_test123
- avc_text_worker
- avc_wireguard
- bind9
- copilot_demo
- esphome
- telegram_download
- trustvault
- youtube_mp3_downloader

## 🌐 Mapa de Puertos

### Puertos del Sistema
| Puerto | Servicio | Proyecto | Descripción |
|--------|----------|----------|-------------|
| 22 | SSH | Sistema | SSH interno NAS |
| 2222 | SSH | Sistema | SSH externo NAS |
| 2229 | SSH | avc_ssh_host | SSH contenedor |
| 3000 | HTTP | behavioural_dragon_pro | Frontend desarrollo |
| 5080 | HTTP | avc_api | API Python |
| 5082 | HTTP | avc_ha_editor | Editor HA |
| 5110 | WebSocket | deepseek | DeepSeek AI |
| 8081 | HTTP | multiple | Nginx/Proxy |
| 8086 | HTTP | multiple | Apps Python |
| 8377 | HTTPS | avc_code_server | VS Code Server |

### ⚠️ Conflictos de Puertos Detectados
1. **Puerto 5090** - 3 proyectos
2. **Puerto 8081** - 2 proyectos (behavioural_dragon_pro, avc_remote_hub)
3. **Puerto 8086** - 2 proyectos (avc_ai_terminal, youtube_mp3_downloader)

## 🐳 Configuración Docker

### Contenedores Activos (Variable)
Los contenedores activos dependen de qué proyectos están ejecutándose en cada momento.

### Imágenes Base Comunes
- **Node.js** - Para aplicaciones web
- **Python** - Para APIs y servicios AI
- **Nginx** - Para proxy y serving
- **MariaDB/MySQL** - Para bases de datos
- **Ubuntu/Alpine** - Como base del sistema

## 📁 Organización de Scripts y Documentación

### Ubicación Centralizada
```
/home/avctrust/docker/avc_ssh_host/
├── scripts/
│   ├── docker-master-analysis.sh      # Script principal
│   ├── docker-ports-analysis.sh       # Análisis de puertos
│   ├── docker-environment-analysis.sh # Análisis del entorno
│   └── README.md                      # Documentación de scripts
├── docs/
│   ├── ARCHITECTURE_DOCKER_NAS.md    # Este documento
│   ├── COMPLETE_DOCKER_ANALYSIS.md   # Análisis completo
│   └── [otros documentos]
└── analysis/                          # Reportes generados
```

### Ventajas de la Centralización
1. **Accesibilidad:** Scripts disponibles desde cualquier proyecto
2. **Mantenimiento:** Actualizaciones centralizadas
3. **Consistencia:** Mismos scripts para todos los proyectos
4. **Documentación:** Todo en un lugar conocido

## 🔧 Procedimientos de Análisis

### Análisis Completo del Entorno
```bash
# Desde cualquier proyecto
cd /home/avctrust/docker/avc_ssh_host/scripts
./docker-master-analysis.sh
```

### Análisis desde Host Real
```bash
ssh -p 2222 avctrust@10.0.0.10
cd /volume1/docker/avc_ssh_host/scripts
./docker-master-analysis.sh
```

### Análisis Específico de Puertos
```bash
./docker-ports-analysis.sh
```

## 📊 Métricas del Entorno

### Estadísticas Actuales
- **Total proyectos:** 41
- **Con docker-compose:** 29
- **Con Dockerfile:** 25+
- **Proyectos Node.js:** 3+
- **Proyectos Python:** 20+
- **Puertos configurados:** 18
- **Conflictos detectados:** 4

### Recursos del Sistema
- **CPU:** Variable según NAS
- **RAM:** Información disponible via scripts
- **Almacenamiento:** Múltiples volúmenes
- **Red:** Interfaces Ethernet/WiFi

## 🌐 Configuración de Red

### Interfaces Principales
- **Ethernet:** Conexión principal del NAS
- **Docker Networks:** Redes internas de contenedores
- **Bridge Networks:** Para comunicación entre contenedores

### Acceso Externo
- **SSH:** Puerto 2222 para acceso externo
- **Web Services:** Puertos 8000-8999 principalmente
- **APIs:** Puertos 5000-5999 principalmente

## 🔒 Consideraciones de Seguridad

### Acceso SSH
- Puerto no estándar (2222)
- Autenticación por clave/contraseña
- Acceso limitado a usuario avctrust

### Contenedores Docker
- Aislamiento de procesos
- Mapeo de puertos controlado
- Volúmenes montados según necesidad

### Recomendaciones
1. Revisar periódicamente conflictos de puertos
2. Monitorear uso de recursos
3. Mantener actualizados los contenedores
4. Backup regular de configuraciones

## 🔄 Mantenimiento y Monitoreo

### Scripts de Monitoreo
Los scripts proporcionan:
- Estado del sistema en tiempo real
- Análisis de recursos
- Detección de problemas
- Generación de reportes

### Frecuencia Recomendada
- **Diario:** Verificación rápida de estado
- **Semanal:** Análisis completo del entorno
- **Mensual:** Revisión de arquitectura y limpieza

### Comandos de Mantenimiento
```bash
# Limpieza Docker
docker system prune

# Estadísticas en tiempo real
docker stats

# Logs de contenedores
docker logs CONTAINER_NAME

# Reinicio de servicios
docker-compose restart
```

## 📋 Próximos Pasos Recomendados

1. **Resolver conflictos de puertos identificados**
2. **Implementar monitoreo automatizado**
3. **Crear backup automatizado de configuraciones**
4. **Documentar procedimientos de deployment**
5. **Optimizar uso de recursos Docker**

## 🆘 Solución de Problemas Comunes

### Contenedor no inicia
1. Verificar conflictos de puertos
2. Revisar logs: `docker logs CONTAINER`
3. Verificar recursos disponibles
4. Revisar configuración docker-compose.yml

### Acceso denegado
1. Verificar permisos de archivos
2. Usar sudo desde host si es necesario
3. Verificar configuración de red

### Scripts no funcionan
1. Verificar permisos de ejecución
2. Verificar rutas en el script
3. Ejecutar desde directorio correcto

---

**Documento mantenido por:** AVCTrust  
**Última actualización:** 10 de julio de 2025  
**Ubicación:** `/home/avctrust/docker/avc_ssh_host/docs/`
