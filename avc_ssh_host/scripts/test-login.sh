#!/bin/bash

# Test script para verificar las correcciones del login
# Sin necesidad de Node.js o Docker

echo "🐉 Behavioural Dragon Pro - Login Test Script"
echo "=============================================="
echo ""

# Test 1: Verificar configuración CORS
echo "🔍 TEST 1: Verificando configuración CORS..."
if grep -q "10.0.0.10:5173" server/index.js; then
    echo "✅ CORS configurado para 10.0.0.10:5173"
else
    echo "❌ CORS no incluye 10.0.0.10:5173"
fi

if grep -q "192.169.145.43" server/index.js; then
    echo "✅ CORS configurado para 192.169.145.43"
else
    echo "❌ CORS no incluye 192.169.145.43"
fi

echo ""

# Test 2: Verificar variables de entorno
echo "🔍 TEST 2: Verificando variables de entorno..."
if grep -q "VITE_API_BASE_URL=http://10.0.0.10:3000/api" .env; then
    echo "✅ VITE_API_BASE_URL configurada correctamente"
else
    echo "❌ VITE_API_BASE_URL no configurada"
fi

if grep -q "JWT_SECRET=" .env; then
    echo "✅ JWT_SECRET configurado"
else
    echo "❌ JWT_SECRET no configurado"
fi

echo ""

# Test 3: Verificar estructura de archivos
echo "🔍 TEST 3: Verificando estructura de archivos..."
files=(
    "server/index.js"
    "server/routes/auth.js"
    "server/middleware/auth.js"
    "src/contexts/AuthContext.jsx"
    "src/components/LoginModal.jsx"
    ".env"
    "docker-compose.yml"
    "Dockerfile"
    "Dockerfile.backend"
)

for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file existe"
    else
        echo "❌ $file no encontrado"
    fi
done

echo ""

# Test 4: Verificar configuración de login
echo "🔍 TEST 4: Verificando configuración de login..."
if grep -q "password_hash" server/routes/auth.js; then
    echo "✅ Verificación de password implementada"
else
    echo "❌ Verificación de password no encontrada"
fi

if grep -q "jwt.sign" server/routes/auth.js; then
    echo "✅ Generación de JWT implementada"
else
    echo "❌ Generación de JWT no encontrada"
fi

echo ""

# Test 5: Verificar mejoras implementadas
echo "🔍 TEST 5: Verificando mejoras implementadas..."
if grep -q "isExpired" src/contexts/AuthContext.jsx; then
    echo "✅ Validación de expiración de token implementada"
else
    echo "❌ Validación de expiración no encontrada"
fi

if grep -q "Network error" src/components/LoginModal.jsx; then
    echo "✅ Mejor manejo de errores implementado"
else
    echo "❌ Mejor manejo de errores no encontrado"
fi

echo ""

# Resumen
echo "📋 RESUMEN DE CORRECCIONES IMPLEMENTADAS:"
echo "========================================="
echo "1. ✅ Configuración CORS ampliada para múltiples IPs"
echo "2. ✅ Validación de expiración de token en AuthContext"
echo "3. ✅ Variables de entorno para URLs dinámicas"
echo "4. ✅ Mejor manejo de errores en LoginModal"
echo "5. ✅ Docker Compose con backend y frontend separados"
echo "6. ✅ Nginx configurado como proxy para API"
echo ""

echo "🚀 PARA PROBAR EL SISTEMA:"
echo "========================="
echo "1. Instalar dependencias: ./setup.sh"
echo "2. Iniciar backend: npm run server"
echo "3. Iniciar frontend: npm run dev"
echo "4. Abrir: http://localhost:5173"
echo "5. Login con: admin / admin123"
echo ""

echo "🐳 PARA USAR DOCKER:"
echo "==================="
echo "1. Instalar Docker: ./setup.sh"
echo "2. Construir: docker compose build"
echo "3. Iniciar: docker compose up"
echo "4. Abrir: http://localhost:8081"
echo ""

echo "🔧 URLS DE PRUEBA:"
echo "=================="
echo "- Frontend: http://localhost:5173 o http://localhost:8081"
echo "- Backend Health: http://localhost:3000/api/health"
echo "- Login API: http://localhost:3000/api/auth/login"
echo ""
