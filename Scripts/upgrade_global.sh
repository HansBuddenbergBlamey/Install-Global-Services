#################################################################
# Nombre de Proceso :	 upgrade_global							#
# Descripcion       :	 Migra desde el VPS hacia AWS,			#
#			 			 instala y actualiza los ambientes		#
#			 			 de Redmine y SugarCRM.					#
# Fecha de Creacion :	 04 de Mayo de 2016						#
# Fecha de Modificación: 11 de Mayo de 2016						#
#################################################################

#! /bin/bash

while getopts ':o:' opt ; do
	case $opt in
	# -- Opciones
	o)	OPCION=$OPTARG;;
	# -- Error
	\?) print -u2 Que es -${OPTARG}?
		((error=error+1))
		;;
	:)
		print -u2 $OPTARG nesecita argumento.
		((error=error+1))
		;;
	esac
done

# -- PreRequisitos
REQ1='realpath'
# # PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQ1|grep "Install ok Installed")
# # echo "Checking for somelib:" $PKG_OK
# # if [ "" == "$PKG_OK" ]; then
# # 	echo "no somelib. Setting up somelib."
# # 	sudo apt-get --force-yes --yes install $REQ1
# # fi
if ! which $REQ1 > /dev/null ; then
	echo "$REQ1 not Installed"
	#$REPLY="y"
	#if [ "$REPLY" == "y" ]; then
		sudo apt-get --force-yes --yes install $REQ1
	#fi
	echo "$REQ1 Installed!"
fi
REQ1='scp'
if ! which $REQ1 > /dev/null ; then
	echo "$REQ1 not Installed"
	#$REPLY="y"
	#if [ "$REPLY" == "y" ]; then
		sudo apt-get --force-yes --yes install $REQ1
	#fi
	echo "$REQ1 Installed!"
fi


# -- Variables Globales
SCRIPT="$(realpath $0)"
BASEFOLDER="$(dirname $SCRIPT)"
BACKUP_FOLDER=$BASEFOLDER"/backup"
WS_PATH="/var/www/html"
DAY=`date +"%Y%m%d"`
HOUR=`date +"%H%M"`
DB_ROOT=""
DB_PASSROOT=""

# -- Variables backup_vps
{
	# -- Ssh VPS
	VPS_USERNAME=""
	VPS_PASSWORD=""
	VPS_HOST="globalintegrator.cl"
	VPS_BACKUP_PATH="/home/webapps/backup"
	ARG_VPS="-a "$VPS_USERNAME" -b "$VPS_PASSWORD" -c "$VPS_HOST" -d "$VPS_BACKUP_PATH
	# -- Redmine
	REDMINE_HOME="/home/webapps/redmine"
	REDMINE_DB_NAME=""
	REDMINE_DB_USER=""
	REDMINE_DB_PASS=""
	ARG_BACKUP_REDMINE="-e "$REDMINE_HOME" -f "$REDMINE_DB_NAME" -g "$REDMINE_DB_USER" -h "$REDMINE_DB_PASS
	# -- Sugar
	SUGAR_HOME="/home/webapps/sugar"
	SUGAR_DB_NAME=""
	SUGAR_DB_USER=""
	SUGAR_DB_PASS=""
	ARG_BACKUP_SUGAR="-i "$SUGAR_HOME" -j "$SUGAR_DB_NAME" -k "$SUGAR_DB_USER" -l "$SUGAR_DB_PASS
	# -- Scp AWS
	AWS_USERNAME=""
	AWS_PASSWORD=""
	if [ -n "$AWS_PASSWORD" ] ; then
		AWS_PASSWORD='-n $AWS_PASSWORD'
	else
		AWS_PASSWORD=''
	fi
	AWS_HOST=''
	AWS_IP=''
	AWS_PATH=$BACKUP_FOLDER
	AWS_PEM="GlobalIntegrator.pem"
	#ARG_SCP_AWS='-m '$AWS_USERNAME' -n '$AWS_PASSWORD' -o '$AWS_HOST' -p '$AWS_PATH' -q '$AWS_PEM
	ARG_SCP_AWS='-m '$AWS_USERNAME' -o '$AWS_IP' -p '$AWS_PATH' -q '$AWS_PEM' '$AWS_PASSWORD
	# -- Argumentos
	ARG_BACKUP_VPS=$ARG_VPS' '$ARG_BACKUP_REDMINE' '$ARG_BACKUP_SUGAR' '$ARG_SCP_AWS
}

# -- Variables redmine_install
{
	# -- Variables
	REDMINE_TMP="/tmp/redmine_tmp"
	REDMINE_LOG="/var/log/redmine_upgrade.log"
	REDMINE_DB_USER=""
	REDMINE_DB_PASS=""
	REDMINE_DB_NAME=""
	# -- Argumentos
	ARG_REDMINE=' -a '$BASEFOLDER' -b '$BACKUP_FOLDER' -c '$WS_PATH' -d '$REDMINE_TMP' -e '$REDMINE_LOG' -f '$DB_ROOT' -g '$DB_PASSROOT' -h '$REDMINE_DB_USER' -i '$REDMINE_DB_PASS' -j '$REDMINE_DB_NAME
}

# -- Variables sugar_install
{
	# -- Variables
	SUGAR_TMP="/tmp/sugar_tmp"
	SUGAR_LOG="/var/log/sugar_upgrade.log"
	SUGAR_ROOT=""
	SUGAR_DB_ROOT=""
	SUGAR_DB_PASSROOT=""
	SUGAR_DB_USER=""
	SUGAR_DB_PASS=""
	SUGAR_DB_NAME=""
	# -- Argumentos
	ARG_SUGAR=' -a '$BACKUP_FOLDER' -b '$WS_PATH' -c '$SUGAR_TMP' -d '$SUGAR_LOG' -e '$SUGAR_ROOT' -f '$DB_ROOT' -g '$DB_PASSROOT' -h '$SUGAR_DB_USER' -i '$SUGAR_DB_PASS' -j '$SUGAR_DB_NAME
}
	echo "-----------"
	echo $ARG_BACKUP_VPS
	echo "-----------"
	echo $ARG_REDMINE
	echo "-----------"
	echo $ARG_SUGAR
	echo "-----------"


# -- Menu
# -- Muestra el menú general
_menu()
	{
		echo "Actualizador de plataforma Global Integrator"
		echo "Seleccione una opción:"
		echo
		echo " (1) Migrar desde VPS en AWS."
		echo " (2) Restaurar y actualizar Redmine."
		echo " (3) Restaurar de SugarCRM."
		echo " (4) Ejecutar Migración y Restauración Completa."
		echo " (5) Instalación y Actualización Completa."
		echo " (9) Salir."
		echo
		echo -n "Indique una opción: "
	}

# -- Muestra la opción seleccionada del menú
_mostrarResultado()
	{
		clear
		echo "Has seleccionado la opción $1"
	}

# -- Ejecutar Scripts
_ejecutaMigrarVPS()
	{
		clear
		echo "Iniciando Respaldo y Migración."
		sh $BASEFOLDER/backup_vps.sh $ARG_BACKUP_VPS
		echo "Finalizado Respaldo y Migración."
	}

_ejecutaRestaurarRedmine()
	{
		clear
		echo "Inicializando Restauración de Redmine."
		sh $BASEFOLDER/redmine_install.sh $ARG_REDMINE
		echo "Finalizado Restauración y Actualización de Redmine."
	}

_ejecutaMigrarRestauraSugar()
	{
		clear
		echo "Inicializando Restauracion de SugarCRM."
		sh $BASEFOLDER/sugar_install.sh $ARG_SUGAR
		echo "Restauración de SugarCRM."
	}

_ejecutaMigComp() {
	echo; echo "-------------------------------------------------------------------------------------------------------" ; echo;
	_ejecutaMigrarVPS
	echo; echo "-------------------------------------------------------------------------------------------------------" ; echo;
	_ejecutaRestaurarRedmine
	echo; echo "-------------------------------------------------------------------------------------------------------" ; echo;
	_ejecutaMigrarRestauraSugar
	echo; echo "-------------------------------------------------------------------------------------------------------" ; echo;
}

_ejecutaInstUpd() {
	echo; echo "-------------------------------------------------------------------------------------------------------" ; echo;
	_ejecutaRestaurarRedmine
	echo; echo "-------------------------------------------------------------------------------------------------------" ; echo;
	_ejecutaMigrarRestauraSugar
	echo; echo "-------------------------------------------------------------------------------------------------------" ; echo;
}

# Opción por defecto
if [ -n "$OPCION" ] ; then
	opcion="$OPCION"
else
	opcion="0"
fi
# echo 'OPCION -> '$opcions

# Bucle mientras la opción sea distinta de 9 (Salir)
until [ "$opcion" = "9" ];
	do
		case $opcion in
			1)	_ejecutaMigrarVPS $opcion
				;;
			2)	_ejecutaRestaurarRedmine $opcion
				;;
			3)	_ejecutaMigrarRestauraSugar $opcion
				;;
			4)	_ejecutaMigComp $opcion
				;;
			5)	_ejecutaInstUpd $opcion
				;;
			*) # esta opcion se ejecuta si no es ninguna de las anteriores
			   clear
			   _menu
			   ;;
		esac
		read opcion
done
