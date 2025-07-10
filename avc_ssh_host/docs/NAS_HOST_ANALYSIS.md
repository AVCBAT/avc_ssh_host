# 🏠 ANÁLISIS DEL NAS HOST SYNOLOGY
*Fecha: 10 de julio 2025*

## 📋 RESUMEN EJECUTIVO

✅ **Conexión SSH al host exitosa** (puerto 2222)  
❌ **Docker no accesible desde SSH** (permisos/configuración)  
🔍 **Puertos críticos identificados**  
⚠️ **Proyecto no visible en host** (posiblemente dentro del contenedor)  

## 🖥️ INFORMACIÓN DEL SISTEMA HOST

**Hostname:** AVCServer  
**Sistema:** Linux AVCServer 4.4.302+ Synology DSM  
**Arquitectura:** x86_64 GNU/Linux synology_apollolake_718+  
**IP Principal:** 10.0.0.10  

### 💾 Recursos del Sistema
- **CPU Load:** 0.75 1.22 5.42 (3/1236 procesos)
- **Memoria:** 3.0Gi/7.6Gi utilizados
- **Disco:** 1.5G/7.9G (20% usado)

### 🌐 Configuración de Red
```
eth0/eth1: Interfaces físicas en modo bond
ovs_bond0: 10.0.0.10/24 (IP principal)
tun0: 10.0.90.1 (VPN tunnel)
br-sonarqube: 172.31.0.1/24 (Red Docker SonarQube)
```

## 🔍 PUERTOS IDENTIFICADOS EN EL HOST

### ✅ Servicios Synology Activos
- **Puerto 80/443:** DSM Web Interface
- **Puerto 2222:** SSH (acceso actual)
- **Puerto 3306:** MariaDB/MySQL
- **Puerto 5432:** PostgreSQL
- **Puerto 5100/5357:** Servicios Synology
- **Puerto 8377/8500:** Aplicaciones web

### ⭕ Puertos Libres (Importantes para el proyecto)
- **Puerto 3000:** Node.js/React (libre)
- **Puerto 5173:** Vite Dev Server (libre)
- **Puerto 8081:** Puerto alternativo aplicaciones (libre)

### 🔧 Otros Servicios
- **Puerto 21:** FTP
- **Puerto 139/445:** SMB/CIFS
- **Puerto 53:** DNS (múltiples instancias)
- **Puerto 161:** SNMP

## 🐳 ESTADO DE DOCKER

❌ **Problema identificado:** Docker no es accesible desde la sesión SSH
- Posibles causas:
  - Usuario sin permisos para acceder a Docker
  - Docker ejecutándose en un contexto diferente
  - Servicios Docker manejados por DSM

## 🐉 ANÁLISIS DEL PROYECTO BEHAVIOURAL DRAGON PRO

### 🎯 Hallazgos Críticos
1. **No se encontraron contenedores** con nombre 'behavioural' en el host
2. **Puertos 3000, 5173, 8081 están libres** en el host
3. **El proyecto está ejecutándose dentro del contenedor** pero sin mapeo de puertos al host

### 🔧 Diagnóstico de Conectividad
```bash
# Desde el contenedor (funcionando):
Frontend: http://localhost:5173
Backend: http://localhost:3000

# Desde el host NAS (no accesible):
http://10.0.0.10:3000 -> Sin respuesta
http://10.0.0.10:5173 -> Sin respuesta
```

## 🛠️ SOLUCIONES RECOMENDADAS

### 1. 🎯 Verificar Mapeo de Puertos en Docker Compose

El `docker-compose.yml` debe incluir mapeo de puertos:

```yaml
services:
  frontend:
    ports:
      - "5173:5173"  # Mapear puerto del host al contenedor
  
  backend:
    ports:
      - "3000:3000"  # Mapear puerto del host al contenedor
```

### 2. 🔄 Reiniciar Servicios con Mapeo Correcto

```bash
# Desde dentro del contenedor:
docker-compose down
docker-compose up -d
```

### 3. 🌐 Verificar Acceso Externo

Una vez configurado el mapeo, verificar acceso desde:
- **Red local:** http://10.0.0.10:5173
- **Desde el host:** http://localhost:5173

## 📊 MATRIZ DE PUERTOS

| Puerto | Estado Host | Uso Actual | Recomendación |
|--------|-------------|------------|---------------|
| 3000   | 🟢 Libre    | Backend Node.js | ✅ Mapear para backend |
| 5173   | 🟢 Libre    | Frontend Vite | ✅ Mapear para frontend |
| 8081   | 🟢 Libre    | Alternativo | 🔄 Backup option |
| 3306   | 🔴 Ocupado  | MariaDB | ✅ Ya disponible |

## 🎯 PRÓXIMOS PASOS

1. **Inmediato:**
   - [ ] Verificar y actualizar `docker-compose.yml` con mapeo de puertos
   - [ ] Reiniciar contenedor con nueva configuración
   - [ ] Probar acceso desde http://10.0.0.10:5173

2. **Verificación:**
   - [ ] Acceso local desde el NAS
   - [ ] Acceso desde red local (otras PCs)
   - [ ] Funcionalidad completa de login/autenticación

3. **Opcional:**
   - [ ] Configurar proxy inverso en DSM si se requiere
   - [ ] Configurar SSL/HTTPS para acceso externo seguro

## 🚨 NOTAS IMPORTANTES

- **El proyecto está funcionando correctamente dentro del contenedor**
- **El problema es de visibilidad/mapeo de puertos al host**
- **MariaDB está disponible en el host (puerto 3306)**
- **Todos los puertos necesarios están libres en el host**

---
*Análisis realizado el 10 de julio 2025 - Estado: Pendiente mapeo de puertos*
