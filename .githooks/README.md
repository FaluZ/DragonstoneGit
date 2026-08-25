## Hook de seguridad — detección del implante "A8-3424-1" (campaña EtherHiding)

Detecta una campaña de malware activa contra desarrolladores que inyecta código ofuscado en
archivos de configuración de build (`vite.config.js`, `webpack.mix.js`, `postcss.config.js`,
`tailwind.config.js`, etc.) y en `.vscode/tasks.json` para lograr ejecución automática al
abrir el proyecto o al hacer build.

### Instalación (una sola vez por clon)

1. Copiá las carpetas `.githooks/` (y `.github/workflows/security-scan.yml`, opcional) a la
   raíz de tu repositorio.
2. Activá el hook local:

   ```
   git config core.hooksPath .githooks
   ```

Listo. No requiere instalar nada más (ni Python, ni Node, ni ninguna dependencia): son
scripts de shell autocontenidos, solo necesitan `git`, `grep` y `awk` — ya incluidos en
cualquier instalación de Git (Git Bash en Windows también sirve).

### Qué hace cada hook

| Hook | Cuándo corre | ¿Bloquea? |
|---|---|---|
| `pre-commit` | Antes de cada commit | **Sí** — aborta el commit si encuentra una firma conocida del implante, una línea anormalmente larga en un config de build, o una tarea `runOn:folderOpen` |
| `post-merge` | Después de `git pull` | No — git no permite bloquear un fast-forward antes de que los archivos toquen disco. Solo alerta en la terminal |
| `post-checkout` | Después de `git clone` / `git checkout <rama>` | No, mismo motivo. Solo alerta |

Si estás seguro de que un hallazgo es un falso positivo, `git commit --no-verify` salta el
`pre-commit` (no recomendado sin revisar primero).

### `.github/workflows/security-scan.yml` (opcional, respaldo en GitHub Actions)

Corre el mismo chequeo en cada push/PR, del lado del servidor. Útil como respaldo para
cubrir a quien no tenga el hook local activado, o lo salte con `--no-verify` — pero **no
bloquea el push por sí solo** (solo marca el check en rojo), a menos que además configures
"require pull request" + "required status check" en la protección de rama del repo.

### Límites — leer esto antes de confiar ciegamente

Este set de reglas detecta **una campaña específica y conocida** (marcadores literales +
patrones estructurales vistos en incidentes reales), no malware en general. Los atacantes
cambian de ofuscador con el tiempo, así que:

- Las **señales estructurales** (línea anormalmente larga en un config de build, tarea oculta
  con `runOn:folderOpen`) son más durables — no dependen de strings exactos.
- Los **marcadores literales** (nombres de variables ofuscadas, dominios de RPC de Ethereum,
  nombres de archivo específicos) van a caducar en cuanto aparezca una variante nueva.

No es un antivirus ni un reemplazo de buenas prácticas (revisar dependencias, no correr
`npm install` sin mirar qué se instala, etc.) — es una capa adicional específica contra esta
campaña puntual.
