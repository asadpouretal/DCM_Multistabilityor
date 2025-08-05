function tracker = track_free_energy(tracker, L, F)
    % Append current iteration’s L (1x9) and F (scalar) to tracker struct

    if isempty(tracker)
        tracker.L = L(:)';      % Initialise first row
        tracker.F = F;          % Initialise scalar
    else
        tracker.L(end+1, :) = L(:)';
        tracker.F(end+1) = F;
    end
end
