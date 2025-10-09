## Enunciado

### Crea mediante comandos de bash la siguiente jerarquía de ficheros y directorios

```
foo/
├─ dummy/
│  ├─ file1.txt
│  ├─ file2.txt
├─ empty/
```

Donde file1.txt debe contener el siguiente texto:

```
Me encanta la bash!!
```

file2.txt debe permanecer vacío.

### Solución

```bash
mkdir -p foo/{dummy,empty}
echo 'Me encanta la bash!!' > ./foo/dummy/file1.txt
touch ./foo/dummy/file2.txt
```

### Demostración

Stdin:

```bash
$ tree foo
```

Stdout:

```              
foo
├── dummy
│   ├── file1.txt
│   └── file2.txt
└── empty
```