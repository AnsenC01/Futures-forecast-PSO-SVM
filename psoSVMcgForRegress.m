function [bestCVmse,bestc,bestg,fit_gen] = psoSVMcgForRegress(train_label,train,T_test,P_test,pso_option)

%% ������ʼ��
% c1:pso�����ֲ���������
% c2:pso����ȫ����������
% maxgen:����������
% sizepop:��Ⱥ�������
% k:k belongs to [0.1,1.0],���ʺ�x�Ĺ�ϵ(V = kX)
% wV:(wV best belongs to [0.8,1.2]),���ʸ��¹�ʽ���ٶ�ǰ��ĵ���ϵ��
% wP:��Ⱥ���¹�ʽ���ٶ�ǰ��ĵ���ϵ��

% popcmax:SVM ����c�ı仯�����ֵ.
% popcmin:SVM ����c�ı仯����Сֵ.
% popgmax:SVM ����g�ı仯�����ֵ.
% popgmin:SVM ����c�ı仯����Сֵ.
% popkernel:SVM�ĺ˲���

Vcmax = pso_option.k*pso_option.popcmax;
Vcmin = -Vcmax ;
Vgmax = pso_option.k*pso_option.popgmax;
Vgmin = -Vgmax ;
%% ������ʼ���Ӻ��ٶ�
for i=1:pso_option.sizepop
    % ���������Ⱥ���ٶ�
    i
    pop(i,1) = (pso_option.popcmax-pso_option.popcmin)*rand+pso_option.popcmin;
    pop(i,2) = (pso_option.popgmax-pso_option.popgmin)*rand+pso_option.popgmin;
    V(i,1)=Vcmax*rands(1,1);
    V(i,2)=Vgmax*rands(1,1);
    
    % �����ʼ��Ӧ��
    cmd = ['-s 3 -t ',num2str( pso_option.popkernel ),' -c ',num2str( pop(i,1) ),' -g ',num2str( pop(i,2) ),' -p 0.01 -d 1'];
    model= svmtrain(train_label, train, cmd);
    [l,~]= svmpredict(T_test,P_test,model);
    fitness(i)=mse(l-T_test);%�Ծ�������Ϊ��Ӧ�Ⱥ�����������ԽС������Խ��
end

% �Ҽ�ֵ�ͼ�ֵ��
[global_fitness bestindex]=min(fitness); % ȫ�ּ�ֵ
local_fitness=fitness;   % ���弫ֵ��ʼ��

global_x=pop(bestindex,:);   % ȫ�ּ�ֵ��
local_x=pop;    % ���弫ֵ���ʼ��

% ÿһ����Ⱥ��ƽ����Ӧ��
avgfitness_gen = zeros(1,pso_option.maxgen);

%% ����Ѱ��
for i=1:pso_option.maxgen
    iter=i
    for j=1:pso_option.sizepop
        
        %�ٶȸ���
        V(j,:) = pso_option.wV*V(j,:) + pso_option.c1*rand*(local_x(j,:) - pop(j,:)) + pso_option.c2*rand*(global_x - pop(j,:));
        % �߽��ж�
        if V(j,1) > Vcmax
            V(j,1) = Vcmax;
        end
        if V(j,1) < Vcmin
            V(j,1) = Vcmin;
        end
        if V(j,2) > Vgmax
            V(j,2) = Vgmax;
        end
        if V(j,2) < Vgmin
            V(j,2) = Vgmin;
        end
        
        %��Ⱥ����
        pop(j,:)=pop(j,:) + pso_option.wP*V(j,:);
        %�߽��ж�
        if pop(j,1) > pso_option.popcmax
            pop(j,1) = (pso_option.popcmax-pso_option.popcmin)*rand+pso_option.popcmin;;
        end
        if pop(j,1) < pso_option.popcmin
            pop(j,1) = (pso_option.popcmax-pso_option.popcmin)*rand+pso_option.popcmin;;
        end
        if pop(j,2) > pso_option.popgmax
            pop(j,2) = (pso_option.popgmax-pso_option.popgmin)*rand+pso_option.popgmin;;
        end
        if pop(j,2) < pso_option.popgmin
            pop(j,2) = (pso_option.popgmax-pso_option.popgmin)*rand+pso_option.popgmin;;
        end
        
        % ����Ӧ���ӱ���
        if rand>0.8
            k=ceil(2*rand);
            if k == 1
                pop(j,k) = (pso_option.popcmax-pso_option.popcmin)*rand + pso_option.popcmin;
            end
            if k == 2
                pop(j,k) = (pso_option.popgmax-pso_option.popgmin)*rand + pso_option.popgmin;
            end
        end
        
        %��Ӧ��ֵ
        cmd = ['-t ',num2str( pso_option.popkernel ),' -c ',num2str( pop(j,1) ),' -g ',num2str( pop(j,2) ),' -s 3 -p 0.01 -d 1'];
        model= svmtrain(train_label, train, cmd);
        [l,mse1]= svmpredict(T_test,P_test,model);
        fitness(j)=mse(l-T_test);
        %�������Ÿ���
        if fitness(j) < local_fitness(j)
            local_x(j,:) = pop(j,:);
            local_fitness(j) = fitness(j);
        end
        
        if fitness(j) == local_fitness(j) && pop(j,1) < local_x(j,1)
            local_x(j,:) = pop(j,:);
            local_fitness(j) = fitness(j);
        end
        
        %Ⱥ�����Ÿ���
        if fitness(j) < global_fitness
            global_x = pop(j,:);
            global_fitness = fitness(j);
        end
    end
    
    fit_gen(i)=global_fitness;
    avgfitness_gen(i) = sum(fitness)/pso_option.sizepop;
end

%% ������
% ��õĲ���
bestc = global_x(1);
bestg = global_x(2);
bestCVmse = fit_gen(pso_option.maxgen);%��õĽ��

