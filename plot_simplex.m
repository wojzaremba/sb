function plot_simplex()

    simp=[0 0 0; 0 0 1; 0 1 0; 0 0 0; 0 1 0; 1 0 0; 0 0 0; 1 0 0; 0 0 1; 0 0 0];

    % Plot the 3-simplex in its initial position.
    plot3(simp(:,1), simp(:,2), simp(:,3),'k','linewidth',2);
end