#Migración Global Integrator de VPS a AWS

##Url
> SugarCRM  : http://ec2-54-187-209-236.us-west-2.compute.amazonaws.com/sugar
</br>
> Redmine   : http://ec2-54-187-209-236.us-west-2.compute.amazonaws.com/redmine

##Instalación
```
	wget https://github.com/KayserV/Backup-install-Global-Services/releases/download/1.01/Scripts.tar.xz
```

##Ejecución
####Modo Manual
```
	sh upgrade_global.sh
```
####Modo Silencioso
```
	sh upgrade_global.sh -o <opcion>
```

> Nota: Para utilizar la aplicación recuerde usarlo con privilegios de administrador.

##Estructura del programa
El programa se compone de 2 modos de uso uno automatico ejecutado por argumentos y otro manual el cual contiene un menú de ejecucion de procesos.

1. **Migrar desde VPS en AWS.**</br>
	Migra desde el VPS los ambientes de SugraCRM y Redmine con sus bases de datos repsectivas, generando respaldo completo de ellos, luego las transporta hacia el servidor AWS, para ubcar los archivos en la carpeta `<aplicacion>/backup`.
2. **Restaurar y actualizar Redmine.**</br>
	Restaura el respaldo encontrado en `<aplicacion>/backup`, configura Passenger, inicializa Apache y actualiza a la ultima version de Redmine por medio de SVN.
3. **Restaurar de SugarCRM.**</br>
	Restaura el respaldo encontrado en `<aplicacion>/backup` e inicializa Apache.
4. **Ejecutar Migración y Restauración Completa.**</br>
	Ejecuta los procesos 1, 2 y 3.
5.  **Instalación y Actualización Completa.**</br>
	Ejecuta los procesos 2 y 3.
9. **Salir.**</br>
	Sale de la aplicación.


###Objetivos
- [x] Backup Redmine.
- [x] Restauración Redmine.
- [x] Actualización Redmine a ultima versión.
- [x] Backup SugarCRM.
- [x] Restaruración SugarCRM.
- [ ] Actualización SugarCRM.
- [x] Apache según Dominio/subcarpeta.
- [ ] Apache subdominio.dominio.
- [ ] Configuracion de DNS y Apache automática.- Notificación via mail.
- [x] Utilizable desde cualquier directorio.
- [x] Sistema de log Grafico.
- [ ] Sistema de Log por archivo.
- [x] Argumentos y parametros en el script.
- [x] Modo de opciones al ejecutar.
- [x] Reintento en caso de error de forma manual.
- [ ] Reintento en caso de error automático.
