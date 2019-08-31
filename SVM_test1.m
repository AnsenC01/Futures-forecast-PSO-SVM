% ֧���������������̼�Ԥ�⣬������δ�Ż��ģ�������Ż����
%% ��ջ���
tic;clc;clear;close all;format compact
%% ��������
% data=xlsread('EUA�����.xlsx','G2:G30763'); save data data
load data
% ��һ��
[a,inputns]=mapminmax(data',0,1);%��һ������Ҫ������Ϊ������
data_trans=data_process(5,a);%% ��ʱ������Ԥ�⽨���������У�����1��m������Ԥ���m+1�����ݣ�Ȼ����2��m+1������Ԥ���m+2������
input=data_trans(:,1:end-1);
output=data_trans(:,end);
%% ���ݼ� ǰ75%ѵ�� ��25%Ԥ��
m=round(size(data_trans,1)*0.75);
Pn_train=input(1:m,:);
Tn_train=output(1:m,:);
Pn_test=input(m+1:end,:);
Tn_test=output(m+1:end,:);

%% 1.û���Ż���SVM
bestc=0.001;bestg=10;%c��g�����ֵ ��ʾû���Ż���SVM
t=0;%t=0Ϊ���Ժ˺���,1-����ʽ��2rbf�˺���
cmd = ['-s 3 -t ',num2str(t),' -c ', num2str(bestc),' -g ',num2str(bestg),' -p 0.01 -d 1'];  
    
model = svmtrain(Tn_train,Pn_train,cmd);%ѵ��
[predict,~]= svmpredict(Tn_test,Pn_test,model);%����
% ����һ����Ϊ����Ľ��������׼��
predict0=mapminmax('reverse',predict',inputns);%����ʵ���������һ��
T_test=mapminmax('reverse',Tn_test',inputns);%���Լ������������һ��
T_train=mapminmax('reverse',Tn_train',inputns);%ѵ���������������һ��

figure
plot(predict0,'r-')
hold on;grid on
plot(T_test,'b-')
xlabel('�������')
ylabel('���̼�/Ԫ')
if t==0
    title('���Ժ�SVMԤ��')
elseif t==1
    title('����ʽ��SVMԤ��')
else
    title('RBF��SVMԤ��')
end
legend('ʵ�����','�������')

figure
error_svm=abs(predict0-T_test)./T_test*100;%���Լ�ÿ��������������
plot(error_svm,'r-*')
xlabel('�������')
ylabel('���̼�������/%')
if t==0
    title('���Ժ�SVMԤ������')
elseif t==1
    title('����ʽ��SVMԤ������')
else
    title('RBF��SVMԤ������')
end
grid on



%% 2.���PSO�Ż�SVM������ѡ����ѵ�C��G
pso_option = struct('c1',1,'c2',1,'maxgen',20,'sizepop',5,'k',0.6,'wV',0.9,'wP',0.9, ...
    'popcmax',10^1,'popcmin',10^(-3),'popgmax',10^1,'popgmin',10^(-3),'popkernel',t);%�����Ľ�����psoSVMcgForRegress����

[bestmse,bestc,bestg,trace] = psoSVMcgForRegress(Tn_train,Pn_train,Tn_test,Pn_test,pso_option);

figure;
plot(trace,'r-');
xlabel('��������');
ylabel('��Ӧ��ֵ(������)');
title('��Ӧ������')
grid on;

% ����PSO�Ż��õ������Ų�������SVM ����ѵ��
cmd = ['-s 3 -t ',num2str(t)',' -c ', num2str(bestc), ' -g ', num2str(bestg),' -p 0.01 -d 1'];
model = svmtrain(Tn_train,Pn_train,cmd);%ѵ��
[predict_train,~]= svmpredict(Tn_train,Pn_train,model);%ѵ����
[predict,fit]= svmpredict(Tn_test,Pn_test,model);%���Լ�
% ����һ��
predict_tr=mapminmax('reverse',predict_train',inputns);%ѵ����ʵ���������һ��
predict1=mapminmax('reverse',predict',inputns);%���Լ��������һ��

figure
plot(predict1,'r-')
hold on;grid on
plot(T_test,'b-')
xlabel('���Լ��������')
ylabel('���̼�/Ԫ')
if t==0
    title('PSO-���Ժ�SVMԤ��')
elseif t==1
    title('PSO-����ʽ��SVMԤ��')
else
    title('PSO-RBF��SVMԤ��')
end
legend('ʵ�����','�������')


figure
error_pso_svm=abs(predict1-T_test)./T_test*100;%���Լ�ÿ��������������
plot(error_pso_svm,'r-*')
xlabel('���Լ��������')
ylabel('���̼�������/%')
if t==0
    title('PSO-���Ժ�SVMԤ������')
elseif t==1
    title('PSO-����ʽ��SVMԤ������')
else
    title('PSO-RBF��SVMԤ������')
end
grid on

%% �������

disp('���ųͷ�������˲���Ϊ��')
bestc
bestg



disp('�Ż�ǰ�ľ������')
mse_svm=mse(predict0-T_test)
disp('�Ż�ǰ��ƽ��������')
mre_svm=sum(abs(predict0-T_test)./T_test)/length(T_test)
disp('�Ż�ǰ��ƽ���������')
abs_svm=mean(abs(predict0-T_test))
disp('�Ż�ǰ�Ĺ�һ���������')
a=sum((predict0-T_test).^2)/length(T_test);
b=sum((predict0-mean(predict0)).^2)/(length(T_test)-1);
one_svm=a/b

disp('�Ż����ѵ�������������')
rmse_svm0=sqrt(mse(predict_tr-T_train))
disp('�Ż���Ĳ��Լ����������')
rmse_svm=sqrt(mse(predict1-T_test))
disp('�Ż���ľ������')
mse_pso_svm=mse(predict1-T_test)
disp('�Ż����ƽ��������')
mre_pso_svm=sum(abs(predict1-T_test)./T_test)/length(T_test)
disp('�Ż����ƽ���������')
abs_pso_svm=mean(abs(predict1-T_test))
disp('�Ż���Ĺ�һ���������')
a1=sum((predict1-T_test).^2)/length(T_test);
b1=sum((predict1-mean(predict1)).^2)/(length(T_test)-1);
one_pso_svm=a1/b1


toc %������ʱ