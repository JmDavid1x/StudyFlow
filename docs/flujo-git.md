# Cómo trabajamos con Git

El profesor califica los commits de **cada uno** (la calidad, no la cantidad), así que cada persona sube su parte con su propia cuenta de GitHub.

## Una vez

```bash
git clone https://github.com/JmDavid1x/StudyFlow.git
cd StudyFlow
flutter pub get
```

Configura tu nombre y tu correo (el mismo de tu cuenta de GitHub, para que el commit quede a tu nombre):

```bash
git config user.name "Tu Nombre"
git config user.email "tu-correo-de-github@ejemplo.com"
```

## Cada vez que vas a trabajar

```bash
git checkout main
git pull
git checkout -b feature/tu-rama        # solo la primera vez
# o, si la rama ya existe:
git checkout feature/tu-rama
git merge main                         # trae lo último de los demás
```

## Commits

- Un commit por cosa terminada: una pantalla, un componente, un arreglo. No un solo commit gigante al final.
- El mensaje dice qué hiciste, empezando por el tipo:
  - `feat: pantalla de registro con validación de campos`
  - `fix: el botón de guardar no se deshabilitaba`
  - `refactor: SfTaskTile en la lista de tareas`
  - `docs: explicación del flujo de materias`

```bash
git add lib/features/tu-feature
git commit -m "feat: ..."
git push -u origin feature/tu-rama
```

## Pull Request

1. En GitHub abre un **Pull Request** de tu rama a `main`.
2. Otra persona del grupo lo revisa: corre la app, mira el código y deja un comentario.
3. Si está bien, se une a `main` con **Create a merge commit**, no con "Squash": así se conservan tus commits con tu nombre.

## Antes de cada sustentación

Todos revisamos juntos todo lo que se subió. El profe pregunta al azar por cualquier parte del código, no solo por la tuya.
