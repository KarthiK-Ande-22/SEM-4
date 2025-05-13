function symbol = fourpammap(bit1, bit2)
    % Combine the two bits into a decimal number
    decimal = bit1 * 2 + bit2;

    % Gray coding mapping
    switch decimal
        case 0
            symbol = -3;
        case 1
            symbol = -1;
        case 3
            symbol = +1;
        case 2
            symbol = +3;
        otherwise
            error('Invalid bits. Must be 0 or 1.');
    end
end
