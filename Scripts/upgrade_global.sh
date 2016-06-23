#################################################################
# Nombre de Proceso :	 upgrade_global							#
# Descripcion       :	 Migra desde el VPS hacia AWS,			#
#			 			 instala y actualiza los ambientes		#
#			 			 de Redmine y SugarCRM.					#
# Fecha de Creacion :	 04 de Mayo de 2016						#
# Fecha de Modificación: 18 de Mayo de 2016						#
#################################################################

#! /bin/bash

# -- Variables Globales
SCRIPT="$(realpath $0)"
BASEFOLDER="$(dirname $SCRIPT)"
CONFIG_FILE="$BASEFOLDER/config/settings"

# -- Habilirar Setteo
source $CONFIG_FILE

# -- Habilitar Logger
source

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
		sh $BASEFOLDER/scripts/backup_vps.sh $ARG_BACKUP_VPS
		echo "Finalizado Respaldo y Migración."
	}

_ejecutaRestaurarRedmine()
	{
		clear
		echo "Inicializando Restauración de Redmine."
		sh $BASEFOLDER/scripts/redmine_install.sh $ARG_REDMINE
		echo "Finalizado Restauración y Actualización de Redmine."
	}

_ejecutaMigrarRestauraSugar()
	{
		clear
		echo "Inicializando Restauracion de SugarCRM."
		sh $BASEFOLDER/scripts/sugar_install.sh $ARG_SUGAR
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
