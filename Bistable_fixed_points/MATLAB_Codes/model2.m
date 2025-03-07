function dX = model2(X, idx, bump1, bump2, noise_amp, tampa, Ae, Ai, a1e, a1i, cL21, cL12, cLi21, cLi12, c3, c4, c5, c7)
    n1 = bump1(idx);
    n2 = bump2(idx);
    I_eta1_effect = noise_amp * randn();
    I_eta2_effect = noise_amp * randn();

    % Unpack variables
    x2 = X(1); x3 = X(2); x4 = X(3); x5 = X(4); x7 = X(5);
    x17 = X(6); x18 = X(7); x19 = X(8); x20 = X(9); x22 = X(10);
    x9 = X(11); x10 = X(12); x11 = X(13); x12 = X(14); x14 = X(15);
    x24 = X(16); x25 = X(17); x26 = X(18); x27 = X(19); x29 = X(20);
    I_eta1 = X(21); I_eta2 = X(22);

    % Differential equations
    dx2 = x9;
    dx9 = Ae * a1e * (cL21 * S(x17 - x18 + x22) + I_eta1 + n1) - 2 * a1e * x9 - a1e ^ 2 * x2;
    dx3 = x10;
    dx10 = Ai * a1i * c3 * S(x4 - x5) - 2 * a1i * x10 - a1i ^ 2 * x3;
    dx4 = x11;
    dx11 = Ae * a1e * (cLi21 * S(x17 - x18 + x22) + c4 * S(x2 - x3 + x7) + I_eta1 + n1) - 2 * a1e * x11 - a1e ^ 2 * x4;
    dx5 = x12;
    dx12 = Ai * a1i * c5 * S(x4 - x5) - 2 * a1i * x12 - a1i ^ 2 * x5;
    dx7 = x14;
    dx14 = Ae * a1e * c7 * S(x2 - x3 + x7) - 2 * a1e * x14 - a1e ^ 2 * x7;
    dx17 = x24;
    dx24 = Ae * a1e * (cL12 * S(x2 - x3 + x7) + I_eta2 + n2) - 2 * a1e * x24 - a1e ^ 2 * x17;
    dx18 = x25;
    dx25 = Ai * a1i * c3 * S(x19 - x20) - 2 * a1i * x25 - a1i ^ 2 * x18;
    dx19 = x26;
    dx26 = Ae * a1e * (cLi12 * S(x2 - x3 + x7) + c4 * S(x17 - x18 + x22) + I_eta2 + n2) - 2 * a1e * x26 - a1e ^ 2 * x19;
    dx20 = x27;
    dx27 = Ai * a1i * c5 * S(x19 - x20) - 2 * a1i * x27 - a1i ^ 2 * x20;
    dx22 = x29;
    dx29 = Ae * a1e * c7 * S(x17 - x18 + x22) - 2 * a1e * x29 - a1e ^ 2 * x22;
    dI_eta1 = -I_eta1 / tampa + I_eta1_effect / sqrt(tampa);
    dI_eta2 = -I_eta2 / tampa + I_eta2_effect / sqrt(tampa);
    % Update the derivatives
    dX = [dx2, dx3, dx4, dx5, dx7, dx17, dx18, dx19, dx20, dx22, dx9, dx10, dx11, dx12, dx14, dx24, dx25, dx26, dx27, dx29, dI_eta1, dI_eta2];
end
