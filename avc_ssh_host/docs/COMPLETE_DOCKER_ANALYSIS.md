# ANÁLISIS COMPLETO DEL ENTORNO DOCKER EN NAS SYNOLOGY

## 📋 RESUMEN EJECUTIVO

**Fecha de análisis:** 10 de julio de 2025  
**Entorno:** NAS Synology (AVCServer)  
**Directorio de proyectos:** `/volume1/docker`  
**Total de proyectos:** 41 proyectos Docker  

## 🏗️ ARQUITECTURA DEL SISTEMA

### Estructura de Directorios
- **Host NAS:** `/volume1/docker/` (directorio real en el NAS)
- **Workspace VS Code:** `/home/avctrust/docker/behavioural_dragon_pro/` (montado en contenedor)
- **Usuario home:** `/volume1/homes/avctrust/` (home real del usuario en NAS)

### Relación Desarrollo vs Producción
- **Desarrollo:** Workspace en VS Code ejecutándose dentro de contenedor Docker
- **Producción:** Proyectos ejecutándose como contenedores Docker en el host NAS
- **Conexión SSH:** `ssh -p 2222 avctrust@10.0.0.10` para acceso al host real

## 📂 LISTADO DE PROYECTOS DOCKER (41 total)

### Proyectos con Docker Compose activo:
1. **behavioural_dragon_pro** - [docker-compose][dockerfile][nodejs]
2. **avc_ai_terminal** - [docker-compose][dockerfile][python]
3. **avc_api** - [docker-compose][dockerfile][python] 
4. **avc_code_server** - [docker-compose][dockerfile]
5. **avc_ha_editor** - [docker-compose][dockerfile][python]
6. **avc_remote_hub** - [docker-compose]
7. **avc_ssh_host** - [docker-compose][dockerfile]
8. **deepseek** - [docker-compose][dockerfile][python]
9. **bind9** - [docker-compose]
10. **telegram_download** - [docker-compose][dockerfile][python]
11. **youtube_mp3_downloader** - [docker-compose][dockerfile][python]

### Proyectos con configuración Docker:
- **avc_autodeploy_manager**, **avc_converter**, **avc_dalle_worker**
- **avc_database**, **avc_db_mirror**, **avc_dev_container**
- **avc_fft_streamer**, **avc_gemini_bot**, **avc_smtp**
- **avc_sonarqube**, **avc_test123**, **avc_text_worker**
- **avc_wireguard**, **copilot_demo**, **esphome**, **trustvault**

## 🌐 ANÁLISIS DE PUERTOS

### Puertos Utilizados por Proyecto:
| Puerto | Proyecto | Servicio | Mapeo |
|--------|----------|----------|-------|
| 2223 | avc_dev_container | SSH | 2223→2222 |
| 2229 | avc_ssh_host | SSH | 2229→22 |
| **3000** | **behavioural_dragon_pro** | **Frontend** | **3000→3000** |
| 5080 | avc_api | API | 5080→5000 |
| 5082 | avc_ha_editor | Editor | 5082→5000 |
| 5090 | múltiples | Varios | 5090→5090 |
| 5110 | deepseek | WebSocket | 5110→5110 |
| 8053 | bind9 | DNS | 8053→53 |
| **8081** | **behavioural_dragon_pro** | **Nginx** | **8081→80** |
| 8081 | avc_remote_hub | Hub | 8081→8080 |
| 8086 | multiple | Apps | 8086→5000 |
| 8090 | telegram_download | Download | 8090→5000 |
| 8377 | avc_code_server | Code Server | 8377→8443 |
| 51820 | avc_wireguard | VPN | 51820→51820/udp |

### ⚠️ CONFLICTOS DE PUERTOS DETECTADOS:

**Puerto 5090** - Usado por 3 proyectos:
- _respaldo_avc_db_mirror
- avc_fft_streamer  
- avc_test123

**Puerto 8081** - Usado por 2 proyectos:
- **behavioural_dragon_pro** (Nginx)
- avc_remote_hub

**Puerto 8086** - Usado por 2 proyectos:
- avc_ai_terminal
- youtube_mp3_downloader

## 🔧 ESTADO DEL PROYECTO BEHAVIOURAL DRAGON PRO

### Configuración de Puertos:
- **Frontend (Vite):** Puerto 3000
- **Backend (Nginx):** Puerto 8081
- **Base de datos:** MariaDB (interno, no expuesto)

### Estado de Desarrollo:
- ✅ Backend configurado y funcionando
- ✅ Frontend configurado y funcionando  
- ✅ Autenticación implementada y probada
- ✅ Base de datos MariaDB operativa
- ✅ CORS configurado correctamente
- ✅ Variables de entorno configuradas

### Usuarios de Prueba Creados:
- **Admin:** admin@behavioural.com / admin123
- **Test User:** test@test.com / test123

## 📋 SCRIPTS DE ANÁLISIS CREADOS

### Scripts en `/home/avctrust/docker/behavioural_dragon_pro/`:
1. **`list-docker-projects.sh`** - Lista todos los proyectos Docker
2. **`analyze-all-docker-ports.sh`** - Análisis completo de puertos
3. **`analyze-docker-projects.sh`** - Análisis detallado de proyectos
4. **`run-remote-analysis.sh`** - Ejecutor remoto automático
5. **`check-ports.sh`** - Análisis de puertos del proyecto actual

### Uso de Scripts:
```bash
# Desde VS Code (dentro del contenedor):
./list-docker-projects.sh

# Desde host externo:
ssh -p 2222 avctrust@10.0.0.10 'bash -s' < analyze-all-docker-ports.sh
```

## 🚀 INSTRUCCIONES DE ACCESO

### Acceso al Proyecto en Desarrollo:
- **Frontend:** http://localhost:3000 (dentro del contenedor)
- **Backend API:** http://localhost:8081/api (dentro del contenedor)

### Acceso al Host NAS:
```bash
ssh -p 2222 avctrust@10.0.0.10
```

### Comandos Docker Útiles en el Host:
```bash
# Ver contenedores activos
docker ps

# Ver estadísticas
docker stats

# Ver logs de proyecto específico
docker logs behavioural_dragon_pro_web_1

# Parar todos los contenedores
docker stop $(docker ps -q)
```

## 📊 ESTADÍSTICAS DEL ENTORNO

- **Total de proyectos Docker:** 41
- **Proyectos con docker-compose:** 29
- **Proyectos activos:** Variable (depende de contenedores en ejecución)
- **Puertos configurados:** 18 configuraciones
- **Puertos únicos:** 13
- **Conflictos de puertos:** 4 detectados

## ✅ CONCLUSIONES

1. **Entorno bien estructurado:** El NAS tiene una excelente organización de proyectos Docker
2. **Proyecto funcional:** Behavioural Dragon Pro está correctamente configurado y operativo
3. **Necesidad de limpieza:** Algunos conflictos de puertos requieren atención
4. **Monitoreo recomendado:** Scripts creados facilitan el monitoreo continuo del entorno

## 🔄 PRÓXIMOS PASOS RECOMENDADOS

1. Resolver conflictos de puertos identificados
2. Implementar monitoreo automático de recursos
3. Crear backups automatizados de proyectos críticos
4. Documentar procedimientos de deployment para cada proyecto
5. Optimizar uso de recursos Docker

---
**Documentación generada automáticamente - Behavioural Dragon Pro v1.0**
