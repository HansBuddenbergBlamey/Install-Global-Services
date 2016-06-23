#################################################################
# Nombre de Proceso :	 redmine_install						#
# Descripcion       :	 Restaura Redmine y lo actualiza.		#
# Fecha de Creacion :	 04 de Mayo de 2016						#
# Fecha de Modificación: 11 de Mayo de 2016						#
#################################################################

#! /bin/bash

# -- Argumentos
while getopts ':a:b:c:d:e:f:g:h:i:j:' opt ; do
	case $opt in
	a)  BACKUP_FOLDER=$OPTARG;;
	b)	WS_PATH=$OPTARG;;
	c)	SUGAR_TMP=$OPTARG;;
	d)	SUGAR_LOG=$OPTARG;;
	e)	SUGAR_ROOT=$OPTARG;;
	f)	SUGAR_DB_ROOT=$OPTARG;;
	g)	SUGAR_DB_PASSROOT=$OPTARG;;
	h)	SUGAR_DB_USER=$OPTARG;;
	i)	SUGAR_DB_PASS=$OPTARG;;
	j)	SUGAR_DB_NAME=$OPTARG;;
	# -- Error
	\?) print -u2 ¿Que es -${OPTARG}?
		((error=error+1))
		;;
	:)
		print -u2 $OPTARG nesecita argumento.
		((error=error+1))
		;;
	esac
done

echo "BACKUP_FOLDER -> "$BACKUP_FOLDER
echo "WS_PATH -> "$WS_PATH
echo "SUGAR_TMP -> "$SUGAR_TMP
echo "SUGAR_LOG -> "$SUGAR_LOG
echo "SUGAR_ROOT -> "$SUGAR_ROOT
echo "SUGAR_DB_ROOT -> "$SUGAR_DB_ROOT
echo "SUGAR_DB_PASSROOT -> "$SUGAR_DB_PASSROOT
echo "SUGAR_DB_USER -> "$SUGAR_DB_USER
echo "SUGAR_DB_PASS -> "$SUGAR_DB_PASS
echo "SUGAR_DB_NAME -> "$SUGAR_DB_NAME

# -- Variables Globales
DAY=`date +"%Y%m%d"`
HOUR=`date +"%H%M"`

echo; echo "-------------------------------------------------------------------------------------------------------" ; echo;

# -- Variables Redmine
SUGAR_VERSION="6.5.13"
SUGAR_6_5_20="6.5.20"
SUGAR_LATEST="6.5.23"
SUGAR_PATH_INSTANCE=$WS_PATH"/sugar"
SUGAR_BACKUPFILE=$BACKUP_FOLDER"/$(ls -Art "$BACKUP_FOLDER" | grep sugar | tail -n 1)"
SUGAR_UPGRADE_6_5_20="SugarCE-Upgrade-6.5.x-to-$SUGAR_6_5_20.zip"
SUGAR_UPGRADE_LATEST="SugarCE-Upgrade-6.5.x-to-$SUGAR_LATEST.zip"

# -- Script

# -- Restauracion de Directorio
echo 'Restaurando Directorio...'
tar -xjf $SUGAR_BACKUPFILE -C $WS_PATH
rm -R $SUGAR_PATH_INSTANCE
mv $WS_PATH/home/webapps/sugar $SUGAR_PATH_INSTANCE
rm -R $WS_PATH/home
chown www-data:www-data -R $WS_PATH
SUGAR_DB_BACKUP=$SUGAR_PATH_INSTANCE"/backupdb/$(ls -Art "$SUGAR_PATH_INSTANCE"/backupdb | grep sugar | tail -n 1)"
chmod 755 -R $SUGAR_PATH_INSTANCE

# -- Restauracion de Base de datos
echo "Restaurando Base de datos..."
mysql -u $SUGAR_DB_ROOT -p$SUGAR_DB_PASSROOT <<EOF
  CREATE DATABASE $SUGAR_DB_USER;
  CREATE USER $SUGAR_DB_USER@localhost;
  GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, DROP ON $SUGAR_DB_USER.* TO '$SUGAR_DB_USER'@'localhost' IDENTIFIED BY '$SUGAR_DB_PASS';
  GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, DROP ON $SUGAR_DB_USER.* TO '$SUGAR_DB_USER'@'localhost.localdomain' IDENTIFIED BY '$SUGAR_DB_PASS';
  FLUSH PRIVILEGES;
  quit
EOF
mysql -u $SUGAR_DB_ROOT -p$SUGAR_DB_PASSROOT $SUGAR_DB_NAME < $SUGAR_DB_BACKUP

echo "Levantando Apache..."
service apache2 restart

echo "Restauracion SugarCRM Completada"

# -- Upgrade - No listo
# cp $SUGAR_PATH_INSTANCE/config.php $(pwd)
# echo "wget -c http://tenet.dl.sourceforge.net/project/sugarcrm/1%20-%20SugarCRM%206.5.X/SugarCommunityEdition-6.5.X%20Upgrade/silentUpgrade-CE-"$SUGAR_6_5_20".zip -O silentUpgrade-CE-"$SUGAR_6_5_20".zip"
# echo "wget -c http://tenet.dl.sourceforge.net/project/sugarcrm/1%20-%20SugarCRM%206.5.X/SugarCommunityEdition-6.5.X%20Upgrade/SugarCE-Upgrade-6.5.x-to-"$SUGAR_6_5_20".zip -O SugarCE-Upgrade-6.5.x-to-"$SUGAR_6_5_20".zip"
# wget -c http://tenet.dl.sourceforge.net/project/sugarcrm/1%20-%20SugarCRM%206.5.X/SugarCommunityEdition-6.5.X%20Upgrade/silentUpgrade-CE-$SUGAR_6_5_20.zip -O silentUpgrade-CE-$SUGAR_6_5_20.zip
# wget -c http://tenet.dl.sourceforge.net/project/sugarcrm/1%20-%20SugarCRM%206.5.X/SugarCommunityEdition-6.5.X%20Upgrade/SugarCE-Upgrade-6.5.x-to-$SUGAR_6_5_20.zip -O SugarCE-Upgrade-6.5.x-to-$SUGAR_6_5_20.zip
#
#
# mv $(pwd)/SugarCE-Upgrade-6.5.x-to-$SUGAR_6_5_20.zip $WS_PATH
# mv $(pwd)/silentUpgrade-CE-$SUGAR_6_5_20.zip $WS_PATH
#
# cd $WS_PATH
# unzip -o $WS_PATH/silentUpgrade-CE-$SUGAR_6_5_20.zip -d $WS_PATH
# echo  "php -f silentUpgrade.php "$WS_PATH"/"$SUGAR_UPGRADE_6_5_20" "$SUGAR_LOG" "$SUGAR_PATH_INSTANCE" "$SUGAR_ROOT
# php -f $WS_PATH/silentUpgrade.php $WS_PATH/$SUGAR_UPGRADE_6_5_20 $SUGAR_LOG $SUGAR_PATH_INSTANCE $SUGAR_ROOT
