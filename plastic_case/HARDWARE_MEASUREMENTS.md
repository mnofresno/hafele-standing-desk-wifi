# Medidas físicas comunicadas por el usuario

Registro de la iteración del **26 de octubre de 2026**. El inventario legible por
herramientas está en [hardware_measurements.json](hardware_measurements.json).
Estas medidas reemplazan las dimensiones candidatas de catálogo únicamente en
los aspectos que el usuario efectivamente midió. No identifican por sí solas el
modelo comercial de cada componente.

Las descripciones de este registro son transcripciones del informe recibido del
agente principal, no citas textuales inventadas del usuario. Se conserva cada
ambigüedad para evitar convertirla en una decisión geométrica silenciosa.

## Procedencia

| Etiqueta del JSON | Significado |
|---|---|
| `user_measured` | Medida física informada por el usuario; el agente no afirma haberla medido independientemente. |
| `user_reported_hardware` | Tipo, tamaño nominal disponible o preferencia del usuario. |
| `user_requirement` | Comportamiento o decisión de diseño solicitada. |
| `source_geometry` | Coordenada conservada del CAD original, sin nueva medición física. |
| `derived` | Resultado aritmético con sus entradas explícitas. |
| `design_choice` | Decisión dimensional del diseño CAD; no es una medida física tomada por el usuario. |
| `cad_validation` | Resultado numérico de geometría/clearance comunicado durante esta iteración; no es una medición física del usuario. |
| `unconfirmed` | Dato ausente, incompatible o con referencia/orientación sin aclarar. |

Todas las cotas dimensionales de abajo están en milímetros.

## Pasacable del motor

| Dato | Valor y procedencia |
|---|---|
| Cuello: ancho × alto | **8,5 × 10,5**, medido por el usuario. |
| Ranura que recibe la pared | **2,5**, medido por el usuario. |
| Apertura del gabinete | Requisito: **abierta hacia arriba y al ras de la unión con la tapa**. |

Las cotas 8,5 × 10,5 describen la envolvente del cuello; no son un diámetro
circular. El perfil de sus esquinas y el margen de impresión no fueron
informados. Los 2,5 corresponden a la ranura de alojamiento de la pared; no deben
usarse como diámetro del cuello.

## Pulsador táctil

La huella informada es **12 × 12** y la **altura total sin presionar es 5**.
El usuario no dio la altura del cuerpo solo. Tampoco están confirmados el
recorrido de actuación ni el espacio de terminales y soldadura. El CAD no debe
usar 5 como altura exclusiva del cuerpo ni derivar el recorrido a partir de ese
dato.

## Módulo OLED

| Dato | Valor y procedencia |
|---|---|
| PCB: ancho × alto | **27,5 × 28**, medido. |
| Profundidad total del módulo | **3,5**, medida; no equivale al espesor del laminado PCB. |
| Ventana visible solicitada | **27 × 14,5**, requisito a conservar. |
| Margen inferior hasta el área visible | **9**, informado; referencia/eje pendiente de confirmar. |
| Margen superior hasta el área visible | **aproximadamente 7**, informado. |
| Extensión con Dupont conectado | **15 hacia atrás, NORMAL al PCB**, hasta el exterior del plástico del conector, **sin curva del cable**. Dirección aclarada por el usuario. |

Los márgenes no son compatibles todavía con el alto declarado: si ambos fueran
márgenes verticales respecto de la ventana de 14,5, sumarían
**9 + aproximadamente 7 + 14,5 = aproximadamente 30,5**, frente a un PCB de 28.
La diferencia derivada es aproximadamente 2,5. Debe aclararse la referencia de
esas medidas para ubicar la ventana; se mantiene su tamaño **27 × 14,5**.

Los **15 son una extensión hacia atrás sobre la normal del PCB**, no una
prolongación en su plano. La posición específica del header sobre el PCB no fue
informada. El espacio para doblar el cable se suma por separado y aún no tiene
una medida confirmada.

## Módulo del encoder

| Dato | Valor y procedencia |
|---|---|
| PCB: largo × ancho | **26 × 18,5**, medido. |
| Dupont conectado más allá del borde PCB | **11,5**, medido, **en el plano del PCB a lo largo de la dirección de 26**, mediante el conector a **90°**. |
| Eje desde el extremo sin conector | **10,5**, medido a lo largo de la dirección de 26. |
| Eje desde el extremo opuesto | **15,5**, derivado de 26 − 10,5, suponiendo extremos opuestos. |
| Distancias transversales del eje a los bordes | **aproximadamente 8 de un lado y 10 del otro**; no se identificó qué lado corresponde a cada valor. |
| Profundidad instalada | **8**, desde la **cara INTERIOR del gabinete hasta la punta de soldadura más profunda**. |
| Plano de la cara plana/contacto del PCB | **6,2**, desde la misma cara interior del gabinete, confirmado por el usuario. |
| Saliente de soldadura desde la cara plana PCB | **1,8**, derivado de las medidas **8 − 6,2** con la misma referencia. Reemplaza el margen supuesto anterior de 0,6. |

Los valores transversales son aproximados y suman 18, frente al ancho informado
de 18,5. No justifican centrar el eje ni elegir en silencio qué borde recibe el
margen de 8. La extensión del plástico Dupont no incluye un radio de curva
confirmado para el cable. La aclaración del usuario fija el plano de contacto del
PCB a **6,2 desde la cara interior**, y los **8 hasta la soldadura** dejan un
saliente derivado de **1,8**. Estas cotas no son el espesor del laminado ni la
altura exclusiva del cuerpo mecánico. La huella del PCB ya no puede
representarse mediante el tamaño supuesto de un encoder EC11 suelto.

## Tornillos e insertos

| Hardware | Dato comunicado |
|---|---|
| M3 | Cabeza **avellanada**; largos nominales disponibles **10, 12, 15, 20 y 25**. Se prefiere **15**. |
| Insertos de latón M3 | **Diámetro exterior y largo aún no informados**. Los valores anteriores del CAD son supuestos, no medidas confirmadas. |
| Parker / autorroscante | Cabeza **Ø7** y largo informado **15**. Diámetro de rosca y paso no especificados; no se aclaró si el largo incluye la cabeza. |
| Madera del escritorio | Espesor no informado. |

La cabeza M3 avellanada aún no tiene diámetro ni ángulo medidos. La preferencia
por un tornillo de 15 no demuestra su enganche útil en el inserto, porque faltan
las dimensiones de ese inserto y el paquete final de material.

Los centros originales de montaje al escritorio se conservan en **X=0,
Y=−83 y Y=+83**. Proceden del CAD fuente, no de una nueva medición del usuario.
Su separación **166** es una derivación de esas coordenadas. El diámetro de
cabeza Parker no es motivo para mover los centros. Sin el espesor de madera no
se puede calcular la penetración admisible del tornillo.

## Exactamente dos conjuntos de placas

| Conjunto físico | Envolvente comunicada |
|---|---|
| Fuente switching | **54 × 24**, altura máxima total **17**, incluyendo soldaduras. |
| ESP32 y relays sobre la misma protoboard | **50 × 100**, altura máxima total **21 en el relay**, incluyendo soldaduras. |

El ESP32 y los relays comparten una placa/conjunto; no son dos conjuntos que
necesiten montajes independientes. Con la fuente hay **dos**, no tres.
El usuario aclaró que ambas alturas máximas **ya incluyen las soldaduras**.
En el conjunto ESP32 + relays se contempla además la envolvente inferior de
soldadura y wire-wrap. Las dimensiones de terminales conectados, extracción de
conectores y curvas de cables requieren su espacio propio; no están incluidas
automáticamente por conocer las alturas máximas de las placas.

En el conjunto ESP32 + relays:

- El conector es **micro USB**, con altura del receptáculo informada de **3,5**.
- Su posición está informada como **aproximadamente 18 por encima del punto más
  bajo del conjunto completo**, incluyendo soldadura y wire-wrap por debajo.
- No se indicó si esos 18 llegan al **centro o a la parte inferior** del
  receptáculo. Ese dato no fija todavía el centro de la abertura USB del CAD.
- Faltan las dimensiones del plástico del cable USB, su corredor de inserción y
  el espacio para doblarlo.

## Extensión trasera del gabinete: decisión de diseño

Se registra una **extensión hacia atrás de 25 mm** como decisión del diseño CAD.
La propuesta anterior de 20 fue descartada al informar un solapamiento de
aproximadamente **68,1 mm³** entre la envolvente de una placa y la envolvente de
conector/curva de cable OLED. Se eligieron 25 para despejar esa ruta; el margen
de aproximadamente 2,4 mm es una estimación de diseño, no una medida física ni
una cota mínima certificada.

**Los 25 no son una medida física tomada por el usuario**. La extensión conserva
las posiciones originales de los controles frontales y los centros de montaje
al escritorio **X=0, Y=−83 y Y=+83**. Esos centros no se desplazan al ampliar el
gabinete.

## Supuestos anteriores reemplazados y datos pendientes

El PCB OLED supuesto de **35,4 × 33,5** se reemplaza por **27,5 × 28**; su
profundidad total medida es 3,5. El montaje del módulo encoder debe contemplar
el PCB **26 × 18,5** y su conector, en vez de usar el cuerpo EC11 supuesto como
envolvente completa. El inventario anterior de tres placas se reemplaza por los
dos conjuntos físicos descriptos arriba.

Las direcciones de extensión Dupont ya están aclaradas: **OLED normal hacia
atrás; encoder en el plano, a lo largo de los 26 mm**. Siguen pendientes sus
curvas de cable, los márgenes compatibles de la ventana OLED, los lados de
referencia transversal del eje del encoder, la altura del cuerpo del pulsador,
las dimensiones de los insertos, la referencia
vertical del USB y el espesor de la madera. Ninguno debe recibir la etiqueta de
medida confirmada hasta resolverlo.
