function [rawoutEr] = threelaysOne(train_x_six,NeuralNum,m,batNum)
%% [5  i]
%%  r,c Ϊ���к�
%   m Ϊ�ļ����
%   batNumΪһ��batch�ĸ���

iterNum = 500 ;               %��������
batchSizeNum =  batNum;       %batch�Ĵ�С������Ҫ�ܱ���������������70750�����ݣ�1415
saeLearningRate = 0.3;        %Ԥѵ�����ֵ�ѧϰ��
NNLearnRate = 0.3;            %��������
startNeuralNum = NeuralNum;          %����������Ԫ����Ŀ,��ʼ��
endNeuralNum = NeuralNum;     %����������Ԫ����Ŀ,��ֹ�� ��400��
AddNerualNum = 10 ;           %ÿ�����Ӷ��ٸ���Ԫ
r  = 1540;
c  = 1741;

filename = ['E://DataResulterGraph/3-29-2������ѵ��ͼ/threelays/', num2str(m) , '/'];

rand('state',0)   

j = 1;
threelayEr = 0;
disp('*****************************��������ѵ��***********************************************'); 

    for i = startNeuralNum : AddNerualNum : endNeuralNum    %��Ԫ��������
            
            Saestruct = [5  i];        %SAE�����ʼ������
            sae = saesetup(Saestruct);
            sae.ae{1}.activation_function       = 'sigm';
            sae.ae{1}.learningRate              = saeLearningRate;
            opts.numepochs =  iterNum;
            opts.batchsize = batchSizeNum;
            [sae] = saeRawTrainProgram(sae, train_x_six, opts);
            
            % encoder��w��ת��+decoder��b��
            wae1 = [sae.ae{1}.W{2}(:,1)';sae.ae{1}.W{1}(:,2:end)]; 

            % Use the SDAE to initialize a FFNN  fine_tuning����
            nn = nnsetup([5  i  5]);
            nn.activation_function              = 'sigm';
            nn.learningRate                     = NNLearnRate;

            nn.W{1} = sae.ae{1}.W{1};                        %  encoder�����w1��Ȩֵ��discoder��w1+w2��ƫִ
            nn.W{2} = wae1';
            nn.output              = 'sigm';                  %  use softmax output

            %%%%%%%%%%% Train the FFNN
            opts.numepochs =   iterNum;
            opts.batchsize =  batchSizeNum;
            [nn,lfull] = nntrain(nn, train_x_six, train_x_six, opts);
            layLfull(j) = mean(lfull);
            NNoutdata = nnfse(nn, train_x_six, batNum);                      %���ÿ�������
            
%           %%%5-40-20-10-5%  ����ʮ����ʱ�������������ֵ
%             if(i ==40)
%                 threelayEr = lfull(size(lfull,1),1);
%             end
            
            figure;plot(lfull);   %���������µ����
%             saveas(gcf,strcat(filename, num2str(i),'����Ԫ��������������ֵ1ǧ'),'fig');
            close(figure(gcf));     %�ر��������ɵ�ͼ
                        
            %%%%%%%%%%% �����ع���ԭʼ���ݲ��죬���ӻ��쳣���
            nnOutdata1 =  gather(NNoutdata); 
            rawoutEr =   elcomputer( train_x_six, nnOutdata1);   %�ع����
% %             rawoutEr =  reshape(rawoutEr,r,c);
% %             figure;visualize(rawoutEr); 
% %             axis off;              %���᲻�ɼ���
% % %           title(strcat(num2str(i) ,'����Ԫ�쳣�ֲ�'));
% %             saveas(gcf,strcat(filename, num2str(i),'���������쳣�ֲ�1ǧ'),'fig')  %���ֻ��һ��ͼ��handle��Ϊgcf           
% %             close(figure(gcf));            
                        
            %%%%%%%%%%   ��¼ÿ������Ԫ��������Ч���ı仯
% %             disp(['�������磬',num2str(i), '�����������������']); 
% %             opts = statset('Display','final','MaxIter',1000);   %���ݴ��ˣ�100�β���������Ϊ1000��
% %             nnOutdata2 =  gather(NNoutdata{1,1}); 
% %             idx = kmeans(nnOutdata2,5,'Options',opts);             
% %             idx = reshape(idx,r,c);
% %             idx = flipud(idx);
% %             figure;contourf(idx); 
% %             axis off;               %���᲻�ɼ���
%           title(strcat('��',num2str(i), '�����Ч��'));
% %             saveas(gcf,strcat(filename,num2str(i),'�������ľ���Ч��1ǧ'),'fig') 
% %             close(figure(gcf));     %�ر��������ɵ�ͼ
            
            j = j+1 ;           %���ڼ�¼���ֵ��λ��
            
            save(strcat(filename,'km-aeOutѧϰ��Ϊ03-03',num2str(NeuralNum),'����Ԫ.mat'));
            
    end
    
        figure;plot(layLfull);
    
% %     %   �ҳ����Ļ���С��layfull
% %          max1 = max(layLfull);
% %          mm = max( max1 );
% %         [~,column] = find(layLfull==mm);
% %         tm =  startNeuralNum + (column-1) * AddNerualNum;
        
    %   title(strcat('��',num2str(z),'�㣬ÿ����10����Ԫ�������ı仯���'));
        saveas(gcf,strcat(filename,'km-aeOut�����ı仯���1ǧ'),'fig') ;
        close(figure(gcf));   
        disp('*****');       

%       clearvars -except tm��
end

