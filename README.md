# MusApp - Documentación y Estado

Bienvenido! MusApp es un prototipo de plataforma enfocada en la creación, respuesta y revisión de evaluaciones online de música, entregando las herramientas necesarias para que alumno pueda demostrar sus conocimientos musicales, tanto teóricos como prácticos.

+ Como profesor: Podrás crear evaluaciones con distintos tipos de preguntas estándar: Verdadero o Falso, Selección Múltiple, y Respuesta de Desarrollo. Además, podrás agregar preguntas del tipo musical, donde el alumno podrá tocar pianos virtuales con su computadora y escribir partituras que podrás leer y escuchar, al momento de revisar sus respuestas. Tendrás acceso a un sistema donde podrás ver tus Asignaturas y las evaluaciones creadas, publicadas y corregidas.

+ Como alumno: Podrás responder las evaluaciones publicadas por tu profesor, teniendo la posibilidad de responder con alternativas, texto, tocando pianos virtuales y escribiendo partituras. Tus evaluaciones serán separadas por Asignatura, y podrás ver las notas que obtuviste en cada una de tus pruebas

## Como ejecutar la aplicación en tu computadora

MusApp consta tanto de una aplicación de escritorio para Windows, y de un backend de pruebas locales que podrás utilizar para probar la aplicación. Deberás clonar este repositorio y seguir las instrucciones detalladas más adelante.

## MusApp Backend
Para ejecutar el backend será necesario tener una versión de Python 3 instalada. Luego, crearemos un ambiente virtual para mantener encapsulado cualquier framework que vayamos a instalar, para ello será necesario ir a la carpeta MusAppBackend en una consola de comandos (PowerShell, cmd) y ejecutar

```console
pip install virtualenv
python -m virtualenv venv
```

Para activar el ambiente virtual utilizaremos
```console
.\venv\Scripts\activate
```

Una vez inicializado el ambiente virtual, instalaremos django y django-rest-framework. Para utilizar las versiones con las que desarrollé el proyecto, recomiendo utilizar la siguiente línea de código:

```console
pip install to-requirements.txt
```

Si por algún motivo no funcionase o quisieras utilizar tus propias versiones, ejecuta:
```console
pip install django
pip install djangorestframework
```

Ya teniendo el ambiente virtual y los frameworks necesaios, ejecutaremos el proyecto en django con las siguientes tres líneas de código:

```console
python manage.py makemigrations
python manage.py migrate  
python manage.py runserver 8000
```

Con dichos pasos la aplicación estará corriendo en un servidor local en el puerto 8000, lugar donde se conectará con la app de escritorio.


## MusApp de Escritorio

Para ejecutarlo, solo deberás entrar a la carpeta MusApp y descomprimir el contenido del archivo MusAppEjecutable.zip en la carpeta MusApp (¡IMPORTANTE! no debe quedar en una subcarpeta, debe ser MusApp/MusApp.exe), despues, ejecutar MusApp.exe (con el servidor local activo), y podrás utilizar la aplicación sin problemas.

En caso de querer ver los códigos a detalle e interfaces, será necesario descargar Godot 4.0 del siguiente [enlace](https://github.com/godotengine/godot/tree/4.0-stable), el cual fue utilizado para el desarrollo. Una vez instalado, será necesario abrir la aplicación y buscar el proyecto de MusApp. Una vez abierto, en la sección superior de Script podrá ver todos los códigos utilizados para el desarrollo de la aplicación.


## Para desenvolverse dentro de la aplicación

En primer lugar, es necesario crear un administrador, lo cual se realiza por consola, por ende, detenido nuestro servidor ejecutaremos

```console
python manage.py createsuperuser
```

Aquí es donde nos pedirá elementos como email, nombre, apellido y contraseña, recuerdalos!

Luego, en la aplicación de escritorio, podrás ingresar con las credenciales de administrador y entrar a la pantalla de inicio, donde como admin podrás crear cursos, letras y asignaturas.

Los pasos que recomiendo para ir creando los distintos aspectos de un establecimiento son:
+ Crear cursos y letras como administrador
+ En la pantalla de inicio de MusApp crear profesores
+ En la pantalla de inicio de MusApp crear alumnos dentro de algun curso establecido
+ Crear asignaturas dando un profesor y los alumnos que perteneceran

Una vez hecho estos pasos, la dinámica de profesores y alumnos es la siguiente:

+ Un profesor crea una evaluación en una asignatura especifica
+ El profesor publica la evaluación para que los alumnos la contesten (este proceso no es automático)
+ El alumno responde la evaluación
+ El profesor cierra la evaluación (actualmente se debe hacer de manera manual)
+ El profesor revisa las evaluaciones respondidas, si un alumno no respondió nada, se le crea una respuesta en blanco y se le asigna nota mínima.
+ Los alumnos podrán ver sus notas publicadas en Mis Notas


Para cualquier duda o consulta, escribir a vicentediazg@gmail.com