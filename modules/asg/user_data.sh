#!/bin/bash
# user_data.sh

# Función para logging: Registra mensajes con fecha y hora en el log de user-data.
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a /var/log/user-data.log
}

log "Iniciando script de User Data para ${project_name}..."

# Redireccionar toda la salida estándar y de error al archivo de log.
exec > >(tee -a /var/log/user-data.log)
exec 2>&1

# Configurar variables de entorno básicas para el script.
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
export HOME="/root"

log "Esperando que el sistema esté completamente inicializado..."
sleep 30

# Detectar la distribución del sistema operativo (Amazon Linux, Ubuntu, Red Hat/CentOS).
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$NAME
  log "Sistema operativo detectado: $OS"
fi

# Actualizar el sistema e instalar dependencias según la distribución.
log "Actualizando el sistema..."
if [[ "$OS" == *"Amazon Linux"* ]]; then
  yum update -y
  yum install -y python3 python3-pip mysql git aws-cli jq wget curl

  # Instalar amazon-linux-extras si está disponible para EPEL.
  if command -v amazon-linux-extras &>/dev/null; then
    amazon-linux-extras install epel -y
    log "EPEL instalado via amazon-linux-extras"
  fi

  # Instalar stress (opcional, para pruebas de carga).
  yum install -y stress

elif [[ "$OS" == *"Ubuntu"* ]]; then
  apt-get update -y
  apt-get install -y python3 python3-pip mysql-client git awscli jq wget curl stress

elif [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"CentOS"* ]]; then
  yum update -y
  yum install -y python3 python3-pip mysql git aws-cli jq wget curl stress
else
  log "Distribución no reconocida, intentando con yum..."
  yum update -y
  yum install -y python3 python3-pip mysql git aws-cli jq wget curl stress
fi

# Verificar que las herramientas críticas estén instaladas correctamente.
log "Verificando instalaciones..."
for cmd in git python3 aws jq pip3; do
  if command -v $cmd &>/dev/null; then
    log "$cmd instalado correctamente: $(which $cmd)"
    case $cmd in
    git | python3 | aws | jq)
      $cmd --version 2>&1 | head -1 | while read line; do log "$line"; done
      ;;
    pip3)
      $cmd --version 2>&1 | head -1 | while read line; do log "$line"; done
      ;;
    esac
  else
    log "ERROR: $cmd no está instalado"
    exit 1
  fi
done

# Configurar AWS CLI con la región por defecto.
log "Configurando AWS CLI..."
aws configure set default.region ${aws_region}
aws configure set default.output json

# Verificar conectividad a GitHub para clonar el repositorio.
log "Verificando conectividad a GitHub..."
if curl -s --connect-timeout 10 https://github.com >/dev/null; then
  log "Conectividad a GitHub: OK"
else
  log "ERROR: No hay conectividad a GitHub"
  exit 1
fi

# Crear el directorio de destino para la aplicación Flask.
TARGET_DIR="/home/ec2-user/flask-app"
log "Creando directorio: $TARGET_DIR"
mkdir -p "$TARGET_DIR"

# Clonar el repositorio de GitHub con reintentos en caso de fallo.
log "Clonando repositorio de GitHub..."
REPO_URL="https://github.com/ehoyos89/FlaskApp.git"
MAX_RETRIES=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  log "Intento de clonación #$((RETRY_COUNT + 1))"

  if git clone "$REPO_URL" "$TARGET_DIR"; then
    log "Repositorio clonado exitosamente"
    break
  else
    log "Error en la clonación, intento #$((RETRY_COUNT + 1)) fallido"
    RETRY_COUNT=$((RETRY_COUNT + 1))

    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
      log "Esperando 10 segundos antes del siguiente intento..."
      sleep 10
      rm -rf "$TARGET_DIR"
      mkdir -p "$TARGET_DIR"
    else
      log "ERROR: Falló la clonación después de $MAX_RETRIES intentos"
      exit 1
    fi
  fi
done

# Cambiar la propiedad del directorio de la aplicación al usuario ec2-user.
log "Cambiando ownership del directorio de la aplicación..."
chown -R ec2-user:ec2-user /home/ec2-user/flask-app

# Navegar al directorio de la aplicación.
log "Navegando al directorio de la aplicación..."
cd "$TARGET_DIR"

# Instalar dependencias de Python desde requirements.txt.
log "Instalando dependencias de Python..."
if [ -f "requirements.txt" ]; then
  log "Archivo requirements.txt encontrado, instalando dependencias..."
  python3 -m pip install --upgrade pip
  pip3 install -r requirements.txt
  log "Dependencias de Python instaladas desde requirements.txt"
else
  log "Warning: requirements.txt no encontrado"
fi

# Instalar Gunicorn, el servidor WSGI para la aplicación Flask.
log "Instalando Gunicorn..."
pip3 install gunicorn
if command -v gunicorn &>/dev/null; then
  log "Gunicorn instalado correctamente: $(which gunicorn)"
  gunicorn --version | while read line; do log "$line"; done
else
  log "ERROR: Gunicorn no se instaló correctamente"
  exit 1
fi

# Obtener secretos de AWS Secrets Manager.
log "Obteniendo secretos de AWS Secrets Manager..."

# Función para obtener secretos con reintentos.
# Redirige los logs a stderr para que no se mezclen con el valor del secreto.
get_secret() {
  local secret_arn=$1
  local key=$2
  local max_retries=3
  local retry_count=0

  while [ $retry_count -lt $max_retries ]; do
    # Escribir logs a stderr para evitar que se mezclen con el resultado
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Obteniendo secreto $key, intento #$((retry_count + 1))" >&2

    local secret_value=$(aws secretsmanager get-secret-value --secret-id "$secret_arn" --query SecretString --output text 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$secret_value" ]; then
      local result=$(echo "$secret_value" | jq -r ".$key" 2>/dev/null)
      if [ $? -eq 0 ] && [ "$result" != "null" ] && [ -n "$result" ]; then
        # Solo el resultado va a stdout
        echo "$result"
        return 0
      fi
    fi

    retry_count=$((retry_count + 1))
    if [ $retry_count -lt $max_retries ]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') - Error obteniendo secreto $key, reintentando en 5 segundos..." >&2
      sleep 5
    fi
  done

  echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: No se pudo obtener el secreto $key después de $max_retries intentos" >&2
  return 1
}

# Obtener secretos de la base de datos y de Flask.
# Captura solo el valor del secreto, no los logs de la función get_secret.
log "Obteniendo secreto de username de la base de datos..."
DB_USERNAME=$(get_secret "${db_username_secret_arn}" "username")
if [ $? -ne 0 ]; then
  log "ERROR: No se pudo obtener el username de la base de datos"
  exit 1
fi
log "Username de BD obtenido exitosamente"

log "Obteniendo secreto de password de la base de datos..."
DB_PASSWORD=$(get_secret "${db_password_secret_arn}" "password")
if [ $? -ne 0 ]; then
  log "ERROR: No se pudo obtener el password de la base de datos"
  exit 1
fi
log "Password de BD obtenido exitosamente"

log "Obteniendo secreto de Flask secret key..."
FLASK_SECRET=$(get_secret "${flask_secret_key_secret_arn}" "secret_key")
if [ $? -ne 0 ]; then
  log "ERROR: No se pudo obtener el Flask secret key"
  exit 1
fi
log "Flask secret key obtenido exitosamente"

log "Todos los secretos obtenidos exitosamente"

# Crear directorio para variables de entorno del servicio systemd.
log "Configurando servicio systemd..."
mkdir -p /etc/systemd/system/flask_app.service.d

# Configurar variables de entorno para la aplicación Flask.
# Estas variables serán utilizadas por el servicio systemd.
log "Creando archivo de configuración de entorno..."
db_host_only=$(echo "$db_endpoint" | cut -d':' -f1)
cat >/etc/systemd/system/flask_app.service.d/environment.conf <<EOF
[Service]
Environment="PHOTOS_BUCKET=${photos_bucket}"
Environment="DATABASE_HOST=${db_host_only}"
Environment="DATABASE_USER=$DB_USERNAME"
Environment="DATABASE_PASSWORD=$DB_PASSWORD"
Environment="DATABASE_PORT=3306"
Environment="DATABASE_DB_NAME=${db_name}"
Environment="FLASK_SECRET=$FLASK_SECRET"
EOF

# Verificar el contenido del archivo de configuración generado.
log "Verificando archivo de configuración generado:"
cat /etc/systemd/system/flask_app.service.d/environment.conf | while read line; do log "CONFIG: $line"; done

# También crear un archivo de perfil para depuración (opcional).
log "Creando archivo de perfil de entorno..."
cat >/etc/profile.d/flask_app_env.sh <<EOF
export PHOTOS_BUCKET="${photos_bucket}"
export DATABASE_HOST="${db_host_only}"
export DATABASE_USER="$DB_USERNAME"
export DATABASE_PASSWORD="$DB_PASSWORD"
export DATABASE_PORT="3306"
export DATABASE_DB_NAME="${db_name}"
export FLASK_SECRET="$FLASK_SECRET"
EOF

# Esperar a que la base de datos esté disponible antes de continuar.
log "Esperando que la base de datos esté disponible en ${db_host_only}..."
MAX_DB_RETRIES=15
DB_RETRY_COUNT=0
DB_READY=false

while [ $DB_RETRY_COUNT -lt $MAX_DB_RETRIES ]; do
  log "Intento de conexión a la BD #$((DB_RETRY_COUNT + 1))/$MAX_DB_RETRIES..."
  if mysqladmin ping -h "${db_host_only}" --user="$DB_USERNAME" --password="$DB_PASSWORD" --silent --connect-timeout=10; then
    log "✓ Conexión a la base de datos exitosa."
    DB_READY=true
    break
  else
    log "✗ La base de datos no está lista. Reintentando en 20 segundos..."
    DB_RETRY_COUNT=$((DB_RETRY_COUNT + 1))
    sleep 20
  fi
done

# Si la base de datos está lista, crear las tablas.
if [ "$DB_READY" = true ]; then
  log "Iniciando la creación de tablas en la base de datos..."
  if cat database_create_tables.sql | mysql -h "${db_host_only}" -u "$DB_USERNAME" -p"$DB_PASSWORD" "${db_name}"; then
    log "✓ Tablas creadas exitosamente."
  else
    log "✗ ERROR: Falló la creación de tablas."
    exit 1
  fi
else
  log "✗ ERROR: No se pudo conectar a la base de datos después de $MAX_DB_RETRIES intentos."
  exit 1
fi

# Crear un servicio systemd para Gunicorn que sirva la aplicación Flask.
log "Creando servicio systemd para Flask..."
cat >/etc/systemd/system/flask_app.service <<EOF
[Unit]
Description=Gunicorn instance to serve flask_app
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/flask-app
ExecStart=/usr/local/bin/gunicorn --workers 4 --bind 0.0.0.0:5000 application:application
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Verificar que el archivo principal de la aplicación existe.
if [ ! -f "/home/ec2-user/flask-app/application.py" ]; then
  log "Warning: application.py no encontrado en el directorio de la aplicación"
  ls -la /home/ec2-user/flask-app/ | while read line; do log "$line"; done
fi

# Recargar systemd y habilitar/iniciar el servicio Flask.
log "Recargando systemd daemon..."
systemctl daemon-reload

log "Habilitando servicio flask_app..."
systemctl enable flask_app

# Esperar un momento antes de iniciar el servicio.
log "Esperando antes de iniciar el servicio..."
sleep 5

log "Iniciando servicio flask_app..."
systemctl start flask_app

# Verificar el estado del servicio Flask.
log "Verificando estado del servicio..."
systemctl status flask_app --no-pager

# Verificar que el servicio está realmente funcionando.
sleep 10
if systemctl is-active --quiet flask_app; then
  log "✓ Servicio flask_app está ejecutándose correctamente"
else
  log "✗ ERROR: Servicio flask_app no está ejecutándose"
  log "Logs del servicio:"
  journalctl -u flask_app --no-pager -l | tail -20 | while read line; do log "$line"; done
fi

# Verificar que el puerto 5000 está abierto y escuchando.
if netstat -tuln | grep :5000 >/dev/null; then
  log "✓ Puerto 5000 está abierto y escuchando"
else
  log "✗ Warning: Puerto 5000 no parece estar abierto"
fi

log "Script de User Data completado"

# Log del estado final del servicio.
log "=== Estado final del servicio ==="
systemctl status flask_app --no-pager | while read line; do log "$line"; done

# Marcar que el user data se completó para evitar ejecuciones repetidas.
touch /home/ec2-user/user-data-completed
chown ec2-user:ec2-user /home/ec2-user/user-data-completed

log "User Data script finalizado exitosamente: $(date)"