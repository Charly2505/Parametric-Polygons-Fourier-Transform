clearvars; clc; close all;

function polygon_gui()
    % Crear la ventana de la interfaz gráfica
    fig = uifigure('Name', 'Generador de Polígonos', 'Position', [100 100 400 300]);

    % Etiqueta y campo de entrada para el número de lados
    uilabel(fig, 'Text', 'Número de lados:', 'Position', [50 230 100 20]);
    ladosInput = uieditfield(fig, 'numeric', 'Position', [180 230 100 20], 'Value', 6, 'Limits', [3 Inf]);

    % Etiqueta y campo de entrada para el ángulo de rotación
    uilabel(fig, 'Text', 'Rotación (°):', 'Position', [50 190 100 20]);
    rotInput = uieditfield(fig, 'numeric', 'Position', [180 190 100 20], 'Value', 30);

    % Etiqueta y campo de entrada para la traslación en X
    uilabel(fig, 'Text', 'Traslación en X:', 'Position', [50 150 100 20]);
    trasXInput = uieditfield(fig, 'numeric', 'Position', [180 150 100 20], 'Value', 1.5);

    % Etiqueta y campo de entrada para la traslación en Y
    uilabel(fig, 'Text', 'Traslación en Y:', 'Position', [50 110 100 20]);
    trasYInput = uieditfield(fig, 'numeric', 'Position', [180 110 100 20], 'Value', -1.0);

    % Botón para generar el polígono
    btn = uibutton(fig, 'Text', 'Generar Polígono', 'Position', [120 50 150 40], ...
                   'ButtonPushedFcn', @(btn,event) plotPolygon(ladosInput.Value, ...
                                                               rotInput.Value, ...
                                                               trasXInput.Value, ...
                                                               trasYInput.Value));
end

% Función para generar y graficar el polígono con los valores ingresados
function plotPolygon(l, theta_deg, x_tras, y_tras)
    % Convertir ángulo a radianes
    theta_rot = deg2rad(theta_deg);

    % Parámetros de la malla
    n = 10;
    N = 2.^n;

    x = linspace(-5,5,N);
    y = linspace(-5,5,N);
    [X,Y] = meshgrid(x,y);

    M = zeros(size(X));

    % Definir el radio del polígono
    r = 0.5;

    % Calcular posiciones originales de los vértices
    theta = 2 * pi * (0:l-1) / l;
    roots_x = r * cos(theta);
    roots_y = r * sin(theta);

    % Aplicar rotación
    rot_x = cos(theta_rot) * roots_x - sin(theta_rot) * roots_y;
    rot_y = sin(theta_rot) * roots_x + cos(theta_rot) * roots_y;

    % Aplicar traslación
    rot_x = rot_x + x_tras;
    rot_y = rot_y + y_tras;

    % Determinar qué puntos están dentro del polígono con inpolygon
    insidePolygon = inpolygon(X, Y, rot_x, rot_y);
    M(:) = 0;
    M(insidePolygon) = 1;

    % Crear la figura y mostrar el polígono
    figure
    pcolor(x,y,M);
    shading interp
    colormap gray
    hold on

    % Dibujar el polígono con los vértices rotados y trasladados
    for i = 1:l
        x1 = rot_x(i);
        y1 = rot_y(i);
        if i < l
            x2 = rot_x(i+1);
            y2 = rot_y(i+1);
        else
            x2 = rot_x(1);
            y2 = rot_y(1);
        end
        plot([x1, x2], [y1, y2], 'r', 'LineWidth', 2);
    end

    % Etiquetas y título
    xlabel('X')
    ylabel('Y')
    title(['Polígono de ', num2str(l), ' lados, rotado ', num2str(theta_deg), '° y trasladado'])
    axis equal
    hold off

    % Transformada de Fourier
    F = fftshift(fft2(M));

    figure
    pcolor(x,y,(abs(F)));
    shading interp
    colormap hot
end
