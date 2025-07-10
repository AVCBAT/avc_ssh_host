# 🐉 Behavioural Dragon Pro - Testing Instructions

## ✅ Correcciones Implementadas para el Login

### Problemas Identificados y Solucionados:

1. **CORS Configuration** - ✅ SOLUCIONADO
   - **Problema**: Solo permitía localhost, bloqueando requests desde otras IPs
   - **Solución**: Ampliada configuración para incluir todas las IPs necesarias:
     - `http://localhost:5173`, `http://localhost:4173`
     - `http://10.0.0.10:5173`, `http://10.0.0.10:4173`, `http://10.0.0.10:3000`
     - `http://192.169.145.43:5173`, `http://192.169.145.43:4173`

2. **Token Validation** - ✅ SOLUCIONADO
   - **Problema**: No verificaba expiración de tokens al cargar la app
   - **Solución**: Implementada validación de expiración en `AuthContext.jsx`

3. **Error Handling** - ✅ SOLUCIONADO
   - **Problema**: Pobre feedback al usuario en caso de errores de red
   - **Solución**: Mejorado manejo de errores en `LoginModal.jsx` con mensajes específicos

4. **Environment Variables** - ✅ SOLUCIONADO
   - **Problema**: URLs hardcodeadas sin flexibilidad
   - **Solución**: Uso de variables de entorno para URLs dinámicas

5. **Docker Configuration** - ✅ SOLUCIONADO
   - **Problema**: Solo frontend, sin backend
   - **Solución**: Docker Compose completo con backend y frontend separados

## 🚀 Instrucciones para Probar

### Opción 1: Desarrollo Local
```bash
# 1. Instalar dependencias
./setup.sh

# 2. En terminal 1 - Iniciar backend
npm run server

# 3. En terminal 2 - Iniciar frontend  
npm run dev

# 4. Abrir navegador
http://localhost:5173
```

### Opción 2: Docker (Recomendado)
```bash
# 1. Instalar Docker (si no está instalado)
./setup.sh

# 2. Construir contenedores
docker compose build

# 3. Iniciar servicios
docker compose up

# 4. Abrir navegador
http://localhost:8081
```

### Opción 3: Desarrollo Completo
```bash
# Ejecutar backend y frontend simultáneamente
npm run dev:full
```

## 🔍 Puntos de Verificación

### 1. Health Check del Backend
```bash
curl http://localhost:3000/api/health
```
**Respuesta esperada:**
```json
{
  "status": "healthy",
  "timestamp": "2025-07-10T...",
  "database": "connected",
  "version": "1.0.0"
}
```

### 2. Test de Login API
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```
**Respuesta esperada:**
```json
{
  "token": "eyJ...",
  "user": {
    "id": 1,
    "username": "admin",
    "role": "admin",
    "name": "Admin User"
  }
}
```

### 3. Test de CORS
- Abrir DevTools en el navegador
- Verificar que no hay errores de CORS en la consola
- Las peticiones AJAX deben completarse sin errores

## 🎯 Credenciales de Prueba

**Administrador:**
- Username: `admin`
- Password: `admin123`

## 🌐 URLs de Acceso

- **Frontend (Desarrollo)**: http://localhost:5173
- **Frontend (Docker)**: http://localhost:8081  
- **Backend API**: http://localhost:3000/api
- **Health Check**: http://localhost:3000/api/health
- **Login Endpoint**: http://localhost:3000/api/auth/login

## 🔧 Configuración de Red

El sistema está configurado para funcionar en las siguientes IPs:
- `localhost` (127.0.0.1)
- `10.0.0.10` (IP del servidor)
- `192.169.145.43` (IP de la base de datos)

## 📋 Checklist de Funcionamiento

- [ ] ✅ Backend se inicia sin errores
- [ ] ✅ Frontend se carga correctamente
- [ ] ✅ Conexión a base de datos establecida
- [ ] ✅ Health check responde OK
- [ ] ✅ Login modal se abre
- [ ] ✅ Credenciales demo se cargan
- [ ] ✅ Login exitoso con admin/admin123
- [ ] ✅ Token se almacena en localStorage
- [ ] ✅ Dashboard se muestra después del login
- [ ] ✅ No hay errores de CORS en consola

## 🐛 Troubleshooting

### Si el backend no se conecta a la base de datos:
1. Verificar que MariaDB esté corriendo en `192.169.145.43:3306`
2. Verificar credenciales en `.env`
3. Verificar conectividad de red

### Si hay errores de CORS:
1. Verificar que el frontend esté accediendo desde una URL permitida
2. Revisar configuración CORS en `server/index.js`
3. Verificar que el backend esté corriendo

### Si el login falla:
1. Verificar que el usuario admin existe en la base de datos
2. Ejecutar `node create-admin.js` para crear el usuario
3. Verificar JWT_SECRET en `.env`

## 🎉 Resultado Esperado

Después de implementar todas las correcciones, el sistema de login debería:
1. Cargar sin errores de CORS
2. Permitir login con credenciales demo
3. Generar y almacenar token JWT
4. Redirigir al dashboard después del login
5. Mantener la sesión entre recargas de página
6. Manejar errores de forma elegante
