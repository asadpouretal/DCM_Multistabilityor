function modifyCustomParallelProfile(profileName, numWorkers, matlabRoot, jobStorageLocation)
    % Get the custom profile
    c = parcluster(profileName);
    
    % Modify the properties
    c.NumWorkers = numWorkers;
    c.ClusterMatlabRoot = matlabRoot;
    c.OperatingSystem = 'unix'; % or 'windows', based on your system
    c.JobStorageLocation = jobStorageLocation;
    c.HasSharedFilesystem = true;
    
    % Save the modified profile
    c.saveProfile();
    fprintf('Profile named "%s" has been modified.\n', profileName);
end