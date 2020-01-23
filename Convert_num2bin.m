clc;
%%% Convert Number to Binary
x = -0.1234;
x_hex = num2hex(x)
x_dec = hex2dec(x_hex)
x_bin = de2bi(x_dec)

%%% Convert Binary to Number
x_dec = bi2de(x_bin)
x_hex = dec2hex(x_dec)
x = hex2num(x_hex)


