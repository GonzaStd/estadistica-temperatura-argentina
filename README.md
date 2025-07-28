# Instrucciones Copilot - Análisis de Temperaturas Históricas

## Descripción del Proyecto
Este es un proyecto de análisis de datos en Octave/MATLAB para datos históricos de temperatura de Buenos Aires. El script principal (`prueba.m`) procesa datos de temperatura en CSV y genera múltiples visualizaciones para análisis climático.

## Patrones de Arquitectura Clave

### Pipeline de Procesamiento de Datos
El código sigue un pipeline estructurado de 10 pasos en `prueba.m`:
1. **Carga de CSV**: Usa `textscan()` cogitn delimitador punto y coma para formato CSV europeo
2. **Procesamiento de Strings**: Convierte decimales con coma a punto (`strrep(data, ',', '.')`)
3. **Mapeo de Meses**: Convierte nombres de meses en español a índices numéricos (1-12)
4. **Filtrado de Datos**: Usa indexación lógica (`variable(valido)`) para remover valores NaN
5. **Generación de Mapa de Calor**: Crea matriz año×mes para visualización de temperaturas
6. **Análisis Estadístico**: Calcula estadísticas anuales y mensuales de temperatura
7. **Visualización**: Genera tres tipos de gráficos (mapa calor, tendencias mensuales, comparación anual)

### Convenciones de Estructuras de Datos
- **Cell Arrays**: Usar `{}` para tipos de datos mixtos (ej., `data{1}` para años, `data{2}` para nombres de meses)
- **Indexación Lógica**: Filtrar datos con vectores booleanos: `temperaturas(valido)`
- **Manejo de NaN**: Inicializar matrices con `NaN()` y filtrar con `~isnan()`

### Patrones de Visualización
- **Control Consistente de Ticks**: Usar `set(gca, 'XTick', values)` y `set(gca, 'YTick', values)` para etiquetado preciso de ejes
- **Múltiples Gráficos**: Usar `figure;` para crear ventanas separadas, `hold on;` para superponer gráficos
- **Configuración de Colorbar**: Acceder con `cb = colorbar; set(cb, 'YTick', values)`

## Estructura de Archivos
- `historico_temperaturas.csv`: Datos delimitados por punto y coma con formato numérico europeo (decimales con coma)
- `prueba.m`: Script principal de análisis con documentación embebida y procesamiento multi-etapa

## Consideraciones Específicas de Octave
- **Diferencias de Funciones**: Usar `YTick` en lugar de `Ticks` para configuración de colorbar
- **Legend**: Usar ubicaciones específicas (`'northwest'`, `'northeast'`) en lugar de `'best'`
- **Manejo de NaN**: `min()` y `max()` ignoran automáticamente valores NaN
- **Operaciones de Matriz**: Usar `matriz(:)` para vectorizar en operaciones min/max globales

## Expectativas de Formato de Datos
Formato de entrada CSV:
```
anio;mes;máxima;mínima;media
1991;Enero;28,4;19,8;24,1
```
- Separador punto y coma
- Nombres de meses en español
- Notación decimal con coma
- Fila de encabezado presente

## Patrones Comunes de Debugging
- Verificar tipos de datos: cell arrays `{}` vs arrays numéricos `()`
- Verificar filtrado de NaN con operadores lógicos: `~isnan() & ~isnan()`
- Usar `fprintf()` para salida formateada en consola con decimales específicos (`%.2f`)
- Probar operaciones de matriz con datos de muestra pequeños antes del procesamiento completo
