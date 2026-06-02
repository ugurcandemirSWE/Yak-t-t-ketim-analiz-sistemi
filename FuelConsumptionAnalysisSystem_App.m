classdef FuelConsumptionAnalysisSystem_App < handle
    %FUELCONSUMPTIONANALYSISSYSTEM_APP Desktop GUI for fuel analytics.
    %   Run this app with:
    %   app = FuelConsumptionAnalysisSystem_App;

    properties (Access = private)
        UIFigure matlab.ui.Figure
        DataTable matlab.ui.control.Table
        AdditionalKmField matlab.ui.control.NumericEditField
        CalculateButton matlab.ui.control.Button

        AvgConsumptionValue matlab.ui.control.Label
        AvgCostValue matlab.ui.control.Label
        TotalFuelValue matlab.ui.control.Label
        TotalCostValue matlab.ui.control.Label
        PredictedEndCostValue matlab.ui.control.Label
        PredictedExtraCostValue matlab.ui.control.Label

        ConsumptionAxes matlab.ui.control.UIAxes
        CostAxes matlab.ui.control.UIAxes
    end

    methods
        function app = FuelConsumptionAnalysisSystem_App()
            app.createComponents();
            app.populateDefaultData();
            app.onCalculate();
        end
    end

    methods (Access = private)
        function createComponents(app)
            app.UIFigure = uifigure( ...
                'Name', 'Yakıt Tüketim Analiz Sistemi', ...
                'Position', [100 100 1200 720]);

            % Input table and controls
            uilabel(app.UIFigure, 'Position', [24 675 320 22], 'Text', 'Yolculuk Verileri (Km, Yakıt Litre, Litre Fiyatı)');
            app.DataTable = uitable(app.UIFigure, ...
                'Position', [24 420 500 250], ...
                'ColumnName', {'Km', 'FuelLiters', 'FuelPriceTLPerLiter'}, ...
                'ColumnEditable', [true true true]);

            uilabel(app.UIFigure, 'Position', [24 382 220 22], 'Text', 'Tahmin için Ek Km');
            app.AdditionalKmField = uieditfield(app.UIFigure, 'numeric', ...
                'Position', [250 382 120 22], ...
                'Value', 1500, ...
                'Limits', [1 Inf], ...
                'LowerLimitInclusive', true);

            app.CalculateButton = uibutton(app.UIFigure, 'push', ...
                'Text', 'Hesapla ve Tahmin Et', ...
                'Position', [390 380 134 26], ...
                'ButtonPushedFcn', @(~, ~) app.onCalculate());

            % Metric labels
            panel = uipanel(app.UIFigure, ...
                'Title', 'Sonuçlar', ...
                'Position', [24 190 500 170]);

            uilabel(panel, 'Position', [12 112 220 22], 'Text', 'Ortalama tüketim (L/100km):');
            app.AvgConsumptionValue = uilabel(panel, 'Position', [240 112 240 22], 'Text', '-');

            uilabel(panel, 'Position', [12 84 220 22], 'Text', 'Ortalama maliyet (TL/km):');
            app.AvgCostValue = uilabel(panel, 'Position', [240 84 240 22], 'Text', '-');

            uilabel(panel, 'Position', [12 56 220 22], 'Text', 'Toplam yakıt (L):');
            app.TotalFuelValue = uilabel(panel, 'Position', [240 56 240 22], 'Text', '-');

            uilabel(panel, 'Position', [12 28 220 22], 'Text', 'Toplam yakıt maliyeti (TL):');
            app.TotalCostValue = uilabel(panel, 'Position', [240 28 240 22], 'Text', '-');

            uilabel(panel, 'Position', [12 0 220 22], 'Text', 'Tahmini toplam maliyet (TL):');
            app.PredictedEndCostValue = uilabel(panel, 'Position', [240 0 240 22], 'Text', '-');

            panel2 = uipanel(app.UIFigure, ...
                'Title', 'Tahmin', ...
                'Position', [24 100 500 78]);
            uilabel(panel2, 'Position', [12 24 220 22], 'Text', 'Tahmini ek maliyet (TL):');
            app.PredictedExtraCostValue = uilabel(panel2, 'Position', [240 24 240 22], 'Text', '-');

            % Axes
            app.ConsumptionAxes = uiaxes(app.UIFigure, 'Position', [560 380 610 300]);
            title(app.ConsumptionAxes, 'Mesafeye Göre Yakıt Tüketimi');
            xlabel(app.ConsumptionAxes, 'Mesafe (km)');
            ylabel(app.ConsumptionAxes, 'Tüketim (L/100km)');
            grid(app.ConsumptionAxes, 'on');

            app.CostAxes = uiaxes(app.UIFigure, 'Position', [560 40 610 300]);
            title(app.CostAxes, 'Yakıt Maliyeti Trendi ve Regresyon');
            xlabel(app.CostAxes, 'Mesafe (km)');
            ylabel(app.CostAxes, 'Kümülatif Yakıt Maliyeti (TL)');
            grid(app.CostAxes, 'on');
        end

        function populateDefaultData(app)
            app.DataTable.Data = table( ...
                [100; 250; 400; 600; 800], ...
                [7; 11; 10.5; 14; 13], ...
                [42; 42.5; 43; 43.2; 44], ...
                'VariableNames', {'Km', 'FuelLiters', 'FuelPriceTLPerLiter'});
        end

        function onCalculate(app)
            try
                [distanceKm, fuelLiters, fuelPriceTLPerLiter] = app.readAndValidateTableData();
                futureAdditionalKm = app.AdditionalKmField.Value;
                results = computeFuelConsumption(distanceKm, fuelLiters, fuelPriceTLPerLiter, futureAdditionalKm);
                app.updateMetrics(results);
                app.updateCharts(results);
            catch ME
                uialert(app.UIFigure, ME.message, 'Geçersiz Giriş');
            end
        end

        function [distanceKm, fuelLiters, fuelPriceTLPerLiter] = readAndValidateTableData(app)
            tableData = app.DataTable.Data;
            if isempty(tableData)
                error('Lütfen en az iki veri satırı girin.');
            end

            if istable(tableData)
                requiredColumns = {'Km', 'FuelLiters', 'FuelPriceTLPerLiter'};
                if ~all(ismember(requiredColumns, tableData.Properties.VariableNames))
                    error('Tablo şu sütunları içermelidir: Km, FuelLiters, FuelPriceTLPerLiter.');
                end
                distanceKm = tableData.Km;
                fuelLiters = tableData.FuelLiters;
                fuelPriceTLPerLiter = tableData.FuelPriceTLPerLiter;
                rowCount = height(tableData);
            elseif isnumeric(tableData)
                if size(tableData, 2) < 3
                    error('Sayısal tablo verisi 3 sütun içermelidir: Km, FuelLiters, FuelPriceTLPerLiter.');
                end
                distanceKm = tableData(:, 1);
                fuelLiters = tableData(:, 2);
                fuelPriceTLPerLiter = tableData(:, 3);
                rowCount = size(tableData, 1);
            elseif iscell(tableData)
                if size(tableData, 2) < 3
                    error('Hücre tablo verisi 3 sütun içermelidir: Km, FuelLiters, FuelPriceTLPerLiter.');
                end
                distanceKm = cellfun(@double, tableData(:, 1));
                fuelLiters = cellfun(@double, tableData(:, 2));
                fuelPriceTLPerLiter = cellfun(@double, tableData(:, 3));
                rowCount = size(tableData, 1);
            else
                error('Desteklenmeyen tablo veri biçimi.');
            end

            if rowCount < 2
                error('Lütfen en az iki veri satırı girin.');
            end

            if any(ismissing(distanceKm)) || any(ismissing(fuelLiters)) || any(ismissing(fuelPriceTLPerLiter))
                error('Tabloda eksik değer var.');
            end

            distanceKm = double(distanceKm(:)).';
            fuelLiters = double(fuelLiters(:)).';
            fuelPriceTLPerLiter = double(fuelPriceTLPerLiter(:)).';
        end

        function updateMetrics(app, results)
            app.AvgConsumptionValue.Text = sprintf('%.2f', results.avgConsumptionLper100Km);
            app.AvgCostValue.Text = sprintf('%.4f', results.costTLPerKm);
            app.TotalFuelValue.Text = sprintf('%.2f', results.totalFuelLiters);
            app.TotalCostValue.Text = sprintf('%.2f', results.totalFuelCostTL);
            app.PredictedEndCostValue.Text = sprintf('%.2f TL (%.0f km sonunda)', ...
                results.predictedEndCostTL, results.predictedEndKm);
            app.PredictedExtraCostValue.Text = sprintf('Sonraki %.0f km için %.2f TL', ...
                results.futureAdditionalKm, results.predictedAdditionalCostTL);
        end

        function updateCharts(app, results)
            cla(app.ConsumptionAxes);
            plot(app.ConsumptionAxes, ...
                results.cumulativeDistanceKm, ...
                results.segmentFuelConsumptionLper100Km, ...
                '-o', 'LineWidth', 1.6, 'MarkerSize', 6);
            grid(app.ConsumptionAxes, 'on');

            cla(app.CostAxes);
            plot(app.CostAxes, results.cumulativeDistanceKm, results.cumulativeFuelCostTL, ...
                '-s', 'LineWidth', 1.6, 'MarkerSize', 6);
            hold(app.CostAxes, 'on');
            plot(app.CostAxes, results.fitX, results.fitY, '--', 'LineWidth', 1.4);
            plot(app.CostAxes, results.predictedEndKm, results.predictedPointY, ...
                'rp', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
            hold(app.CostAxes, 'off');
            legend(app.CostAxes, {'Kümülatif Maliyet', 'Lineer Regresyon', 'Tahmin'}, 'Location', 'northwest');
            grid(app.CostAxes, 'on');
        end
    end
end

