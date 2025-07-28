% Cargar y analizar los datos históricos de temperatura de Buenos Aires
% Autor: Gonzalo
% Fecha: Julio 2025
% Uso: Ejecutar en Octave con el archivo CSV en el mismo directorio
%  Ejemplo:
%   anio;mes;máxima;mínima;media
%   1991;Enero;28,4;19,8;24,1
% 1. Carga del archivo CSV con delimitador ';' y columnas conocidas
filename = 'historico_temperaturas.csv';
fid = fopen(filename, 'r');
if fid == -1
    error('No se pudo abrir el archivo %s', filename);
end

% Asumimos que el archivo tiene encabezado que vamos a saltar
header_line = fgetl(fid);

% Leer columnas: Año (int), Mes (string), TempMáx (string), TempMín (string), TempMedia (string)
data = textscan(fid, '%d %s %s %s %s', 'Delimiter', ';');
fclose(fid);

anios = data{1};              % vector numérico con los años
meses_str = data{2};          % celdas con nombres de meses
temp_max_str = data{3};       % strings de temperatura máxima con coma decimal
temp_min_str = data{4};       % strings de temperatura mínima con coma decimal
temp_med_str = data{5};       % strings de temperatura media con coma decimal

% 2. Convertir coma decimal a punto decimal para poder convertir a número
temp_max_str = strrep(temp_max_str, ',', '.');
temp_min_str = strrep(temp_min_str, ',', '.');
temp_med_str = strrep(temp_med_str, ',', '.');

temp_max = str2double(temp_max_str);
temp_min = str2double(temp_min_str);
temp_med = str2double(temp_med_str);

% 3. Convertir meses de nombre a número (1-12)
meses_nombre = {'Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'};
meses_num = zeros(length(meses_str), 1);
for i = 1:length(meses_str)
    idx = find(strcmp(meses_str{i}, meses_nombre));
    if ~isempty(idx)
        meses_num(i) = idx;
    else
        meses_num(i) = NaN; % Marca mes inválido para filtrar luego
    end
end

% Filtrar posibles filas con mes inválido o temperaturas NaN
valido = ~isnan(meses_num) & ~isnan(temp_med);
anios = anios(valido);
meses_num = meses_num(valido);
temperaturas = temp_med(valido);

% 4. Construir matriz de calor: promedio de temperatura media por mes y año
anios_unicos = unique(anios);
mapa_calor = NaN(length(anios_unicos), 12);

for i = 1:length(anios_unicos)
    for j = 1:12
        idx = anios == anios_unicos(i) & meses_num == j;
        if any(idx)
            mapa_calor(i, j) = mean(temperaturas(idx));
        end
    end
end

% 5. Imprimir matriz de calor en consola
fprintf('\nTemperaturas promedio por año y mes:\n');
fprintf('Año\tMes\tTemperatura media (°C)\n');
for i = 1:length(anios_unicos)
    for j = 1:12
        val = mapa_calor(i,j);
        if ~isnan(val)
            fprintf('%d\t%s\t%.2f\n', anios_unicos(i), meses_nombre{j}, val);
        end
    end
end

% 6. Gráfico de calor
figure;
imagesc(mapa_calor);
cb = colorbar;
% Configurar ticks de la colorbar (temperaturas de 1 en 1 grado)
temp_min_mapa = floor(min(mapa_calor(:)));  % Temperatura mínima redondeada hacia abajo
temp_max_mapa = ceil(max(mapa_calor(:)));   % Temperatura máxima redondeada hacia arriba
set(cb, 'YTick', temp_min_mapa:1:temp_max_mapa);           % De 1 en 1 grado
xlabel('Mes'); ylabel('Año');
title('Mapa de calor de temperaturas promedio por mes');
set(gca, 'XTick', 1:12, 'XTickLabel', meses_nombre, 'XTickLabelRotation', 45);
set(gca, 'YTick', 1:length(anios_unicos), 'YTickLabel', cellstr(num2str(anios_unicos)));

% 7. Estadísticas generales
media_temp = mean(temperaturas);
max_temp = max(temperaturas);
min_temp = min(temperaturas);
std_temp = std(temperaturas);

% 8. Gráfico de estadísticas mensuales (usando todos los años juntos)
temp_prom_mes = NaN(1,12);
temp_max_mes = NaN(1,12);
temp_min_mes = NaN(1,12);

for m = 1:12
    idx = meses_num == m;
    if any(idx)
        temp_prom_mes(m) = mean(temperaturas(idx));
        temp_max_mes(m) = max(temperaturas(idx));
        temp_min_mes(m) = min(temperaturas(idx));
    end
end

figure;
plot(1:12, temp_prom_mes, '-o', 'DisplayName', 'Promedio'); hold on;
plot(1:12, temp_max_mes, '-r*', 'DisplayName', 'Máxima');
plot(1:12, temp_min_mes, '-bs', 'DisplayName', 'Mínima');
legend('Location','northwest');
xlabel('Mes'); ylabel('Temperatura (°C)');
title('Estadísticas de temperatura por mes');
set(gca, 'XTick', 1:12)
set(gca, 'YTick', floor(min_temp):1:ceil(max_temp))
grid on;

% 9. Análisis por año para comparar cuáles fueron más calurosos
temp_promedio_anual = NaN(length(anios_unicos), 1);
for i = 1:length(anios_unicos)
    idx = anios == anios_unicos(i);
    if any(idx)
        temp_promedio_anual(i) = mean(temperaturas(idx));
    end
end

% Gráfico de temperatura promedio por año
figure;
plot(anios_unicos, temp_promedio_anual, '-o', 'LineWidth', 2);
xlabel('Año'); ylabel('Temperatura promedio anual (°C)');
title('Temperatura promedio anual - Comparación entre años');
set(gca, 'XTick', anios_unicos);  % Mostrar todos los años, uno por uno
% Configurar ticks principales (enteros) y menores (decimales)
y_min = floor(min(temp_promedio_anual));
y_max = ceil(max(temp_promedio_anual));
set(gca, 'YTick', y_min:1:y_max);                    % Ticks principales cada 1°C
set(gca, 'YMinorTick', 'on');                        % Activar ticks menores
set(gca, 'YTickMode', 'manual');                     % Mantener configuración manual
grid on;

% Encontrar los años más calurosos y más fríos
[temp_max_anual, idx_max] = max(temp_promedio_anual);
[temp_min_anual, idx_min] = min(temp_promedio_anual);
anio_mas_caluroso = anios_unicos(idx_max);
anio_mas_frio = anios_unicos(idx_min);

% 10. Imprimir resumen en consola
fprintf('\n=== RESUMEN GENERAL ===\n');
fprintf('Media anual de temperatura: %.2f °C\n', media_temp);
fprintf('Temperatura máxima registrada: %.2f °C\n', max_temp);
fprintf('Temperatura mínima registrada: %.2f °C\n', min_temp);
fprintf('Desviación estándar: %.2f °C\n', std_temp);

fprintf('\n=== COMPARACIÓN ENTRE AÑOS ===\n');
fprintf('Año más caluroso: %d (%.2f °C promedio)\n', anio_mas_caluroso, temp_max_anual);
fprintf('Año más frío: %d (%.2f °C promedio)\n', anio_mas_frio, temp_min_anual);
fprintf('Diferencia entre el año más caluroso y más frío: %.2f °C\n', temp_max_anual - temp_min_anual);

