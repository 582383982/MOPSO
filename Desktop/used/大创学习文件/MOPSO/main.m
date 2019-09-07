%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �Ľ��Ķ�Ŀ������Ⱥ�㷨������������Ժ���
% �Գ����еĲ��ֲ��������޸Ľ����õ����ĳЩ����
%% ������
function []=main()
Varin = load('mydata.mat');%������Լ�������Ĳ���
ZDTFV=cell(1,50); %// ����Ԫ������
ZDT=zeros(1,50); %//0����
funcname = 'ZDT1';
times = 10;%�൱�ڶ�������ʮ�γ���
M = 100;%MOPSO�еĵ�������
for i=1:times        %//ѭ��10�Σ������µĵ���
    tic; %//��ʱ��ʼ
    %[np,nprule,dnp,fv,goals,pbest]=ParticleSwarmOpt(funcname,100,200,2.0,1.0,0.5,M,30,Varin);%--ZDT3 zeros(1,9)-5-��zeros(1,29)
    [np,nprule,dnp,fv,goals,pbest]=ParticleSwarmOpt(funcname,100,200,2.0,1.0,0.4,M,10,[0,zeros(1,9)],[1,zeros(1,9)+5],Varin);%--ZDT4
    elapsedTime=toc;       %//��ʱ����
    ZDTFV(i)={fv};
    ZDT(i)=elapsedTime;
    display(strcat('��������Ϊ',num2str(i)));
end
zdt1fv=cell2mat(ZDTFV');
for i =1:times
    display(strcat(i,':'));
    disp(ZDT(i));%Ҳ������ʱ��
end
disp(zdt1fv);
disp('�����������º����Ӧ��ֵΪ��');
zdt1fv=GetLeastFunctionValue(zdt1fv);
disp(zdt1fv);

figure(9)
plot(zdt1fv(:,1),zdt1fv(:,2),'k*');
%���������������������ʽ�ʹ�С
xlabel('$f_1$','interpreter','latex','FontSize',25);
ylabel('$f_2$','interpreter','latex','FontSize',25);
set(gca,'FontName','Times New Roman','FontSize',25)%��������������Ϳ̶ȵĴ�С,get current axes���ص�ǰ���������ľ��ֵ
%if(strcmp(funcname,'ZDT3'))
    axis([0 1 0 1]);
%else
 %   axis([20555 20790 190.4 190.7]);
%end
   
% ������������
% �Ⱦ���ȡ��ʵPareto���Ž��ϵĵ㣬��������Ŀ�꺯��ֵ
p_true=0:0.002:1;
pf_true1=p_true;
pf_true2=1-p_true.^2;
r=size(zdt1fv,1);

for i=1:r%��ÿһ�����ӽ⣬
   for j=1:501
    d(i,j)=sqrt((zdt1fv(i,1)-pf_true1(j))^2+(zdt1fv(i,2)-pf_true2(j))^2);
    end
end
%�����d��ÿ������Сֵ����Ϊ��i������������С����
for i=1:r
  dmin(i)=min(d(i,:));
end
Cmean=mean(dmin);
%Cfangcha=var(dmin)% �������ֵ�Ĳ��ƽ�������Ը���-1��������������
disp('������ֵ:');
disp(Cmean);
Cvariance=var(dmin,1);% �������ֵ�Ĳ��ƽ�������Ը���,������ѧ�Ϸ���Ķ���
disp('��������:');
disp(Cvariance)
% �����������delta
% �ȶ�zdt1fv����һ���������򣬼��������꣨��һ��Ŀ��ֵ��������
zdt1fv=sortrows(zdt1fv);%����һ����������������������df(����ߵļ�ֵ��ǰ�صľ���)��dl�������ұߵļ�ֵ��ǰ�صľ��룩
df=sqrt((zdt1fv(1,1)-0)^2+(zdt1fv(1,2)-1)^2);
r=length(zdt1fv);
dl=sqrt((zdt1fv(r,1)-1)^2+(zdt1fv(r,2)-0)^2);
for i=1:r-1
    %��i���͵�i+1����ǰ��֮��ľ���Ϊd(i)
    c(i)=sqrt((zdt1fv(i,1)-zdt1fv(i+1,1))^2+(zdt1fv(i,2)-zdt1fv(i+1,2))^2);
end
%������d�ľ�ֵ
meanNum=mean(c);
%���빫ʽ����delta��ֵ
%����ͺŵĲ���
sum=0;
for i=1:r-1
    sum=sum+abs(c(i)-meanNum);
end
delta=(df+dl+sum)/(df+dl+(r-1)*meanNum);
disp('������Ϊ��');
disp(delta);



end
%% MOPSO��������
%function [np,nprule,dnp,fv,goals,pbest] = ParticleSwarmOpt(funcname,N,Nnp,cmax,cmin,w,M,D,Varin)
function [np,nprule,dnp,fv,goals,pbest] = ParticleSwarmOpt(funcname,N,Nnp,cmax,cmin,w,M,D,lb,ub,Varin)
%���Ż���Ŀ�꺯��:fitness
%�糧Լ��������fitness2
%�ڲ���Ⱥ(������Ŀ)��N
%�ⲿ��Ⱥ(���ӽ⼯):Nnp
%��Ӧ�Ȳ���
%ѧϰ����1:cmax
%ѧϰ����2:cmin
%����Ȩ��:w
%������������M
%�����ά����D
%Ŀ�꺯��ȡ��Сֵʱ���Ա���ֵ:xm
%Ŀ�꺯������Сֵ:fv
%��������:cv
%���Ӽ��:flag
%����Ӧ�Ȳ���:unifit:1->0.1

format long;
unifit = 1;
flag = 0;
NP=[];%���ӽ⼯
Dnp=[];%���ӽ⼯����
params = struct('isfmopso',true,'istargetdis',false,'stopatborder',true);%ZTD2->isfmopso(false->true)����һ��   ZTD3����ʱӦΪtrue
%x0=lb+(ub-lb).*rand([1,D]);
%T=size(fitness(x0,funcname),2);
T = 2;
goals=zeros(M,N,T);%����N������M�ε���TάĿ��仯

% %----��ʼ����Ⱥ�ĸ���--------///////��1��///////////////////////////////////
% %x(1,:)=x0;
% %v(1,:)=(ub-lb).*rand([1,D])*0.5;
x = zeros(N,D);
v = zeros(N,D);
% for i=1:N
%     for j=1:D
%         x(i,j)=lb(j)+(ub(j)-lb(j))*rand;  %�����ʼ��λ��
%         v(i,j)=(ub(j)-lb(j))*rand*0.5; %�����ʼ���ٶ�
%     end
% end
% %----����Ŀ������----------
% %---�ٶȿ���
% %vmax=(ub-lb)*0.5;
%vmin = -vmax;

%----��ʼ����Ⱥ�ĸ���--------///////��1��///////////////////////////////////

for i=1:N
    for j=1:D
        x(i,j)=lb(j)+(ub(j)-lb(j))*rand;  %�����ʼ��λ��
        v(i,j)=(ub(j)-lb(j))*rand*0.5; %�����ʼ���ٶ�
    end
end
%----����Ŀ������----------
%---�ٶȿ���
vmax=(ub-lb)*0.5;
vmin= -vmax;


%-----�����ʼNP-----------////////��2��///////////////////////////////////
NP(1,:)=x(1,:);%��һ��Ĭ�ϼ��루���ӽ⼯��������Ϊһ�в�ȷ���еģ�������ʾ���߱��������������ά��
NPRule=[0,0,0];%���ӽ⼯����
Dnp(1,1)=0;

for i=2:N
   
      [NP,NPRule,Dnp,flag] = compare(flag,x(i,:),NP,NPRule,Dnp,Nnp,funcname,params,Varin);
end
%-----��ʼ�������λ��------///////��3��////////////////////////////////////
pbest = x;%�������Ž�

%-----��ȷ��ÿ���������Ծ͵�Ŀ�귽��-------//��4��///////////////////////////


%------������Ҫѭ�������չ�ʽ���ε���------------
for t=1:M  
    c = cmax - (cmax - cmin)*t/M;
    w1=w-(w-0.3)*t/M;

    for i=1:N
%-----���ȫ������-------/////��5��/////////////////////////////////////////////   
      [gbest,NPRule] = GetGlobalBest(NP,NPRule,Dnp);    
          v(i,:)=w1*v(i,:)+c*rand*(pbest(i,:)-x(i,:))+c*rand*(gbest-x(i,:));
          for j=1:D
            if v(i,j)>vmax(j) 
                v(i,j)=vmax(j);
            elseif  v(i,j)<vmin(j) 
                v(i,j)=vmin(j);
            end 
          end
           x(i,:)=x(i,:)+v(i,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------��ȡ��ʩ���������ӷɳ��ռ�----------////��7��/////////////
         %�ٶ�λ��ǯ��
        if(params.stopatborder)%�������ͣ���ڱ߽�    
            if x(i,1)>ub(1)
                x(i,1)=ub(1);
                v(i,1)=-v(i,1);
            end
            if x(i,1)<lb(1)
                 x(i,1)=lb(1)+(ub(1)-lb(1))*rand;  %�����ʼ��λ��        
                 v(i,1)=(ub(1)-lb(1))*rand*0.5; 
            end
            for j=2:D
                if x(i,j)>ub(j)
                    if(randi([0,2],1)==0)%����0->1
                        x(i,j)=ub(j);
                        v(i,j)=-v(i,j);
                    else
                         x(i,j)=lb(j)+(ub(j)-lb(j))*rand;  %�����ʼ��λ��
                         v(i,j)=(ub(j)-lb(j))*rand*1.5; 
                    end              
                end
                if x(i,j)<lb(j)
                    if(randi([0,0],1)==0) 
                      x(i,j)=lb(j);              
                      v(i,j)=-v(i,j)*unifit;
                       if(unifit>0.2)
                           unifit = unifit -0.1;
                       end
                    else
                       x(i,j)=lb(j)+(ub(j)-lb(j))*rand;  %�����ʼ��λ��        
                       v(i,j)=(ub(j)-lb(j))*rand*0.5; 
                    end
                end
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%------------------ÿ�����ӵ�Ŀ������-----------------//��8��///////////////  
        goals(t,i,:)=fitness(x(i,:),funcname,Varin);
%----------------��������---------------------------//��9��/////////////////
        domiRel = DominateRel(pbest(i,:),x(i,:),funcname,params,Varin);%x,y��֧���ϵ
       if domiRel==1%pbest֧���½�
           continue;
       else 
            if domiRel==-1%�½�֧��pbest
                pbest(i,:) = x(i,:);
              elseif(rand*2<1)%�½���pbest���಻֧��
                pbest(i,:) = x(i,:);
            end
%-----------------��NP���и��º�ά��-----------------//��10��////////////////
          
          [NP,NPRule,Dnp,flag] = compare(flag,x(i,:),NP,NPRule,Dnp,Nnp,funcname,params,Varin);
          if flag==1%Ϊ�˷����㷨������ֲ����ŵ����⣬��������Ų������
             [NP,flag,x,v] = fresh(NP,flag,x,v);
          end
       end
    end
end
np = NP;%���ӽ�
nprule=NPRule;
dnp = Dnp;%���ӽ�֮��ľ���
r=size(np,1);
fv=zeros(r,T);
for i=1:r
    fv(i,:)=fitness(np(i,:),funcname,Varin);
end
end
%%%%%%%%%%%%%%%--------------����������--------------%%%%%%%%%%%%%%%%%
%% ������ά�����ⲿ��Ⱥ
function [np_out,nprule_out,dnp_out,flag] = compare(flag,x,np,nprule,dnp,nnp,funcname,params,Varin)
%np:���з��ӽ�
%x:��Ҫ�Ƚϵ���
Nnp = nnp;%���ӽ⼯�ռ�
r=size(np,1);%���ӽ�ĸ���
np_out=np;%���ӽ⸴��
nprule_out = nprule;
dnp_out = dnp;%���ӽ⼯��֮�����
if r==0
    return;
end
for i=r:-1:1
    domiRel=DominateRel(x,np(i,:),funcname,params,Varin);
    if domiRel==1 %NP(i)��x֧��
        np_out(i,:)=[];%���ӽ��޳��ý�
        nprule_out(i,:)=[];
        dnp_out(i,:)=[];  
        if ~isempty(dnp_out)
            dnp_out(:,i)=[];
        end
    elseif domiRel==-1 %x��NP(i)֧��,���ز��ٱȽ�
        return;
    end
end
r1=size(np_out,1);%���з��ӽ������
np_out(r1+1,:)=x;%�����з�֧�伯���ӱȽϾ�ռ�Ż򲻿ɱȽϣ���NP�м���x

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    nprule_out(r1+1,:)=[0,0,0];
    
if r1==0
    dnp_out=0;
end
for j=1:r1
    dnp_out(r1+1,j)=GetDistance(np_out(j,:),x,funcname,params);
    dnp_out(j,r1+1)=dnp_out(r1+1,j);
end
if r1>=Nnp  %�ﵽ���ӽ���Ⱥ����
    %---------�Ƴ��ܼ�������С��һ��-------
     densedis = GetDenseDis(dnp_out);   
     n_min = find(min(densedis)==densedis);%�ҳ��ܶȾ�����С��һ��
     tempIndex = randi([1,length(n_min)],1);  
     if min(densedis)==0
        flag = 1;
     end
    np_out(n_min(tempIndex),:)=[];%���ӽ��޳��ý� 
    nprule_out(n_min(tempIndex),:)=[];
    dnp_out(n_min(tempIndex),:)=[];
    if ~isempty(dnp_out)
        dnp_out(:,n_min(tempIndex))=[]; 
    end
end
end
%% ��������֮��ľ���
function dis=GetDistance(x,y,funcname,params)
if(params.istargetdis)
    gx=fitness(x,funcname,Varin);
    gy=fitness(y,funcname,Varin);
    gxy=(gx-gy).^2;
    dis=sqrt(sum(gxy(:)));
else
    g=x-y;
    dis=sum(sum(g.^2));
end
end
%% �ܼ����루����ľ��룩
function densedis = GetDenseDis(dnp)
[r,c] = size(dnp);
densedis=zeros(1,r);
for i=1:r
    firstmin=Inf;
    for j=1:c
        if dnp(i,j)~=0 && dnp(i,j)<firstmin
            firstmin = dnp(i,j);
        end   
    end
    densedis(i)=firstmin;
end
end
%% ϡ����루�ڶ����ľ��룩
function sparedis = GetSpareDis(dnp)
[r,c] = size(dnp);
sparedis=zeros(1,r);
for i=1:r
    firstmin=Inf;
    secondmin=Inf;
    for j=1:c
        if dnp(i,j)~=0 && dnp(i,j)<firstmin
            firstmin = dnp(i,j);
        end
        if dnp(i,j)~=0 && dnp(i,j)~=firstmin && dnp(i,j)<secondmin
            secondmin = dnp(i,j);
        end       
    end
    sparedis(i)=(firstmin+secondmin)/2;
end
end
%% �Ƚ������ӵ��໥֧���ϵ
function v = DominateRel(x,y,funcname,~,Varin)
%�ж�x��y֧���ϵ,����1��ʾx֧��y������-1��ʾy֧��x,����0��ʾ����֧��
v=0;
gx = fitness(x,funcname,Varin);%x��Ŀ������
gy = fitness(y,funcname,Varin);%y��Ŀ������
len = length(gx);
if sum(gx<=gy)==len%x������Ŀ�궼��yС��x֧��y
    v=1;
elseif sum(gx>=gy)==len%y������Ŀ�궼��xС��y֧��x
    v=-1;
end
end
%% ���ȡһ��ȫ������
function [gbest,nprule_out] = GetGlobalBest(np,nprule,dnp_out)
r=size(np,1);%���ӽ������
nprule_out=nprule;
intem=1;
if(round(rand)==0)
    if r==1  
       gbest = np(1,:);
    else
        sparedis = GetSpareDis(dnp_out);
     if(round(rand)==0)
        n_max=find(max(sparedis)==sparedis);
        intem=n_max(round(rand*(length(n_max)-1)+1));
        gbest = np(intem,:);   
     else %�����Ѱ����С�Ĳ���
        sparedis = GetSpareDis(dnp_out);
        n_min=find(min(sparedis)==sparedis);
        intem=n_min(round(rand*(length(n_min)-1)+1));
        gbest = np(intem,:);
     end
     
    end    
else 
    tt=find(min(nprule(:,1))==nprule(:,1));  %���ȡһ����Ϊȫ�����ţ���������ѡ���Ĵ�����͵�����ѡ
    intem=tt(round(rand*(length(tt)-1)+1));
    gbest = np(intem,:);      
end
nprule_out(intem,1)=nprule_out(intem,1)+1;%����ѡȡ�����ӣ���nprule������ͬnp������Ϊ3���ж�Ӧ��
%�еĵ�һ�е���ֵ��1����Ϊ���м�¼���ӱ�ѡȡ���Ĵ�����������Ϊ�Ƿ��ٴν���ѡΪȫ�ּ�ֵ�Ĳο���
end
%% �糧Լ������
function fv = fitness2(x,~,Varin)
    res1=0;
    res2=0;
    for i=1:6
        res1 = res1+Varin.a(i)*x(i)*x(i)+Varin.b(i)*x(i)+Varin.c(i);
        res2 = res2+Varin.Ea(i)*x(i)*x(i)+Varin.Eb(i)*x(i)+Varin.Ec(i)+Varin.Ed(i)*exp(Varin.Ee(i)*x(i));
    end
    fv(1) = res1;
    fv(2) = res2;
  
end
%% ZDT1,ZDT2,ZDT3���Ժ���
function fv=fitness(x,funcname,~)
%��ö�Ŀ���Ŀ������ fv
fv=[];
switch upper(funcname) 
    case 'ZDT1'
        n=length(x);
        gv=1+9*sum(x(2:n))/(n-1);
        fv(1)=x(1);
        fv(2)=gv*(1-sqrt(x(1)/gv));
    case 'ZDT2'
        n=length(x);
        gv=1+9*sum(x(2:n))/(n-1);
        fv(1)=x(1);
        fv(2)=gv*(1-(x(1)/gv).^2);
    case 'ZDT3'
        n=length(x);
        gv=1+9*sum(x(2:n))/(n-1);
        fv(1)=x(1);
        fv(2)=gv*(1-sqrt(x(1)/gv)-(x(1)/gv)*sin(10*pi*x(1)));   
    case 'ZDT4'
        n=length(x);
        gv=1+10*(n-1)+sum(x(2:n).^2-10*cos(4*pi*x(2:n)));
        fv(1)=x(1);
        fv(2)=gv*(1-sqrt(x(1)./gv));
end
end
%% �޳��ⲿ��Ⱥ�еķ�֧�伯
function fvout=GetLeastFunctionValue(fvin)
fvout=fvin;
n=size(fvout,1);
i=1;
while(i<=n)
    j=i+1;
    isdominated=false;%�ж�����
    while(j<=n)
        a=fvout(i,:);b=fvout(j,:);
        if((a(1)<b(1)&&a(2)<=b(2))||(a(1)<=b(1)&&a(2)<b(2)))%b��a֧����
            fvout(j,:)=[];n=n-1;
        else
            if((b(1)<a(1)&&b(2)<=a(2))||(b(1)<=a(1)&&b(2)<a(2)))%a��b֧����
                isdominated=true;
            end
            j=j+1;
        end
    end
    if isdominated
        fvout(i,:)=[];n=n-1;
    else
        i=i+1;
    end
end
end
%% flagΪ1,˵�������������ֲ����ţ��ʼ���25%��������
function [NP,flag,x,v] =   fresh(NP,~,x,v)
    r=size(NP,1);
    flag =1;
    for i=2:r
        if(randi([0,3],1)==0)
            for j=1:D
                x(i,j)=lb(j)+(ub(j)-lb(j))*rand;  %�����ʼ��λ��
                v(i,j)=(ub(j)-lb(j))*rand*0.5; %�����ʼ���ٶ�
            end
        end
    end
end

