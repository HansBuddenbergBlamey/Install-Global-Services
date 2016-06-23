#################################################################
# Nombre de Proceso :	 backup_vps								#
# Descripcion       :	 Respalda y migra desde el VPS hacia	#
#			 			 AWS, los ambientes de Redmine y 		#
#						 SugarCRM.								#
# Fecha de Creacion :	 04 de Mayo de 2016						#
# Fecha de Modificación: 11 de Mayo de 2016						#
#################################################################

#! /bin/bash

# -- Argumentos
while getopts ':a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:' opt ; do
	case $opt in
	# -- SSH VPS
	a)	VPS_USERNAME=$OPTARG;;
	b)	VPS_PASSWORD=$OPTARG;;
	c)	VPS_HOST=$OPTARG;;
	d)	VPS_BACKUP_PATH=$OPTARG;;
	# -- Redmine
	e)	REDMINE_HOME=$OPTARG;;
	f)	REDMINE_DB_NAME=$OPTARG;;
	g)	REDMINE_DB_USER=$OPTARG;;
	h)	REDMINE_DB_PASS=$OPTARG;;
	# -- Sugar
	i)	SUGAR_HOME=$OPTARG;;
	j)	SUGAR_DB_NAME=$OPTARG;;
	k)	SUGAR_DB_USER=$OPTARG;;
	l)	SUGAR_DB_PASS=$OPTARG;;
	# -- SCP AWS
	m)	AWS_USERNAME=$OPTARG;;
	n)	AWS_PASSWORD=$OPTARG;;
	o)	AWS_HOST=$OPTARG;;
	p)	AWS_PATH=$OPTARG;;
	q)	AWS_PEM=$OPTARG;;
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

# -- SSH VPS
echo "VPS_USERNAME -> "$VPS_USERNAME
echo "VPS_PASSWORD -> "$VPS_PASSWORD
echo "VPS_HOST -> "$VPS_HOST
echo "VPS_BACKUP_PATH -> "$VPS_BACKUP_PATH
# -- Redmine
echo "REDMINE_HOME -> "$REDMINE_HOME
echo "REDMINE_DB_NAME -> "$REDMINE_DB_NAME
echo "REDMINE_DB_USER -> "$REDMINE_DB_USER
echo "REDMINE_DB_PASS -> "$REDMINE_DB_PASS
# -- Sugar
echo "SUGAR_HOME -> "$SUGAR_HOME
echo "SUGAR_DB_NAME -> "$SUGAR_DB_NAME
echo "SUGAR_DB_USER -> "$SUGAR_DB_USER
echo "SUGAR_DB_PASS -> "$SUGAR_DB_PASS
# -- SCP AWS
echo "AWS_USERNAME -> "$AWS_USERNAME
echo "AWS_PASSWORD -> "$AWS_PASSWORD
echo "AWS_HOST -> "$AWS_HOST
echo "AWS_PATH -> "$AWS_PATH
echo "AWS_PEM -> "$AWS_PEM


# -- Variables Globales
DAY=`date +"%Y%m%d"`
HOUR=`date +"%H%M"`

# -- Variables Redmine
REDMINE_DB_BACKUP_DIR=$REDMINE_HOME"/backupdb"
REDMINE_DB_BACKUP=$REDMINE_DB_BACKUP_DIR"/redmine_mysql_"$DAY"_"$HOUR".sql"
REDMINE_BACKUP_NAME="redmine_"$DAY"_"$HOUR".tar.bz2"

# -- Variables Sugar
SUGAR_DB_BACKUP_DIR=$SUGAR_HOME"/backupdb"
SUGAR_DB_BACKUP=$SUGAR_DB_BACKUP_DIR"/sugar_mysql_"$DAY"_"$HOUR".sql"
SUGAR_BACKUP_NAME="sugar_"$DAY"_"$HOUR".tar.bz2"

# -- Variables Argumentos sshpass
SCP_AWS="AWS_USERNAME="$AWS_USERNAME" AWS_PASSWORD="$AWS_PASSWORD" AWS_HOST="$AWS_HOST" AWS_PATH="$AWS_PATH" AWS_PEM="$AWS_PEM
SSH_REDMINE="REDMINE_HOME="$REDMINE_HOME" REDMINE_DB_NAME="$REDMINE_DB_NAME" REDMINE_DB_USER="$REDMINE_DB_USER" REDMINE_DB_PASS="$REDMINE_DB_PASS" REDMINE_DB_BACKUP="$REDMINE_DB_BACKUP"  REDMINE_DB_BACKUP_DIR="$REDMINE_DB_BACKUP_DIR" REDMINE_BACKUP_NAME="$REDMINE_BACKUP_NAME
SSH_SUGAR="SUGAR_HOME="$SUGAR_HOME" SUGAR_DB_NAME="$SUGAR_DB_NAME" SUGAR_DB_USER="$SUGAR_DB_USER" SUGAR_DB_PASS="$SUGAR_DB_PASS" SUGAR_DB_BACKUP="$SUGAR_DB_BACKUP" SUGAR_DB_BACKUP_DIR="$SUGAR_DB_BACKUP_DIR" SUGAR_BACKUP_NAME="$SUGAR_BACKUP_NAME
SSH_PASS_ARG="VPS_BACKUP_PATH="$VPS_BACKUP_PATH" "$SCP_AWS" "$SSH_REDMINE" "$SSH_SUGAR

# -- Script
echo; echo "-------------------------------------------------------------------------------------------------------" ; echo;

# -- Limpieza de Directorio Backup
echo "Limpiando Residuos de directorio Backup AWS..."
rm -R $AWS_PATH
mkdir $AWS_PATH
chmod 777 $AWS_PATH
echo ;

# -- Conectar SSH
echo "Conectandose por medio de SSH a ambiente VPS..."
sshpass -p $VPS_PASSWORD ssh $VPS_USERNAME@$VPS_HOST $SSH_PASS_ARG 'bash -s' <<'ENDSSH'
echo "Conectado."
echo ;

# -- Limpieza de Directorio Backup
echo "Limpiando Residuos de directorio Backup VPS..."
rm $VPS_BACKUP_PATH/*
rm $REDMINE_DB_BACKUP_DIR/*
rm $SUGAR_DB_BACKUP_DIR/*
echo ;

# -- Backup MySQL Redmine
echo "Generando Snapshot de la base de datos de Redmine de MySQL..."
mysqldump --user=$REDMINE_DB_USER --password=$REDMINE_DB_PASS $REDMINE_DB_NAME > $REDMINE_DB_BACKUP
echo "($REDMINE_DB_BACKUP) Realizado."
echo ;

# -- Backup Redmine
echo "Generando Snapshot del directorio de Redmine..."
tar --exclude='files' -cjf $VPS_BACKUP_PATH/$REDMINE_BACKUP_NAME $REDMINE_HOME
tar -cjf $VPS_BACKUP_PATH/$REDMINE_BACKUP_NAME $REDMINE_HOME
echo "($VPS_BACKUP_PATH/$REDMINE_BACKUP_NAME) Realizado."
echo ;

# -- Backup MySQL Sugar
echo "Generando Snapshot de la base de datos de Sugar de MySQL..."
mysqldump --user=$SUGAR_DB_USER --password=$SUGAR_DB_PASS $SUGAR_DB_NAME > $SUGAR_DB_BACKUP
echo "($SUGAR_DB_BACKUP) Realizado."
echo ;

# -- Backup Sugar
echo "Generando Snapshot del directorio de Sugar..."
tar -cjf $VPS_BACKUP_PATH/$SUGAR_BACKUP_NAME $SUGAR_HOME
tar -cjf $VPS_BACKUP_PATH/$SUGAR_BACKUP_NAME $SUGAR_HOME
echo "($VPS_BACKUP_PATH/$SUGAR_BACKUP_NAME) Realizado."
echo ;

# -- Envio hacia AWS
echo "Enviando archivo a AWS..."
scp -i $AWS_PEM $VPS_BACKUP_PATH/$REDMINE_BACKUP_NAME $AWS_USERNAME@$AWS_HOST:$AWS_PATH
echo "Redmine - ($AWS_HOST : $AWS_PATH/$REDMINE_BACKUP_NAME) >> Enviado."
scp -i $AWS_PEM $VPS_BACKUP_PATH/$SUGAR_BACKUP_NAME $AWS_USERNAME@$AWS_HOST:$AWS_PATH
echo "Sugar - ($AWS_HOST : $AWS_PATH/$SUGAR_BACKUP_NAME) >> Enviado."
echo;

# ENDSSH

echo "Desconectado de ambiente VPS..."
echo; echo "-------------------------------------------------------------------------------------------------------" ; echo;
