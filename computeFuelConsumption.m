function results = computeFuelConsumption(distanceKm, fuelLiters, fuelPriceTLPerLiter, futureAdditionalKm)
%COMPUTEFUELCONSUMPTION Core analytics for fuel consumption and cost.
%   RESULTS = COMPUTEFUELCONSUMPTION(DISTANCEKM, FUELLITERS, FUELPRICETLPERLITER, FUTUREADDITIONALKM)
%   validates inputs, computes summary metrics, and prepares plotting/
%   regression outputs used by both script and desktop GUI.

    validateattributes(distanceKm, {'numeric'}, {'vector', 'real', 'finite', 'positive'}, mfilename, 'distanceKm');
    validateattributes(fuelLiters, {'numeric'}, {'vector', 'real', 'finite', 'nonnegative'}, mfilename, 'fuelLiters');
    validateattributes(fuelPriceTLPerLiter, {'numeric'}, {'vector', 'real', 'finite', 'nonnegative'}, mfilename, 'fuelPriceTLPerLiter');
    validateattributes(futureAdditionalKm, {'numeric'}, {'scalar', 'real', 'finite', 'positive'}, mfilename, 'futureAdditionalKm');

    n = numel(distanceKm);
    if numel(fuelLiters) ~= n || numel(fuelPriceTLPerLiter) ~= n
        error('distanceKm, fuelLiters, and fuelPriceTLPerLiter must have equal length.');
    end
    if n < 2
        error('At least two rows are required for regression.');
    end

    distanceKm = distanceKm(:).';
    fuelLiters = fuelLiters(:).';
    fuelPriceTLPerLiter = fuelPriceTLPerLiter(:).';

    % Detect whether input Km is already cumulative odometer data.
    % If so, use interval distances for consumption calculations, but keep
    % the original Km values on the X-axis to avoid double cumulative sums.
    isCumulativeKm = all(diff(distanceKm) > 0);
    if isCumulativeKm
        intervalDistanceKm = [distanceKm(1), diff(distanceKm)];
        xDistanceKm = distanceKm;
    else
        intervalDistanceKm = distanceKm;
        xDistanceKm = cumsum(distanceKm);
    end

    segmentFuelConsumptionLper100Km = (fuelLiters ./ intervalDistanceKm) * 100;
    segmentFuelCostTL = fuelLiters .* fuelPriceTLPerLiter;

    totalDistance = sum(intervalDistanceKm);
    totalFuelLiters = sum(fuelLiters);
    totalFuelCostTL = sum(segmentFuelCostTL);
    avgConsumptionLper100Km = (totalFuelLiters / totalDistance) * 100;
    costTLPerKm = totalFuelCostTL / totalDistance;

    cumulativeDistanceKm = xDistanceKm;
    cumulativeFuelCostTL = cumsum(segmentFuelCostTL);

    regressionCoeffs = polyfit(cumulativeDistanceKm, cumulativeFuelCostTL, 1);
    lastCumulativeKm = cumulativeDistanceKm(end);
    lastCumulativeCostTL = cumulativeFuelCostTL(end);
    predictedEndKm = lastCumulativeKm + futureAdditionalKm;
    predictedEndCostTL = polyval(regressionCoeffs, predictedEndKm);
    % Keep prediction marker exactly on the regression line.
    predictedPointY = predictedEndCostTL;
    predictedAdditionalCostTL = predictedEndCostTL - lastCumulativeCostTL;

    fitX = linspace(min(cumulativeDistanceKm), predictedEndKm, 200);
    fitY = polyval(regressionCoeffs, fitX);

    results = struct( ...
        'segmentFuelConsumptionLper100Km', segmentFuelConsumptionLper100Km, ...
        'segmentFuelCostTL', segmentFuelCostTL, ...
        'totalDistance', totalDistance, ...
        'totalFuelLiters', totalFuelLiters, ...
        'totalFuelCostTL', totalFuelCostTL, ...
        'avgConsumptionLper100Km', avgConsumptionLper100Km, ...
        'costTLPerKm', costTLPerKm, ...
        'cumulativeDistanceKm', cumulativeDistanceKm, ...
        'cumulativeFuelCostTL', cumulativeFuelCostTL, ...
        'regressionCoeffs', regressionCoeffs, ...
        'futureAdditionalKm', futureAdditionalKm, ...
        'predictedEndKm', predictedEndKm, ...
        'predictedEndCostTL', predictedEndCostTL, ...
        'predictedPointY', predictedPointY, ...
        'predictedAdditionalCostTL', predictedAdditionalCostTL, ...
        'fitX', fitX, ...
        'fitY', fitY);
end

