#################################################################
# Nombre de Proceso :	 redmine_install						#
# Descripcion       :	 Restaura Redmine y lo actualiza.		#
# Fecha de Creacion :	 04 de Mayo de 2016						#
# Fecha de Modificación: 11 de Mayo de 2016						#
#################################################################

#! /bin/bash

# -- Argumentos
while getopts ':a:b:c:d:e:f:g:h:i:' opt ; do
	case $opt in
	a)  BACKUP_FOLDER=$OPTARG;;
	b)	WS_PATH=$OPTARG;;
	c)	REDMINE_TMP=$OPTARG;;
	d)	REDMINE_LOG=$OPTARG;;
	e)	REDMINE_DB_ROOT=$OPTARG;;
	f)	REDMINE_DB_PASSROOT=$OPTARG;;
	g)	REDMINE_DB_USER=$OPTARG;;
	h)	REDMINE_DB_PASS=$OPTARG;;
	i)	REDMINE_DB_NAME=$OPTARG;;
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
echo "REDMINE_TMP -> "$REDMINE_TMP
echo "REDMINE_LOG -> "$REDMINE_LOG
echo "REDMINE_DB_ROOT -> "$REDMINE_DB_ROOT
echo "REDMINE_DB_PASSROOT -> "$REDMINE_DB_PASSROOT
echo "REDMINE_DB_USER -> "$REDMINE_DB_USER
echo "REDMINE_DB_PASS -> "$REDMINE_DB_PASS
echo "REDMINE_DB_NAME -> "$REDMINE_DB_NAME

# -- Variables Globales
DAY=`date +"%Y%m%d"`
HOUR=`date +"%H%M"`

echo; echo "-------------------------------------------------------------------------------------------------------" ; echo;

# -- Variables Redmine
REDMINE_PATH_INSTANCE=$WS_PATH"/redmine"
REDMINE_BACKUPFILE=$BACKUP_FOLDER"/$(ls -Art "$BACKUP_FOLDER" | grep redmine | tail -n 1)"

# -- Script

# -- Restauracion de Directorio
echo 'Restaurando Directorio...'
tar -xjf $REDMINE_BACKUPFILE -C $WS_PATH
rm -R $REDMINE_PATH_INSTANCE
mv $WS_PATH/home/webapps/redmine/redmine-2.3 $REDMINE_PATH_INSTANCE
mv $WS_PATH/home/webapps/redmine/backupdb $REDMINE_PATH_INSTANCE/backupdb
REDMINE_DB_BACKUP=$REDMINE_PATH_INSTANCE"/backupdb/$(ls -Art "$REDMINE_PATH_INSTANCE"/backupdb | grep redmine | tail -n 1)"
rm -R $WS_PATH/home
chown www-data:www-data -R $WS_PATH
chmod 755 -R $REDMINE_PATH_INSTANCE

# -- Restauracion de Base de datos
echo "Restaurando Base de datos..."
 mysql -u $REDMINE_DB_ROOT -p$REDMINE_DB_PASSROOT <<EOF
   CREATE DATABASE $REDMINE_DB_NAME;
   CREATE USER $REDMINE_DB_USER@localhost;
   GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, DROP ON $REDMINE_DB_USER.* TO '$REDMINE_DB_USER'@'localhost' IDENTIFIED B '$REDMINE_DB_PASS';"
   GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, DROP ON $REDMINE_DB_USER.* TO '$REDMINE_DB_USER'@'localhost.localdomain' IDENTIFIE BY '$REDMINE_DB_PASS';"
   FLUSH PRIVILEGES;
   quit
EOF
mysql -u $REDMINE_DB_ROOT -p$REDMINE_DB_PASSROOT $REDMINE_DB_NAME < $REDMINE_DB_BACKUP

# -- Levantamiento de Passenger
echo "Levantando Apache y Paseenger..."
rm /etc/apache2/sites-enabled/*
rm /etc/apache2/sites-available/passenger.conf
cp $BASEFOLDER/passenger.conf /etc/apache2/sites-available/passenger.conf
a2ensite passenger.conf

# -- Restaurando Redmine Migrado
echo "Restaurando Redmine Migrado..."
cd $REDMINE_PATH_INSTANCE
bundle install
service apache2 restart

echo "Restauracion Redmine Completada"
echo ;

# -- Actualizando Redmine
echo "Actualizando Redmine..."
svn upgrade $REDMINE_PATH_INSTANCE
svn update $REDMINE_PATH_INSTANCE
bundle update
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
bundle exec rake tmp:cache:clear tmp:sessions:clear RAILS_ENV=production
cd $BACKUP_FOLDER
service apache2 restart

echo "Actualización Redmine Completada."

echo; echo "-------------------------------------------------------------------------------------------------------" ; echo;
