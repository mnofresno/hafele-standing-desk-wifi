# Plan: gabinete OpenSCAD y posicionamiento absoluto

## Objetivo

Agregar al proyecto una fuente paramétrica en OpenSCAD del gabinete actual y rediseñar el firmware para que conozca la altura real del escritorio mediante un sensor de distancia conectado al ESP32, sin perder las funciones existentes ni dejar el control dependiente de una calibración temporal almacenada en NVS.

Este PR es únicamente de planificación. No modifica todavía la geometría final, el cableado del equipo ni el comportamiento de movimiento en producción.

## Estado actual

- La fuente paramétrica existente es `plastic_case/hafele_control_box_with_lid.FCStd` de FreeCAD.
- `plastic_case/control_box.stl` y `plastic_case/control_box_lid.stl` son exportaciones existentes.
- El firmware calcula la posición con velocidad de desplazamiento y tiempo transcurrido en `firmware/MotorDriver.cpp`.
- `CalibrationData.current_position_mm` se persiste en NVS desde `firmware/Calibration.cpp`.
- Los límites actuales son nominales: 725–1220 mm, con margen de 5 mm.
- El build reproducible y los tests nativos están definidos por `firmware/build.sh`.
- Pines ocupados actualmente: relés GPIO32/33, botones GPIO34/35 y encoder GPIO18/19. El bus I2C del OLED debe conservarse.

## Resultado esperado

Al finalizar las tareas:

1. El gabinete tendrá una fuente OpenSCAD paramétrica, reproducible y documentada.
2. Existirán exports STL separados del cuerpo, tapa y soporte del sensor.
3. El sensor tendrá montaje mecánico estable y cableado seguro para el nivel lógico del ESP32.
4. La altura se calculará desde una medición absoluta, no desde la última posición guardada.
5. El firmware rechazará ecos inválidos, lecturas inestables y sensor desconectado.
6. Un reinicio o corte de energía no obligará a repetir la calibración manual de altura.
7. Las memorias M1/M2, movimiento a objetivo, límites, pantalla, Web UI, `/status`, OTA y parada de emergencia seguirán funcionando.
8. El sistema se detendrá ante medición imposible, pérdida de referencia, timeout o contradicción entre movimiento y medición.

## Fases y tareas

### Fase 0 — relevamiento y congelamiento de interfaces

- Confirmar dimensiones reales del `.FCStd` y de ambos STL.
- Identificar orientación, referencia de altura y ubicación posible del sensor.
- Confirmar el pin libre del ESP32 y que no comparta función con relés, botones, encoder, OLED, arranque o flash.
- Medir el rango real del escritorio: posición mínima, máxima y recorrido útil.
- Registrar qué funciones actuales deben conservarse: WiFi, OTA, OLED, encoder, botones, lock, memorias y API.
- Definir una referencia física fija: piso, travesaño o parte estructural que no se mueva con el escritorio.

**Salida:** plano de referencia, pinout aprobado y criterios de medición.

### Fase 1 — reconstrucción paramétrica del gabinete en OpenSCAD

- Modelar cuerpo y tapa a partir del `.FCStd`, STL y renders existentes.
- Exponer parámetros de longitud, ancho, altura, espesores, radios, ángulo del panel, posición del OLED, botones, tornillos, tuercas y holguras.
- Mantener nombres de piezas y puntos de montaje compatibles con el gabinete actual.
- Agregar únicamente el volumen y los anclajes necesarios para el sensor, sin cambiar controles existentes.
- Crear selector de partes: `body`, `lid`, `sensor_mount` y `all`.
- Exportar STL binario reproducible y generar renders de comparación.
- Comparar dimensiones principales y posiciones de interfaces contra FreeCAD/STL.
- Documentar diferencias inevitables cuando la geometría FreeCAD no permita recuperar una operación exacta.

**Criterio de aceptación:** cuerpo y tapa exportan sin warnings críticos, son manifold, encajan visualmente con los renders actuales y preservan los alojamientos del hardware existente.

### Fase 2 — prototipo eléctrico del sensor

- Comenzar con un sensor ultrasónico de 5 V compatible con Arduino, sujeto a validación del entorno.
- Conectar `TRIG` desde un GPIO seguro del ESP32.
- Conectar `ECHO` mediante divisor resistivo o level shifter; nunca aplicar directamente 5 V a un GPIO del ESP32.
- Alimentar el sensor desde una fuente estable y revisar masa común.
- Medir ruido eléctrico con relés apagados y durante ambos sentidos de movimiento.
- Añadir conectores que permitan retirar el sensor sin cortar el cableado original.
- Documentar colores de cable, pin, tensión y punto de referencia.

**Criterio de aceptación:** el circuito funciona sin alterar relés, botones, encoder, OLED, WiFi ni arranque del ESP32; las entradas permanecen dentro de 0–3,3 V.

### Fase 3 — driver de medición y filtrado

- Crear un módulo aislado de lectura del sensor.
- Aplicar timeout por lectura y periodo mínimo entre disparos.
- Rechazar distancias fuera de rango, ecos ausentes y saltos físicamente imposibles.
- Usar mediana/ventana de muestras y filtro suavizado con límites de cambio.
- Exponer estado de medición: `valid`, `stale`, `out_of_range`, `no_echo`, `unstable` y distancia cruda/filtrada.
- Convertir distancia a altura usando una referencia configurable y unidades enteras consistentes.
- Evitar bloquear el loop principal y conservar el watchdog.

**Criterio de aceptación:** las lecturas inválidas no cambian la altura ni activan movimiento; el firmware informa el motivo de invalidación.

### Fase 4 — rediseño del control de movimiento

- Separar `altura medida`, `altura objetivo`, `estado del sensor` y `estado del motor`.
- Reemplazar el avance principal basado en `mm/s × tiempo` por control con realimentación de altura.
- Implementar estados explícitos: `UNKNOWN`, `VALIDATING`, `READY`, `MOVING_UP`, `MOVING_DOWN`, `SENSOR_FAULT`, `STOPPED` y `EMERGENCY_STOP`.
- Permitir movimiento sólo con referencia válida, salvo una rutina de recuperación explícita y segura.
- Detener al alcanzar el objetivo con tolerancia configurable.
- Detener ante sobrepaso, falta de cambio de altura, dirección incorrecta, sensor obstruido, timeout o límite físico.
- Mantener un límite temporal independiente como defensa contra motor trabado o medición congelada.
- No borrar automáticamente la configuración vieja hasta demostrar que el nuevo camino es estable.

**Criterio de aceptación:** después de apagar y encender, el sistema vuelve a informar una altura válida sin que el usuario ajuste manualmente `current_position_mm`.

### Fase 5 — persistencia, UI y API

- Retirar `current_position_mm` como fuente de verdad de la posición.
- Conservar en NVS sólo parámetros que sigan siendo configuración: memorias, referencia geométrica, tolerancias, límites y timeout.
- Añadir al `/status` altura medida, distancia, calidad, estado de referencia y fallo activo.
- Actualizar OLED y menú para mostrar `altura real` y `sensor OK/fallo`.
- Adaptar M1/M2 para guardar y usar alturas medidas.
- Adaptar `/move_to`, `full_up` y `full_down` para respetar el estado de seguridad.
- Mostrar un error accionable cuando el sensor no esté listo.
- Revisar el panel web y sus mensajes para no presentar una posición estimada como absoluta.

**Criterio de aceptación:** UI local, Web UI y JSON muestran la misma altura medida y ningún comando permite ignorar un fallo de seguridad.

### Fase 6 — pruebas y validación física

- Agregar tests nativos del filtro, conversión distancia-altura, estados y condiciones de parada.
- Agregar mocks para ecos válidos, ausencia de eco, ruido, saltos y sensor congelado.
- Ejecutar build con el toolchain Docker fijado por el repo.
- Probar mínimo 20 ciclos completos arriba/abajo.
- Repetir pruebas con reinicio durante reposo y durante movimiento.
- Verificar posiciones M1/M2, objetivo intermedio y parada manual.
- Medir error absoluto contra una regla o instrumento independiente en mínimo, medio y máximo recorrido.
- Probar diferentes superficies, inclinaciones y condiciones de luz/ruido si se mantiene ultrasonido.
- Verificar que el gabinete cerrado no fuerce cables ni obstruya el sensor.

**Criterio de aceptación:** no hay movimiento no comandado, no se pierde la referencia tras reinicio y el error medido queda dentro de la tolerancia acordada antes de reemplazar la calibración existente.

### Fase 7 — entrega y despliegue controlado

- Entregar fuente OpenSCAD, STL, renders y documentación de montaje.
- Entregar esquema de cableado y tabla de pinout.
- Publicar changelog de firmware y procedimiento de rollback.
- Compilar con `bash firmware/build.sh`.
- Desplegar primero por OTA al equipo de prueba.
- Verificar `/status`, versión, altura, estado del sensor y parada antes de habilitar todos los comandos.
- Mantener una ventana de observación y registrar fallos antes de declarar el cambio terminado.

## Archivos previstos

- `cad/` o `plastic_case/`: fuente `.scad`, parámetros, renders y exports STL.
- `README.md`: montaje, pinout, referencia de altura y procedimiento de validación.
- `firmware/DistanceSensor.*`: driver y filtrado.
- `firmware/PositionController.*`: estados y control absoluto.
- `firmware/MotorDriver.*`: integración con realimentación y paradas de seguridad.
- `firmware/Calibration.*`: migración de NVS y configuración no-posicional.
- `firmware/firmware.ino`: wiring, API, menú y ciclo principal.
- `firmware/tests/`: tests de sensor, filtro, conversión y máquina de estados.

## Riesgos y decisiones pendientes

### Sensor

Un HC-SR04 es barato y sirve para prototipar, pero su salida `ECHO` es de 5 V y necesita adaptación de nivel. El piso, alfombra, inclinación, vibración y obstáculos pueden producir ecos erráticos. Si la precisión o estabilidad no alcanza, evaluar un sensor ToF I2C o un sensor industrial antes de cerrar el diseño.

### Referencia mecánica

La medición sólo será absoluta si el sensor mide contra una referencia fija y repetible. Montarlo en el gabinete no alcanza por sí solo: hay que definir si mide al piso, a una estructura fija o a una pieza solidaria con la columna.

### Seguridad

El sensor no reemplaza protecciones eléctricas ni un límite temporal. Una lectura correcta tampoco demuestra por sí sola que el mecanismo pueda moverse libremente; las primeras pruebas deben ser supervisadas y con parada accesible.

### Compatibilidad

No se debe asumir que cualquier GPIO libre es seguro. Se verificará el modelo exacto de placa ESP32 y su comportamiento durante boot antes de soldar o desplegar.

## Estimación correcta para un agente AI

La estimación no se expresa como horas de un desarrollador humano. El agente puede generar y modificar código, CAD, tests y documentación en una sesión mucho más corta. Lo que no puede saltarse es la inspección de la geometría real, el armado eléctrico y la validación física.

### Tiempo activo aproximado del agente

- Inspección de repo, `.FCStd`, STL y pinout: **10–30 min**.
- Primera reconstrucción OpenSCAD, exports y comparación: **30–120 min**.
- Driver de sensor, filtrado y máquina de estados: **60–180 min**.
- Integración con firmware, UI, API y tests: **45–120 min**.
- Build, revisión de errores y preparación del PR/OTA: **20–60 min**.

**Primera implementación completa: aproximadamente 3–8 horas activas del agente**, suponiendo que el hardware, la referencia geométrica y el pin libre estén claros.

### Tiempo externo o no acelerable por el agente

- Comprar o disponer del sensor, resistencias, cables y soporte: depende de disponibilidad.
- Montar el sensor y cablearlo físicamente: **30–90 min**.
- Medir la referencia y ajustar el soporte: **30–120 min**.
- Ejecutar ciclos físicos y observar errores: **1–3 h de pruebas**, distribuidas según las iteraciones necesarias.

El resultado realista es una primera versión funcional el mismo día, más **una o varias rondas de validación física**. Si el HC-SR04 produce ecos inestables o la referencia mecánica no es adecuada, el tiempo adicional no será de “más código”: será cambiar la ubicación, el soporte o el tipo de sensor y repetir las pruebas.

No se debe prometer una duración exacta para la versión final antes de completar la Fase 0 y ver una medición real durante todo el recorrido.

## Fuera de alcance de este plan

- Cambiar relés, fuente, motor o electrónica original sin evidencia de necesidad.
- Rediseñar la placa ESP32 completa.
- Agregar automatización cloud o dependencia de un servidor externo.
- Declarar precisión de laboratorio sin medirla con un instrumento independiente.
- Eliminar watchdogs, límites temporales o parada manual.
- Entregar el equipo como seguro únicamente porque compila o porque el STL es manifold.

## Definición de terminado

El trabajo se considera terminado sólo cuando:

- la fuente OpenSCAD reproduce y exporta el gabinete y sus accesorios;
- el sensor está montado, protegido eléctricamente y documentado;
- el firmware arranca con una altura absoluta válida o queda bloqueado de forma segura;
- el sistema supera tests nativos y ciclos físicos repetidos;
- el reinicio no devuelve el escritorio a una posición inventada;
- Web UI, OLED, memorias, OTA y parada funcionan con la misma fuente de verdad;
- existe evidencia de build, versión desplegada, `/status` y rollback.
