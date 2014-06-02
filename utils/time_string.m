function str = time_string()
    c = clock();
    s1 = strrep(strrep(datestr(c), ' ', '_'), ':', '_');
    s2 = sprintf('%.3f',mod(c(6), 1));
    str = [s1 s2(3:end)];
end
