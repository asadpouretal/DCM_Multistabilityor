function safe_save(full_base_path, variable)
    % Saves a variable to a .mat file without overwriting existing files
    % full_base_path: full path without .mat, e.g., '/path/to/F_tracker'
    % variable: the variable to save, saved with the same name

    [folder, base_name, ~] = fileparts(full_base_path);

    if isempty(folder)
        folder = pwd; % default to current working directory
    end

    % Ensure folder exists
    if ~exist(folder, 'dir')
        mkdir(folder);
    end

    idx = 0;
    filename = fullfile(folder, [base_name, '.mat']);

    % Add suffix if file already exists
    while exist(filename, 'file')
        idx = idx + 1;
        filename = fullfile(folder, sprintf('%s_%d.mat', base_name, idx));
    end

    % Save using dynamic fieldname
    s.(base_name) = variable;
    save(filename, '-struct', 's');

    fprintf('Saved free energy tracker to: %s\n', filename);
end
