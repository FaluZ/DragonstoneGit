## Qué agrega/cambia este PR

<!-- Firma nueva, patron estructural nuevo, fix de falso positivo, etc. -->

## De dónde salió

<!-- Donde encontraste esto: un repo propio infectado, un reporte de otra persona, una
     campaña ya documentada en otro lado... Contexto suficiente para que se pueda verificar. -->

## ¿Toca la lógica de los hooks, o solo agrega datos/firmas?

<!-- Si toca control de flujo, condiciones, o agrega algo que no sea grep/awk sobre archivos
     locales, decilo explicitamente aca -- va a recibir mas revision. -->

## Tests

- [ ] Agregué un caso de prueba en `tests/fixtures/` que dispara la detección nueva
- [ ] Agregué un caso que NO debería dispararla (para verificar que no hay falsos positivos)
- [ ] Corrí `tests/run-tests.sh` localmente y pasa

## Checklist

- [ ] No agrego llamadas de red, ejecución de binarios externos, ni nada fuera de
      `git`/`grep`/`awk`
- [ ] El código es legible, sin ofuscación
