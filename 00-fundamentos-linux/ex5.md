## OPCIONAL - Modifica el ejercicio anterior de forma que la URL de la página web se pase por parámetro y también verifique que la llamada al script sea correcta

Si al invocar el script este no recibe dos parámetros (URL y palabra a buscar), se deberá de mostrar el siguiente mensaje:

```bash
$ ejercicio5.sh https://lemoncode.net/ patata 27
```

```
> Se necesitan únicamente dos parámetros para ejecutar este script
```

Además, si la palabra sólo se encuentra una vez en el fichero, se mostrará el siguiente mensaje:

```bash
$ ejercicio5.sh https://lemoncode.net/ patata
```

```
> La palabra "patata" aparece 1 vez
> Aparece únicamente en la línea 27
```

```bash
$ ejercicio5.sh https://lemoncode.net/ patata
```

```
> La palabra "patata" aparece 1 vez
> Aparece únicamente en la línea 27
```

### Solución

```bash
#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Se necesitan únicamente dos parámetros para ejecutar este script"
    echo "Sintaxis correcta del script:"
    echo "$0 <URL> <palabra>"
    exit 1
fi

URL="$1"
word="$2"

echo "> Bienvenido al script de búsqueda de palabras."

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
    if [ "$word_count" -eq 1 ]; then
        echo "> La palabra \"$word\" aparece 1 vez"
        echo "> Aparece únicamente en la línea $first_line"
    else
        echo "> La palabra \"$word\" aparece $word_count veces"
        echo "> Aparece por primera vez en la línea $first_line"
    fi
fi
```

### Demostración

Stdin:

```bash
$ ./ex5.sh "https://www.gutenberg.org/files/1342/1342-0.txt" "looking up"
``` 

Stdout:

```
> Bienvenido al script de búsqueda de palabras.
> La palabra "looking up" aparece 3 veces
> Aparece por primera vez en la línea 585
```

Stdin:

```bash
$ ./ex5.sh "https://www.gutenberg.org/files/1342/1342-0.txt" "PUBLISHER"
``` 

Stdout:

```
> Bienvenido al script de búsqueda de palabras.
> La palabra "PUBLISHER" aparece 1 vez
> Aparece únicamente en la línea 9
```

Stdin:

```bash
$ ./ex5.sh "https://www.gutenberg.org/files/1342/1342-0.txt" "patata"
```

```bash
> Bienvenido al script de búsqueda de palabras.
> No se ha encontrado la palabra "patata"
```

### Control de errores

Si la URL no es correcta, se mostrará el siguiente mensaje:

Stdin:

```bash
$ ./ex5.sh "https://www.gutenberg.org/files/1342/1342-0.tx" "looking up"
``` 

Stdout:

```
> Bienvenido al script de búsqueda de palabras.
Error: la descarga ha fallado -> código de error 404
```

Si no se pasan los parámetros correctos, se mostrará el siguiente mensaje:
```bash
$ ./ex5.sh "https://www.gutenberg.org/files/1342/1342-0.txt"
```

```
Se necesitan únicamente dos parámetros para ejecutar este script
Sintaxis correcta del script:
./ex5.sh <URL> <palabra>
```