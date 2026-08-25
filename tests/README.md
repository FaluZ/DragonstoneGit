# Tests

`run-tests.sh` corre cada carpeta de `fixtures/should-block/` y `fixtures/should-pass/`
contra el hook `pre-commit` real, en un repo temporal aislado, y verifica que el resultado
sea el esperado (commit bloqueado o permitido).

## Agregar un caso nuevo

1. Creá una carpeta nueva bajo `fixtures/should-block/<nombre-descriptivo>/` (si tu caso
   debería bloquear el commit) o `fixtures/should-pass/<nombre-descriptivo>/` (si no debería
   dispararse nada).
2. Adentro, poné el/los archivo(s) con la ruta relativa exacta que tendrían en un proyecto
   real — por ejemplo, para probar `.vscode/tasks.json`, la carpeta necesita
   `.vscode/tasks.json` adentro, no el archivo suelto.
3. Corré `tests/run-tests.sh` y confirmá que tu caso nuevo aparece y pasa.

## Correr los tests

```bash
bash tests/run-tests.sh
```
