function s = S(x)
    r1 = 2;
    r2 = 1;
    s = 1 ./ (1 + exp(-r1 * (x - r2))) - 1 ./ (1 + exp(r1 * r2));
end