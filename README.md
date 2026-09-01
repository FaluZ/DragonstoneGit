# DragonstoneGit

Hooks de git de código abierto que detectan y bloquean campañas de malware que infectan
proyectos de software a través de repositorios git — inyección de código en archivos de
configuración de build, persistencia vía tareas de VS Code, y otras técnicas por el estilo.

Nació de una campaña real y activa (identificada como **A8-3424-1 / EtherHiding**) que inyecta
código ofuscado en `vite.config.js`, `webpack.mix.js`, `postcss.config.js`,
`tailwind.config.js`, etc., y en `.vscode/tasks.json`, para lograr ejecución automática al
abrir el proyecto en el editor o al correr un build. El objetivo de este repo es que las
firmas y patrones de detección se mantengan actualizados con el tiempo — a medida que
aparecen variantes nuevas o se identifican otras campañas — con aportes de cualquiera que se
tope con algo que valga la pena agregar.

## Instalación (2 minutos, sin dependencias)

1. Descargá o cloná este repo.
2. Copiá las carpetas `.githooks/` y `.github/workflows/security-scan.yml` (opcional, ver
   abajo) a la raíz de tu proyecto.
3. Activá el hook local, una sola vez por clon:

   ```bash
   git config core.hooksPath .githooks
   ```

Listo. No hace falta instalar Python, Node, ni ninguna herramienta extra — son scripts de
shell autocontenidos que solo usan `git`, `grep` y `awk`, ya incluidos en cualquier
instalación de Git (en Windows, Git Bash alcanza).

## Qué hace cada hook

| Hook | Cuándo corre | ¿Bloquea? |
|---|---|---|
| `pre-commit` | Antes de cada commit | **Sí** — aborta el commit si encuentra una firma conocida, una línea anormalmente larga en un archivo de configuración de build, o una tarea `runOn:folderOpen` |
| `post-merge` | Después de `git pull` | No — git no permite bloquear un fast-forward antes de que los archivos toquen disco. Solo alerta en la terminal |
| `post-checkout` | Después de `git clone` / `git checkout <rama>` | No, mismo motivo. Solo alerta |

`.github/workflows/security-scan.yml` es un respaldo opcional que corre el mismo chequeo en
GitHub Actions, del lado del servidor, en cada push/PR — útil para cubrir a quien no tenga el
hook local activado, o lo salte con `--no-verify`. Por defecto solo marca el check en rojo
(no bloquea el push); para que bloquee de verdad hay que combinarlo con "require pull
request" + "required status check" en la protección de rama de tu repo.

## Auditar varios repos locales de una sola vez

Los hooks solo miran lo que acaba de pasar (un commit, un pull, un checkout). Para revisar
de una pasada el estado completo (árbol actual + todo el historial alcanzable) de varios
repos que ya tenés clonados, usá `tools/scan-all.sh`:

```bash
./tools/scan-all.sh /ruta/repo1 /ruta/repo2 /ruta/repo3
# o, para autodetectar cada repo bajo una carpeta:
./tools/scan-all.sh --root /ruta/con/varios/proyectos
```

No hace falta que estos repos tengan `.githooks/` instalado — el script trae su propia copia
de las reglas y corre desde afuera. Termina con código de salida `1` si algún repo tuvo
hallazgos (útil para meterlo en un script de chequeo periódico propio).

## Límites — leé esto antes de confiar ciegamente

Este repo detecta **campañas conocidas**, no malware en general:

- Las **señales estructurales** (línea anormalmente larga en un config de build, tarea oculta
  con `runOn:folderOpen`) son más durables — no dependen de strings exactos, sobreviven a que
  el atacante cambie de ofuscador.
- Los **marcadores literales** (nombres de variables ofuscadas, dominios específicos, nombres
  de archivo) caducan en cuanto aparece una variante nueva — por eso este repo depende de que
  la gente reporte lo que se va encontrando.

No es un antivirus ni reemplaza buenas prácticas de seguridad (revisar dependencias antes de
instalarlas, no correr `npm install` a ciegas, etc.) — es una capa adicional específica contra
estas campañas puntuales.

## Contribuir

¿Encontraste una variante nueva, un falso positivo, o quieres agregar detección para otra
campaña? Ver [CONTRIBUTING.md](CONTRIBUTING.md).

## Licencia

[MIT](LICENSE) — usalo, modificalo, redistribuilo, incluso en proyectos comerciales.
