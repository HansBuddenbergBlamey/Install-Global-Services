#############################################################
# Nombre de Proceso :	 upgrade_global						#
# Descripcion       :	 Migra los desde el VPS hacia AWS,	#
#						 instala y actualiza los ambientes	#
#						 de Redmine y SugarCRM.				#
# Fecha de Creacion :	 04 de Mayo de 2016					#
# Fecha de Modificación: 10 de Mayo de 2016					#
#############################################################

#! /bin/bash

# -- Argumentos

# -- Parametros


# -- Variables
# -- Globales
script="$0"
basename="$(dirname $script)"
BackupFolder=$basename"/backup"

# -- Script

echo "Inicializando Respaldo"
sh $basename/backup_vps.sh
echo ""
echo "Inicializando Restauracion"
echo ""
sh $basename/sugar_install.sh
echo ""
sh $basename/redmine_install.sh
echo ""
# -- Limpieza de Directorio Backup
echo "Limpiando Residuos de directorio Backup AWS..."
#rm -R $BackupFolder
#rm $basename/sugar_install.sh
#rm $basename/redmine_install.sh
#rm $basename/backup_vps.sh
echo ""
echo "Termiando Proceso"
echo ""
