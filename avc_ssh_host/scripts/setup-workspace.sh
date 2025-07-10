#!/bin/bash

# =================================================================
# SCRIPT DE CONFIGURACIÓN INICIAL PARA WORKSPACE CENTRALIZADO
# Prepara el entorno para usar el workspace master de Docker NAS
# =================================================================

echo "🚀 CONFIGURACIÓN INICIAL - WORKSPACE CENTRALIZADO DOCKER NAS"
echo "============================================================"
echo "Fecha: $(date)"
echo ""

# Configuraciones
WORKSPACE_DIR="/home/avctrust/docker/avc_ssh_host"
WORKSPACE_FILE="$WORKSPACE_DIR/docker-nas-master.code-workspace"
SCRIPTS_DIR="$WORKSPACE_DIR/scripts"
DOCS_DIR="$WORKSPACE_DIR/docs"

echo "📁 VERIFICANDO ESTRUCTURA DEL WORKSPACE..."
echo "==========================================="
echo "Directorio principal: $WORKSPACE_DIR"
echo "Archivo workspace: $WORKSPACE_FILE"
echo "Scripts: $SCRIPTS_DIR"
echo "Documentación: $DOCS_DIR"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "❌ Error: Directorio del workspace no encontrado: $WORKSPACE_DIR"
    exit 1
fi

cd "$WORKSPACE_DIR"

# Verificar archivo de workspace
if [ ! -f "$WORKSPACE_FILE" ]; then
    echo "❌ Error: Archivo de workspace no encontrado: $WORKSPACE_FILE"
    exit 1
fi

echo "✅ Estructura básica verificada"
echo ""

# Verificar y configurar permisos de scripts
echo "🔧 CONFIGURANDO PERMISOS DE SCRIPTS..."
echo "======================================"

if [ -d "$SCRIPTS_DIR" ]; then
    echo "📝 Haciendo scripts ejecutables..."
    chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null
    
    script_count=$(find "$SCRIPTS_DIR" -name "*.sh" | wc -l)
    echo "✅ $script_count scripts configurados como ejecutables"
    
    echo ""
    echo "📋 Scripts disponibles:"
    find "$SCRIPTS_DIR" -name "*.sh" -executable | sort | while read script; do
        script_name=$(basename "$script")
        echo "   • $script_name"
    done
else
    echo "⚠️  Directorio de scripts no encontrado: $SCRIPTS_DIR"
fi

echo ""

# Verificar proyectos Docker accesibles
echo "📂 VERIFICANDO ACCESO A PROYECTOS DOCKER..."
echo "==========================================="

DOCKER_BASE="/home/avctrust/docker"
if [ -d "$DOCKER_BASE" ]; then
    echo "📁 Directorio base: $DOCKER_BASE"
    
    project_count=$(find "$DOCKER_BASE" -maxdepth 1 -type d | wc -l)
    project_count=$((project_count - 1))  # Excluir directorio padre
    
    echo "📊 Total de proyectos encontrados: $project_count"
    echo ""
    
    echo "🔍 Proyectos principales:"
    main_projects=(
        "avc_ssh_host"
        "behavioural_dragon_pro"
        "avc_ai_terminal"
        "avc_api"
        "avc_remote_hub"
        "avc_code_server"
        "avc_database"
        "deepseek"
        "bind9"
        "avc_wireguard"
    )
    
    for project in "${main_projects[@]}"; do
        if [ -d "$DOCKER_BASE/$project" ]; then
            echo "   ✅ $project"
        else
            echo "   ❌ $project (no encontrado)"
        fi
    done
else
    echo "❌ Error: Directorio base de Docker no accesible: $DOCKER_BASE"
fi

echo ""

# Verificar herramientas necesarias
echo "🛠️  VERIFICANDO HERRAMIENTAS NECESARIAS..."
echo "========================================"

tools=("docker" "docker-compose" "node" "npm" "python3" "git" "ssh" "netstat" "lsof")
echo "🔍 Verificando disponibilidad de herramientas..."

for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$(command -v "$tool" >/dev/null 2>&1 && $tool --version 2>/dev/null | head -1 | cut -d' ' -f1-3 || echo "disponible")
        echo "   ✅ $tool ($version)"
    else
        echo "   ⚠️  $tool (no disponible desde contenedor)"
    fi
done

echo ""

# Probar script principal
echo "🧪 PROBANDO FUNCIONALIDAD PRINCIPAL..."
echo "===================================="

if [ -f "$SCRIPTS_DIR/docker-environment-analysis.sh" ]; then
    echo "🔍 Ejecutando análisis rápido del entorno..."
    echo ""
    
    # Ejecutar análisis con timeout para evitar bloqueos
    timeout 30s "$SCRIPTS_DIR/docker-environment-analysis.sh" | head -20
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Script de análisis funcionando correctamente"
    elif [ $? -eq 124 ]; then
        echo ""
        echo "⚠️  Script ejecutándose (interrumpido para configuración rápida)"
    else
        echo ""
        echo "❌ Error al ejecutar script de análisis"
    fi
else
    echo "❌ Script principal no encontrado"
fi

echo ""

# Generar configuración de VS Code específica
echo "⚙️  GENERANDO CONFIGURACIÓN DE VS CODE..."
echo "======================================="

VSCODE_DIR="$WORKSPACE_DIR/.vscode"
mkdir -p "$VSCODE_DIR"

# Configuración de tasks.json específica para el workspace
cat > "$VSCODE_DIR/tasks.json" << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "🔍 Análisis Maestro Completo",
            "type": "shell",
            "command": "./docker-master-analysis.sh",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "options": {
                "cwd": "${workspaceFolder}/scripts"
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "new",
                "showReuseMessage": false
            },
            "problemMatcher": []
        },
        {
            "label": "🌐 Análisis de Puertos",
            "type": "shell",
            "command": "./docker-ports-analysis.sh",
            "group": "build",
            "options": {
                "cwd": "${workspaceFolder}/scripts"
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "new"
            },
            "problemMatcher": []
        },
        {
            "label": "🏗️ Análisis del Entorno",
            "type": "shell",
            "command": "./docker-environment-analysis.sh",
            "group": "build",
            "options": {
                "cwd": "${workspaceFolder}/scripts"
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "new"
            },
            "problemMatcher": []
        },
        {
            "label": "🚀 SSH al NAS Host",
            "type": "shell",
            "command": "ssh -p 2222 avctrust@10.0.0.10",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": true,
                "panel": "new"
            },
            "problemMatcher": []
        }
    ]
}
EOF

echo "✅ Configuración de tareas creada: $VSCODE_DIR/tasks.json"

# Configuración de settings específicos del workspace
cat > "$VSCODE_DIR/settings.json" << 'EOF'
{
    "terminal.integrated.cwd": "${workspaceFolder}",
    "files.watcherExclude": {
        "**/node_modules/**": true,
        "**/.git/objects/**": true,
        "**/venv/**": true,
        "**/__pycache__/**": true,
        "**/logs/**": true,
        "**/tmp/**": true,
        "**/analysis/**": true
    },
    "search.exclude": {
        "**/node_modules": true,
        "**/venv": true,
        "**/__pycache__": true,
        "**/logs": true,
        "**/tmp": true
    },
    "files.associations": {
        "*.yml": "yaml",
        "*.yaml": "yaml",
        "docker-compose*.yml": "yaml",
        "Dockerfile*": "dockerfile",
        "*.sh": "shellscript"
    },
    "explorer.sortOrder": "foldersNestsFiles",
    "git.detectSubmodules": false,
    "terminal.integrated.defaultProfile.linux": "bash"
}
EOF

echo "✅ Configuración de workspace creada: $VSCODE_DIR/settings.json"

echo ""

# Crear archivo de inicio rápido
echo "📋 CREANDO GUÍA DE INICIO RÁPIDO..."
echo "=================================="

cat > "$WORKSPACE_DIR/QUICK_START.md" << 'EOF'
# INICIO RÁPIDO - WORKSPACE CENTRALIZADO

## 🚀 Comandos Esenciales

### Análisis del Entorno
```bash
# Análisis completo
cd scripts && ./docker-master-analysis.sh

# Solo puertos
cd scripts && ./docker-ports-analysis.sh

# Solo entorno
cd scripts && ./docker-environment-analysis.sh
```

### Acceso al Host NAS
```bash
ssh -p 2222 avctrust@10.0.0.10
```

### Navegación Rápida
- **Ctrl+Shift+P** → Tasks → Ejecutar tareas predefinidas
- **Ctrl+Shift+E** → Explorer para navegar proyectos
- **Ctrl+`** → Terminal rápido

## 📁 Estructura
- `scripts/` → Herramientas de análisis
- `docs/` → Documentación completa
- `analysis/` → Reportes generados

## 🔧 Proyectos Principales
- behavioural_dragon_pro
- avc_ai_terminal
- avc_api
- avc_remote_hub
- Y 37 más...
EOF

echo "✅ Guía de inicio rápido creada: $WORKSPACE_DIR/QUICK_START.md"

echo ""

# Resumen final
echo "🎯 CONFIGURACIÓN COMPLETADA"
echo "============================"
echo ""
echo "✅ LISTO PARA USAR EL WORKSPACE CENTRALIZADO"
echo ""
echo "📋 Próximos pasos:"
echo "1. Abrir VS Code con el workspace:"
echo "   code $WORKSPACE_FILE"
echo ""
echo "2. O desde VS Code:"
echo "   File → Open Workspace from File → docker-nas-master.code-workspace"
echo ""
echo "3. Ejecutar primera tarea (Ctrl+Shift+P → Tasks):"
echo "   🔍 Análisis Maestro Completo"
echo ""
echo "📁 Archivos importantes creados:"
echo "   • $WORKSPACE_FILE"
echo "   • $VSCODE_DIR/tasks.json"
echo "   • $VSCODE_DIR/settings.json"
echo "   • $WORKSPACE_DIR/QUICK_START.md"
echo ""
echo "🎯 BENEFICIOS DEL WORKSPACE CENTRALIZADO:"
echo "   ✅ Acceso a todos los 41 proyectos Docker"
echo "   ✅ Scripts de análisis centralizados"
echo "   ✅ Documentación unificada"
echo "   ✅ Tareas predefinidas listas"
echo "   ✅ Configuración optimizada"
echo ""
echo "🚀 ¡Tu entorno está listo para máxima productividad!"
echo "=============================================="
