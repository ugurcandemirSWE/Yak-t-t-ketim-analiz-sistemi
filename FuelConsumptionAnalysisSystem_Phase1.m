%% Fuel Consumption Analysis System - Phase 1 (Script)
% This script demonstrates basic fuel consumption calculations, plotting,
% and a simple linear regression prediction using polyfit/polyval.
%
% Mock data is used for an end-to-end working example that can later be
% connected to an App Designer UI.

clear; clc; close all;

%% Mock dataset (example: last 5 trips/refuels)
distanceKm = [100, 250, 400, 600, 800];
fuelLiters = [7, 11, 10.5, 14, 13];
fuelPriceTLPerLiter = [42, 42.5, 43, 43.2, 44];

%% Core calculations using shared compute function
futureAdditionalKm = getFutureAdditionalKm();
results = computeFuelConsumption(distanceKm, fuelLiters, fuelPriceTLPerLiter, futureAdditionalKm);

% Display summary metrics in command window
fprintf('--- Fuel & Cost Summary (Mock Data) ---\n');
fprintf('Total distance: %.2f km\n', results.totalDistance);
fprintf('Total fuel: %.2f L\n', results.totalFuelLiters);
fprintf('Total fuel cost: %.2f TL\n', results.totalFuelCostTL);
fprintf('Avg consumption: %.2f L/100km\n', results.avgConsumptionLper100Km);
fprintf('Avg cost: %.4f TL/km\n', results.costTLPerKm);

fprintf('\n--- Prediction (Simple Linear Regression) ---\n');
fprintf('Additional distance requested: %.0f km\n', futureAdditionalKm);
fprintf('Estimated cost at %.0f km (TL): %.2f\n', results.predictedEndKm, results.predictedEndCostTL);
fprintf('Estimated additional cost for next %.0f km (TL): %.2f\n', futureAdditionalKm, results.predictedAdditionalCostTL);

%% Plotting (single figure, two subplots)

figure('Color', 'w', 'Name', 'Fuel Consumption Analysis - Phase 1');
subplot(2, 1, 1);
plot(results.cumulativeDistanceKm, results.segmentFuelConsumptionLper100Km, '-o', 'LineWidth', 1.5);
grid on;
xlabel('Toplam Mesafe (km)');
ylabel('Tuketim (L/100km)');
title('Kilometreye Gore Yakit Tuketimi (Segment Bazli)');

subplot(2, 1, 2);
plot(results.cumulativeDistanceKm, results.cumulativeFuelCostTL, '-s', 'LineWidth', 1.5, 'MarkerSize', 7);
hold on;
plot(results.fitX, results.fitY, '--', 'LineWidth', 1.5);
plot(results.predictedEndKm, results.predictedEndCostTL, 'rp', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
grid on;
xlabel('Toplam Mesafe (km)');
ylabel('Kumulatif Yakit Maliyeti (TL)');
title('Mesafeye Gore Yakit Maliyeti Degisimi + Regresyon Tahmini');
legend({'Kumulatif Maliyet', 'Lineer Regresyon', 'Tahmin Noktasi'}, 'Location', 'northwest');

%% Local function
function additionalKm = getFutureAdditionalKm()
    % Prompts the user for "additional kilometers" to predict.
    defaultAdditionalKm = 1500;
    userValue = input(sprintf('Gelecekte kac km icin tahmin edilsin? (default %d): ', defaultAdditionalKm));

    if isempty(userValue)
        additionalKm = defaultAdditionalKm;
    else
        additionalKm = userValue;
    end

    if ~isnumeric(additionalKm) || ~isscalar(additionalKm) || additionalKm <= 0
        error('Additional kilometers must be a positive numeric scalar.');
    end
end

