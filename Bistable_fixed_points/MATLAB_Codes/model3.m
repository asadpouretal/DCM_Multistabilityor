function dX = model3(X, idx, bump1, bump2, noise_amp, tampa, Ae, Ai, ae, ai, cL21, cL12, cLi21, cLi12, c1,c2,c3, c4, c5, c6, c7)
    n1 = bump1(idx);
    n2 = bump2(idx);
    I_eta1_effect = noise_amp * randn();
    I_eta2_effect = noise_amp * randn();

    % Unpack variables from X
    x1 = X(1); x2 = X(2); x3 = X(3); x4 = X(4); x5 = X(5);
    x6 = X(6); x7 = X(7); x8 = X(8); x9 = X(9); x10 = X(10);
    x11 = X(11); x12 = X(12); x13 = X(13); x14 = X(14); x16 = X(15);
    x17 = X(16); x18 = X(17); x19 = X(18); x20 = X(19); x21 = X(20);
    x22 = X(21); x23 = X(22); x24 = X(23); x25 = X(24); x26 = X(25);
    x27 = X(26); x28 = X(27); x29 = X(28); I_eta1 = X(29); I_eta2 = X(30);

    % Sigmoid function
    % Differential equations
    dx1 = x8;
    dx8 = Ae * ae * (c1 * S(x2 - x3 + x7) + cL21 * S(x17 - x18 + x22) + I_eta1 + n1) - 2 * ae * x8 - ae ^ 2 * x1;
    dx2 = x9;
    dx9 = Ae * ae * (c2 * S(x1 + x6)) - 2 * ae * x9 - ae ^ 2 * x2;
    dx3 = x10;
    dx10 = Ai * ai * (c3 * S(x4 - x5)) - 2 * ai * x10 - ai ^ 2 * x3;
    dx4 = x11;
    dx11 = Ae * ae * (cLi21 * S(x17 - x18 + x22) + c4 * S(x2 - x3 + x7) + I_eta1 + n1) - 2 * ae * x11 - ae ^ 2 * x4;
    dx5 = x12;
    dx12 = Ai * ai * (c5 * S(x4 - x5)) - 2 * ai * x12 - ai ^ 2 * x5;
    dx6 = x13;
    dx13 = Ae * ae * (c6 * S(x1 + x6)) - 2 * ae * x13 - ae ^ 2 * x6;
    dx7 = x14;
    dx14 = Ae * ae * (c7 * S(x2 - x3 + x7)) - 2 * ae * x14 - ae ^ 2 * x7;
    dx16 = x23;
    dx23 = Ae * ae * (c1 * S(x17 - x18 + x22) + cL12 * S(x2 - x3 + x7) + I_eta2 + n2) - 2 * ae * x23 - ae ^ 2 * x16;
    dx17 = x24;
    dx24 = Ae * ae * (c2 * S(x16 + x21)) - 2 * ae * x24 - ae ^ 2 * x17;
    dx18 = x25;
    dx25 = Ai * ai * (c3 * S(x19 - x20)) - 2 * ai * x25 - ai ^ 2 * x18;
    dx19 = x26;
    dx26 = Ae * ae * (cLi12 * S(x2 - x3 + x7) + c4 * S(x17 - x18 + x22) + I_eta2 + n2) - 2 * ae * x26 - ae ^ 2 * x19;
    dx20 = x27;
    dx27 = Ai * ai * (c5 * S(x19 - x20)) - 2 * ai * x27 - ai ^ 2 * x20;
    dx21 = x28;
    dx28 = Ae * ae * (c6 * S(x16 + x21)) - 2 * ae * x28 - ae ^ 2 * x21;
    dx22 = x29;
    dx29 = Ae * ae * (c7 * S(x17 - x18 + x22)) - 2 * ae * x29 - ae ^ 2 * x22;

    dI_eta1 = -I_eta1 / tampa + I_eta1_effect / sqrt(tampa);
    dI_eta2 = -I_eta2 / tampa + I_eta2_effect / sqrt(tampa);

    % Update the derivatives
    dX = [dx1, dx2, dx3, dx4, dx5, dx6, dx7, dx8, dx9, dx10, dx11, dx12, dx13, dx14, dx16, dx17, dx18, dx19, dx20, dx21, dx22, dx23, dx24, dx25, dx26, dx27, dx28, dx29, dI_eta1, dI_eta2];
end
