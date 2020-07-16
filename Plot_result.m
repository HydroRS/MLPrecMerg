function [  ] = Plot_result(x,y,R2_train, RMSE_train,x_vali, y_vali,R2_vali, RMSE_vali,weights)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


% ------------------------------------
% Create a scatter Diagram
disp('Create a scatter Diagram for training period')

% plot the 1:1 line
plot(x,x,'LineWidth',3);

hold on
scatter(x,y,'filled');
hold off
grid on

set(gca,'FontSize',18)
xlabel('Actual','FontSize',25)
ylabel('Estimated','FontSize',25)
title(['Training Dataset, R^2=' num2str(R2_train);'RMSE=' num2str(RMSE_train)],'FontSize',15)

% ------------------------------------
% Create a scatter Diagram
disp('Create a scatter Diagram for validation period')


% plot the 1:1 line
plot(x_vali,x_vali,'LineWidth',3);

hold on
scatter(x_vali,y_vali,'filled');
hold off
grid on

set(gca,'FontSize',18)
xlabel('Actual','FontSize',25)
ylabel('Estimated','FontSize',25)
title(['Training Dataset, R^2=' num2str(R2_vali);'RMSE=' num2str(RMSE_vali)],'FontSize',15)

% drawnow

% fn='ScatterDiagram';
% fnpng=[fn,'.png'];
% print('-dpng',fnpng);

% ------------------------------------
%% Calculate the relative importance of the input variables
% tic
% disp('Sorting importance into descending order')
% weights=b.OOBPermutedVarDeltaError;
% [B,iranked] = sort(weights,'descend');
% toc
% 
% % ------------------------------------
% disp(['Plotting a horizontal bar graph of sorted labeled weights.']) 
% figure
% barh(weights(iranked),'g');
% xlabel('Variable Importance','FontSize',30,'Interpreter','latex');
% ylabel('Variable Rank','FontSize',30,'Interpreter','latex');
% title(...
%     ['Relative Importance of Inputs in estimating Redshift'],...
%     'FontSize',17,'Interpreter','latex'...
%     );
% hold on
% barh(weights(iranked(1:10)),'y');
% barh(weights(iranked(1:5)),'r');
% 
% % ------------------------------------
% grid on 
% xt = get(gca,'XTick');    
% xt_spacing=unique(diff(xt));
% xt_spacing=xt_spacing(1);    
% yt = get(gca,'YTick');    
% ylim([0.25 length(weights)+0.75]);
% xl=xlim;
% xlim([0 2.5*max(weights)]);
% 
% % ------------------------------------
% % Add text labels to each bar
% for ii=1:length(weights)
%     text(...
%         max([0 weights(iranked(ii))+0.02*max(weights)]),ii,...
%         ['Column ' num2str(iranked(ii))],'Interpreter','latex','FontSize',11);
% end
% 
% % ------------------------------------
% set(gca,'FontSize',16)
% set(gca,'XTick',0:2*xt_spacing:1.1*max(xl));
% set(gca,'YTick',yt);
% set(gca,'TickDir','out');
% set(gca, 'ydir', 'reverse' )
% set(gca,'LineWidth',2);   
% drawnow
% 
% % ------------------------------------
% fn='RelativeImportanceInputs';
% fnpng=[fn,'.png'];
% print('-dpng',fnpng);

% ==================================
%% Ploting how weights change with variable rank
% disp('Ploting out of bag error versus the number of grown trees')
% 
% figure
% plot(b.oobError,'LineWidth',2);
% xlabel('Number of Trees','FontSize',30)
% ylabel('Out of Bag Error','FontSize',30)
% title('Out of Bag Error','FontSize',30)
% set(gca,'FontSize',16)
% set(gca,'LineWidth',2);   
% grid on
% drawnow
% fn='EroorAsFunctionOfForestSize';
% fnpng=[fn,'.png'];
% print('-dpng',fnpng);

end

