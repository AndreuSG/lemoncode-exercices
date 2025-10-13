## Crea un script de bash que descargue el contenido de una página web a un fichero y busque en dicho fichero una palabra dada como parámetro al invocar el script

La URL de dicha página web será una constante en el script.

Si tras buscar la palabra no aparece en el fichero, se mostrará el siguiente mensaje:

```
$ ejercicio4.sh patata
> No se ha encontrado la palabra "patata"
```

Si por el contrario la palabra aparece en la búsqueda, se mostrará el siguiente mensaje:

```
$ ejercicio4.sh patata
> La palabra "patata" aparece 3 veces
> Aparece por primera vez en la línea 27
```

### Solución
```bash
#!/bin/bash

URL="https://www.gutenberg.org/files/1342/1342-0.txt"

if [ $# -ne 1 ]; then
    echo "Sintaxis correcta del script:"
    echo "$0 <palabra>"
    exit 1
fi

echo "> Bienvenido al script de búsqueda de palabras del libro 'Pride and Prejudice'."

word="$1"

http_code=$(curl -s -o prideAndPrejudice.txt -w "%{http_code}" "$URL")
if [ "$http_code" -ne 200 ]; then
    echo "Error: la descarga ha fallado -> código de error $http_code"
    exit 1
fi

if ! grep -q "$word" prideAndPrejudice.txt; then
    echo "> No se ha encontrado la palabra \"$word\""
else
    word_count=$(grep -c "$word" prideAndPrejudice.txt)
    first_line=$(grep -n "$word" prideAndPrejudice.txt | head -n 1 | cut -d: -f1)
    echo "> La palabra \"$word\" aparece $word_count veces"
    echo "> Aparece por primera vez en la línea $first_line"
fi
```

### Demostración

Stdin:

```bash
$ ./ex4.sh "looking up"
```

Stdout:

```
> Bienvenido al script de búsqueda de palabras del libro 'Pride and Prejudice'.
> La palabra "looking up" aparece 3 veces
> Aparece por primera vez en la línea 585
```

Stdin:

```bash
$ ./ex4.sh "patata"
```

Stdout:

```
> Bienvenido al script de búsqueda de palabras del libro 'Pride and Prejudice'.
> No se ha encontrado la palabra "patata"
```

### Control de errores

Si no se pasa ningún parámetro al script, se mostrará un mensaje de error indicando la sintaxis correcta del script. Nos imaginamos que el script se llama `ex4.sh`:

Stdin:

```bash
$ ./ex4.sh
```

Stdout:

```
Sintaxis correcta del script:
$ ./ex4.sh <palabra>
```

Si la descarga de la página web falla, se mostrará un mensaje de error indicando que la descarga ha fallado y el código de error HTTP, para forzar el error, podemos cambiar la URL a una errónea:

Stdin:

```bash
$ ./ex4.sh "looking up"
```

Stdout:

```
> Bienvenido al script de búsqueda de palabras del libro 'Pride and Prejudice'.
Error: la descarga ha fallado -> código de error 404
```