function SHD = compute_shd(G, true_pdag, print_flag)
    pred_Pdag = dag_to_cpdag(G);
    SHD = shd(true_pdag,pred_Pdag);
    if ( ~isequal(true_pdag, pred_Pdag) && print_flag )
        fprintf('predicted G:\n');
        disp(G);
        fprintf('predicted PDAG:\n');
        disp(pred_Pdag);
        fprintf('true PDAG: \n');
        disp(true_pdag);
    end
    fprintf('hamming distance = %d\n', SHD);
end