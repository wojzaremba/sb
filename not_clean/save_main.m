function dummy()
assert(0)
-d function dummy()\nassert(0)

% for c = 1:length(classifiers)
%     scores = zeros(2, 2, length(range));
%     w_acc = zeros(length(range), 1);
%     for i = 1:length(range)
%         fprintf('Starting i = %f\n', range(i));
%         options = struct('threshold', range(i), 'arity', arity);
%         for t = 1 : length(triples)      
%             indep = double(dsep(triples{t}(1), triples{t}(2), triples{t}(3:end), bnet.dag));
%             emp = s(triples{t}, :);
%             indep_emp = double(classifiers{c}(emp, options));       
%             scores(1 + indep, indep_emp + 1, i) = scores(1 + indep, indep_emp + 1, i) + 1;
%         end
%         P = scores(2, 1, i) + scores(2, 2, i);
%         N = scores(1, 1, i) + scores(1, 2, i);
%         TP = scores(2, 2, i);        
%         TN = scores(1, 1, i);
%         FN = scores(2, 1, i);
%         FP = scores(1, 2, i); 
%         w_acc(i) = (TP / P + TN / N) / 2;
%         TPR(c,i) = TP/P; % = TP / (TP + FN)
%         FPR(c,i) = FP/N; % = FP / (FP + TN);
%         fprintf('acc = %f\n', w_acc(i));
%     end
%     names{c} = func2str(classifiers{c});
%     fprintf('func = %s, max(w_acc) = %f\n', names{c}, max(w_acc));
%     plot(FPR(c,:),TPR(c,:),colors{c});
%     hold on;
%     %plot(w_acc, colors{c});
%     %hold on;
% end
% legend(names,'interpreter','none');
% xlabel('FPR');
% ylabel('TPR');