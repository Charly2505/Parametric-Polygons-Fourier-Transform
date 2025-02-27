

function polytrian()
    % Crear la ventana de la interfaz gráfica
    fig = uifigure('Name', 'Generador de Polígonos desde Triángulo', 'Position', [100 100 400 300]);

    % Etiqueta y campo de entrada para el número de lados
    uilabel(fig, 'Text', 'Número de lados:', 'Position', [50 230 100 20]);
    ladosInput = uieditfield(fig, 'numeric', 'Position', [180 230 100 20], 'Value', 3, 'Limits', [3 Inf]);

    % Etiqueta y campo de entrada para el ángulo de rotación
    uilabel(fig, 'Text', 'Rotación (°):', 'Position', [50 190 100 20]);
    rotInput = uieditfield(fig, 'numeric', 'Position', [180 190 100 20], 'Value', 0);

    % Etiqueta y campo de entrada para la traslación en X
    uilabel(fig, 'Text', 'Traslación en X:', 'Position', [50 150 100 20]);
    trasXInput = uieditfield(fig, 'numeric', 'Position', [180 150 100 20], 'Value', 0);

    % Etiqueta y campo de entrada para la traslación en Y
    uilabel(fig, 'Text', 'Traslación en Y:', 'Position', [50 110 100 20]);
    trasYInput = uieditfield(fig, 'numeric', 'Position', [180 110 100 20], 'Value', 0);

    % Botón para generar el polígono
    btn = uibutton(fig, 'Text', 'Generar Polígono', 'Position', [120 50 150 40], ...
                   'ButtonPushedFcn', @(btn,event) plotPolygonFromManualTriangle(ladosInput.Value, ...
                                                               rotInput.Value, ...
                                                               trasXInput.Value, ...
                                                               trasYInput.Value));
end

% Función para generar y graficar el polígono desde el triángulo construido manualmente
function plotPolygonFromManualTriangle(l, theta_deg, x_tras, y_tras)
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

    % **Paso 1: Construcción manual del triángulo**
    % Primer vértice (punto inicial en el eje X)
    tri_x(1) = r;
    tri_y(1) = 0;

    % Rotación manual para los otros dos vértices
    angle1 = 2 * pi / 3;  % 120 grados en radianes
    angle2 = 4 * pi / 3;  % 240 grados en radianes

    % Usamos la matriz de rotación para calcular los otros dos vértices
    tri_x(2) = r * cos(angle1);
    tri_y(2) = r * sin(angle1);

    tri_x(3) = r * cos(angle2);
    tri_y(3) = r * sin(angle2);

    % **Paso 2: Construcción del polígono desde el triángulo**
    % Usamos la estructura base del triángulo para construir polígonos de l lados
    poly_x = zeros(1, l);
    poly_y = zeros(1, l);

    for k = 1:l
        angle_k = 2 * pi * (k-1) / l;
        poly_x(k) = r * cos(angle_k);
        poly_y(k) = r * sin(angle_k);
    end

    % Aplicar rotación
    rot_x = cos(theta_rot) * poly_x - sin(theta_rot) * poly_y;
    rot_y = sin(theta_rot) * poly_x + cos(theta_rot) * poly_y;

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

    % Dibujar el triángulo base manual
    % for i = 1:3
    %     x1 = tri_x(i);
    %     y1 = tri_y(i);
    %     if i < 3
    %         x2 = tri_x(i+1);
    %         y2 = tri_y(i+1);
    %     else
    %         x2 = tri_x(1);
    %         y2 = tri_y(1);
    %     end
    %     plot([x1, x2], [y1, y2], 'b', 'LineWidth', 2); % Azul para el triángulo base
    % end

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
        plot([x1, x2], [y1, y2], 'r', 'LineWidth', 2); % Rojo para el polígono final
    end

    % Etiquetas y título
    xlabel('X')
    ylabel('Y')
    title(['Polígono con l=', num2str(l),',θ=',num2str(theta_deg),',x=', num2str(x_tras),',y=',num2str(y_tras)])
    axis equal
    hold off

    % Transformada de Fourier
    F = fftshift(fft2(M));

    figure
    pcolor(x,y,(abs(F)));
    shading interp
    colormap hot
    title(['Patron de Difracción de Polígono con l=', num2str(l),',θ=',num2str(theta_deg),',x=', num2str(x_tras),',y=',num2str(y_tras)])

end
