## Enunciado

### Crear un script de bash que agrupe los pasos de los ejercicios anteriores y además permita establecer el texto de file1.txt alimentándose como parámetro al invocarlo

Si se le pasa un texto vacío al invocar el script, el texto de los ficheros, el texto por defecto será:

```
Que me gusta la bash!!!!
```

### Solución

```bash
#!/bin/bash

text="${1:-Que me gusta la bash!!!!}"

mkdir -p ./foo/{dummy,empty}
echo "$text" > ./foo/dummy/file1.txt
touch ./foo/dummy/file2.txt
cat ./foo/dummy/file1.txt > ./foo/dummy/file2.txt
mv ./foo/dummy/file2.txt ./foo/empty/file2.txt
```

### Demostración

Stdin:

```bash
$ ./ex3.sh 'Me encanta la bash!!'
$ tree foo
```

Stdout:

```
foo
├── dummy
│   └── file1.txt
└── empty
    └── file2.txt
```

Stdin:

```bash
$ cat ./foo/dummy/file1.txt
```

Stdout:

```
Me encanta la bash!!
```

Stdin:

```bash
$ cat ./foo/empty/file2.txt
```

Stdout:

```
Me encanta la bash!!
```


### Demostración con valor por defecto

Stdin:

```bash
$ ./ex3.sh
$ tree foo
```

Stdout:

```
foo
├── dummy
│   └── file1.txt
└── empty
    └── file2.txt
```

Stdin:

```bash
$ cat ./foo/dummy/file1.txt
```

Stdout:

```
Que me gusta la bash!!!!
```

Stdin:

```bash
$ cat ./foo/empty/file2.txt
```

Stdout:

```
Que me gusta la bash!!!!
```