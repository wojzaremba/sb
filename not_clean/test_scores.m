function dummy()
assert(0)
-d function dummy()\nassert(0)
            

scores_test = zeros(size(scores));
scores_test2 = zeros(size(scores));
total_time1 = 0;
total_time2 = 0;
indep_emp1 = reshape(indep_emp,[1 1 size(indep_emp)]);


for t = 1:length(triples)
    tic;
    scores_test(1 + indep(t),1,:,:,:) = scores_test(1 + indep(t),1,:,:,:) + ~indep_emp1;
    scores_test(1 + indep(t),2,:,:,:) = scores_test(1 + indep(t),2,:,:,:) + indep_emp1;
    time1 = toc;
    total_time1 = total_time1 + time1;
    fprintf('finished triples %d score1, time = %d.\n',t,time1);
    
%     tic;
%     scores_test2(1+indep(t),1,:) = scores_test2(1+indep(t),1,:) + ~indep_emp;
%     scores_test2(1+indep(t),2,:) = scores_test2(1+indep(t),2,:) + ~indep_emp;
%     time2 = toc;
%     total_time2 = total_time2 + time2;
%     fprintf('finished triples %d score2, time = %d.\n',t,time2);

end

fprintf('total_time = %d\n',total_time1);