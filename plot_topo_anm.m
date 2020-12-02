%plot anormary and topography
clear
close all
display('0. Plot anormary and topo');
disp('--0. reset all data')
%% 0. open data
[infile, inpath] = uigetfile('*.stcm', 'Open input file:');
disp('--0. import')
if (inpath == 0) 
        %break;
else
    infullpath=[inpath infile];
    data1=load(infullpath);
    display(infile);
end

%topo data
sampling_n=30;
data_downsample=downsample(data1,sampling_n);
T(:,1:2)=data_downsample(:,7:8)/10000000;
T(:,3)=data_downsample(:,9)*-1;
k=find(T(:,3) == 0);
T(k,:)=[];


%% 0. open data
[infile, inpath] = uigetfile('*.wiggle', 'Open input file:');
disp('--0. import')
if (inpath == 0) 
        %break;
else
    infullpath=[inpath infile];
    data2=load(infullpath);
    display(infile);
end

data2(:,1)=[];

%M(:,2)=-1*(data2(:,6)-mean(data2(:,6)));
M(:,2)=-1*(data2(:,5));
M(:,1)=data2(:,2);

tarou=min(T(:,3))-100;
jirou=max(T(:,3))+100;

figure(1);
subplot(2,1,1)
plot(T(:,2),T(:,3));
legend('Bathymetry')

tarou=min(T(:,3))-100;
jirou=max(T(:,3))+100;
axis([min(T(:,2)) max(T(:,2)) tarou jirou]);
%axis([-65.1 max(T(:,2)) tarou jirou]);


subplot(2,1,2)
plot(data2(:,2),data2(:,3));hold on;
plot(data2(:,2),data2(:,4));
plot(data2(:,2),data2(:,5));
plot(data2(:,2),data2(:,6));
legend('X','Y','Z','Total Force')

axis([min(T(:,2)) max(T(:,2)) -500 500]);
%axis([-65.1 max(T(:,2)) -600 600]);


figure(2);
subplot(2,1,1)
scatter(T(:,2),T(:,3),'.');
legend('Bathymetry')

axis([min(T(:,2)) max(T(:,2)) tarou jirou]);
%axis([-65.1 max(T(:,2)) tarou jirou]);


subplot(2,1,2)
scatter(data2(:,2),data2(:,3),'.');hold on;
scatter(data2(:,2),data2(:,4),'.');
scatter(data2(:,2),data2(:,5),'.');
scatter(data2(:,2),data2(:,6),'.');
legend('X','Y','Z','Total Force')

axis([min(T(:,2)) max(T(:,2)) -500 500]);
%axis([-65.1 max(T(:,2)) -600 600]);

