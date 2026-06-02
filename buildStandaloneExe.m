function buildStandaloneExe()
%BUILDSTANDALONEEXE Build Windows standalone EXE (R2026a).
% Run this from MATLAB in project folder:
%   buildStandaloneExe
%
% Output installer and binaries are created under:
%   ./dist/FuelConsumptionAnalysisSystem

    projectRoot = fileparts(mfilename('fullpath'));
    outputRoot = fullfile(projectRoot, 'dist', 'FuelConsumptionAnalysisSystem');
    if ~exist(outputRoot, 'dir')
        mkdir(outputRoot);
    end

    mainFile = fullfile(projectRoot, 'runFuelConsumptionApp.m');
    extraFiles = {
        fullfile(projectRoot, 'FuelConsumptionAnalysisSystem_App.m')
        fullfile(projectRoot, 'computeFuelConsumption.m')
    };

    fprintf('Building standalone application...\n');
    buildResults = compiler.build.standaloneApplication( ...
        mainFile, ...
        'ExecutableName', 'FuelConsumptionAnalysisSystem', ...
        'OutputDir', outputRoot, ...
        'AdditionalFiles', extraFiles, ...
        'TreatInputsAsNumeric', false);

    fprintf('\nBuild completed.\n');
    fprintf('Executable: %s\n', buildResults.Executable);
    fprintf('Installer:  %s\n', buildResults.Installer);
    fprintf('Output dir: %s\n', outputRoot);
end

