# Cómo contribuir

Gracias por querer aportar. Este es un repo de seguridad — algunas reglas existen
específicamente para que un aporte con buena intención no termine siendo un vector de ataque
en sí mismo.

## Qué es bienvenido

- **Firmas/marcadores nuevos**: strings literales, dominios, nombres de archivo de una
  variante de malware que hayas encontrado y puedas documentar (de dónde salió, en qué
  contexto).
- **Patrones estructurales nuevos**: heurísticas que no dependan de strings exactos (ej. otro
  tipo de archivo de configuración que se use como vector, otro patrón de ofuscación
  detectable estructuralmente).
- **Reducir falsos positivos**: si un patrón existente te bloquea algo legítimo, contalo — con
  el archivo/caso concreto que lo dispara.
- **Mejoras a los tests, la documentación, o el workflow de CI.**

## Qué NO es bienvenido (o va a recibir mucho más escrutinio)

- Cambios a la **lógica de control** de los hooks (qué se ejecuta, en qué orden, condiciones
  de salida) sin una razón clara y bien explicada en el PR. Agregar una firma nueva a una
  lista de strings es un cambio de bajo riesgo; cambiar cómo el script decide qué escanear o
  qué ejecutar es un cambio de alto riesgo.
- Cualquier cosa que haga que el hook **llame a una URL externa**, descargue algo, o ejecute
  un binario que no sea `git`/`grep`/`awk`. Estos hooks son intencionalmente autocontenidos y
  offline — eso es parte de por qué son seguros de instalar.
- Ofuscación en el código del propio hook. Todo tiene que ser legible a simple vista.

## Cómo mandar un cambio

1. Fork de este repo.
2. Rama nueva a partir de `main` (`git checkout -b mi-cambio`).
3. Hacé el cambio. Si agregás una firma o patrón nuevo, agregá también un caso de prueba en
   `tests/fixtures/` (ver `tests/README.md`) — un archivo de ejemplo que dispare la detección,
   y si podés, uno parecido que NO debería dispararla (para verificar que no hay falsos
   positivos).
4. Corré `tests/run-tests.sh` localmente y confirmá que pasa.
5. Abrí un Pull Request contra `main`. En la descripción, contá:
   - Qué detecta el cambio y por qué lo agregaste (de dónde salió el hallazgo, si podés
     compartirlo sin exponer datos sensibles de terceros).
   - Si agregaste tests nuevos.
   - Si el cambio toca la lógica de los hooks (no solo agrega datos/firmas) — decilo
     explícitamente, para que sepamos que necesita más revisión.

## Qué pasa después

- GitHub Actions corre los tests automáticamente en tu PR.
- Reviso el diff completo a mano antes de aprobar nada — no hay merge automático, sin
  excepciones, sea quien sea quien lo mande. Esto no es desconfianza personal: es la política
  para cualquier cambio a una herramienta que se ejecuta automáticamente en la máquina de
  quien la instale.
- Puedo pedir cambios, hacer preguntas, o cerrar el PR si no encaja con el alcance del
  proyecto — con una explicación de por qué.
- Los PRs de primera vez de alguien nuevo requieren aprobación manual antes de que corra CI
  (configuración del repo), para que no se ejecute código no confiable sin que alguien lo
  haya mirado antes.

## Reportar sin abrir un PR

Si encontraste algo pero no tenés tiempo/ganas de armar el PR vos mismo, abrí un
[Issue](../../issues/new/choose) igual — con el detalle que tengas (el string/patrón, dónde lo
viste, cualquier contexto). Lo puedo convertir en un cambio yo.
