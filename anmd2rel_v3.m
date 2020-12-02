clear
close all
display('0. Program: anmd_filter');
disp('--0. reset all data')
%% memo
%v2 ���Ԋu�ɂȂ�悤�ɕ␳����R�[�h����ꍞ�񂾁B���̂ق���������������Ȃ�����
%v3 ���[�p�X�t�B���^�������B�܂��ʑ��x���������C������悤�ɂ����B

%% #0. open data
[infile, inpath] = uigetfile('*.anmd', 'Open input file:');
disp('--0. import')
if (inpath == 0) 
        %break;
else
    infullpath=[inpath infile];
    data1=load(infullpath);
    display(infile);
end

%% #1.1 �Ԉ��� ����y���Ȃ邵
display('1. decimate')
sampling_n=10;
data_downsample=downsample(data1,sampling_n);
%decimate�̋��������\���������Ƃ��Ă�C������B���Ԃ��S�̓I�Ɉ��k�����g�����h�������Ă�
%���Ȃ畁�ʂɊԈ������オ������˂��Ă��Ƃ�downsample���g�p�B
%�Ԉ������Ƃ͎���matlab�̃t�B���^�[��������O�̏����Ƃ��Đ�������Ă���

%% 1.2 resampling
% �q�X�g�O��������œK�ȊԊu���s�b�L���O���A���T���v�����O����B
% ���Ԋu�Ő؂�o���Ȃ��Ə������Ԋu�قǋ����ISDV���������ƂɂȂ�
% �ł�����菬���ȊԊu�Ő؂�o�������������炵���iSeama1992�j
T=gradient(data_downsample(:,1),1);
histogram(T);
desired_interval = 'What is the main peak? if bymodal, the right side peak is better: ';
desired_interval = input(desired_interval)
timeB=data_downsample(:,1);
tx = fix(min(timeB))+1:desired_interval:max(timeB);
tx = tx-1;
d2 = timeseries(data_downsample(:,2),timeB,'Name','data');
d2 = resample(d2,tx);
d3 = timeseries(data_downsample(:,3),timeB,'Name','data');
d3 = resample(d3,tx);
d4 = timeseries(data_downsample(:,4),timeB,'Name','data');
d4 = resample(d4,tx);
d5 = timeseries(data_downsample(:,5),timeB,'Name','data');
d5 = resample(d5,tx);
d6 = timeseries(data_downsample(:,6),timeB,'Name','data');
d6 = resample(d6,tx);
d7 = timeseries(data_downsample(:,7),timeB,'Name','data');
d7 = resample(d7,tx);

data3(:,1)=tx;
data3(:,2)=d2.data;
data3(:,3)=d3.data;
data3(:,4)=d4.data;
data3(:,5)=d5.data;
data3(:,6)=d6.data;
data3(:,7)=d7.data;

%% #2. filtering
disp('--1. filtering');

%% 2.1 low-pass filter
y=d7.data; %Hz
yy=fft(y);

%% 2.1.1 �t�B���^�[������O�Ƀp���[�v���b�g�B�S�̂̃g�����h���m�F�B
T =desired_interval;             % Sampling period 
Fs=1/T;   % Sampling frequency                    
L = size(y,1);             % Length of signal
t = (0:L-1)*T;        % Time vector
P2 = abs(yy/L); %�����X�y�N�g��
P1 = P2(1:L/2+1); %�Б��X�y�N�g��
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L*T;
figure(2)
loglog(f,P1) 
title('Power spectrum of the unfiltered magnetic vector anomaly')
xlabel('Wave lengthf (km)')
ylabel('Power nT2km')

%obw(y,Fs);
[bw,flo,fhi,powr] = obw(y,Fs);
pcent = powr/bandpower(y)*100;

%% 2.1.2 �t�B���^�[�p�����[�^���`
depth=3 %km
Fst = 0.0001/T %0.08 km /T % Stopband frequency in Hz 1.4e3
%Fst = depth*0.5/T %0.08 km /T % Stopband frequency in Hz 1.4e3
Ap = 1;      % Passband ripple in dB
Ast = 95;    % Stopband attenuation in dB
% Design the filter
N=500;
Rp  = 0.0001; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-4;       % Corresponds to 80 dB stopband attenuation
eqnum = firceqrip(N,Fst/(Fs/2),[Rp Rst],'passedge'); % eqnum = vec of coeffs
fvtool(eqnum,'Fs',Fs,'Color','White') % Visualize filter
lowpassFIR = dsp.FIRFilter('Numerator',eqnum); 

%% 2.1.3 ���[�p�X�t�B���^�[������
yyy=lowpassFIR(y);

%% 2.1.4 �t�B���^�[��̃g�����h���p���[�v���b�g�Ŋm�F
figure(2)
hold on
T =desired_interval;             % Sampling period 
Fs=1/T;   % Sampling frequency                    
L = size(y,1);             % Length of signal
t = (0:L-1)*T;        % Time vector
P2 = abs(yyy/L); %�����X�y�N�g��
P1 = P2(1:L/2+1); %�Б��X�y�N�g��
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L*T;
loglog(f,P1) 
title('Power spectrum of the unfiltered magnetic vector anomaly')
xlabel('Wave lengthf (km)')
ylabel('Power nT2km')

%% 2.1.3 xyz�S���Ƀ��[�p�X�t�B���^�[�̓K�p
%��ɃX�p�C�N�m�C�Y��������
temp_t=medfilt1(d5.data,3); %despike
d5_lpfil=lowpassFIR(temp_t);
clear temp_t;

temp_t=medfilt1(d6.data,3); %despike
d6_lpfil=lowpassFIR(temp_t);
clear temp_t;

temp_t=medfilt1(d7.data,3); %despike
d7_lpfil=lowpassFIR(temp_t);
clear temp_t;

zure = mean(grpdelay(lowpassFIR)); 
%�t�B���^�[�Ɉˑ�����x���������I�Ɏ擾���āA���炷

%% 3. isdv2rel
%T=gradient(data3(:,1),1); %�����������Ǝv��,1�Ŋ����č��������܂��o���Ă�
a=size(tx,2);
T2=zeros(a,7);
T2(:,1)=transpose(tx); %dist
T2(:,2)=d2.data/10000000; %lat
T2(:,3)=d3.data/10000000; %lon
T2(end+1:end+zure,:)=zeros(zure,7);
%T2(:,4)=gradient(d4.data,desired_interval); %total
T2(zure+1:end,5)=gradient(d5_lpfil,desired_interval); %dHx/dp
T2(zure+1:end,6)=gradient(d6_lpfil,desired_interval); %dHy/dpy
T2(zure+1:end,7)=gradient(d7_lpfil,desired_interval); %dHz/dp
ISDV=sqrt(T2(:,5).^2.+T2(:,6).^2.+T2(:,7).^2);

%% #3.1 filtering �ړ�����
%�ɑ�_�����ɂ����̂ňړ����σt�B���^�[�������Ⴄ 
window_med=80 %stcm2stc��delay�ɍ��킹�Ă�� 8�b�Ȃ�64�Z��
T2(:,4)=medfilt1(ISDV,window_med); %isdv
T2(1:zure,:)=[];
T2(end-zure:end,:)=[];

%pswiggle�悤�̃f�[�^�����
T4=zeros(size(T2,1),6);
T4(:,1:3)=T2(:,1:3); %lon,lat
T4(:,4)=d5_lpfil(zure+2:end); %Hx
T4(:,5)=d6_lpfil(zure+2:end); %Hy
T4(:,6)=d7_lpfil(zure+2:end); %Hz
T4(:,7)=sqrt(T4(:,3).^2+T4(:,4).^2+T4(:,5).^2); %Htotal

%% 3.2 result plot
x1=T2(:,1);

figure(4)
subplot(5,1,1);
plot(x1, T2(:,5))
axis([min(x1) max(x1) -200 200])
title('dFx/dp');

subplot(5,1,2);
plot(x1,T2(:,6))
axis([min(x1) max(x1) -200 200])
title('dFy/dp');

subplot(5,1,3);
plot(x1,T2(:,7))
axis([min(x1) max(x1) -200 200])
title('dFz/dp');
hold on 


%% 4. Peak detection
x1=T2(:,1);
y1=T2(:,4);
ax1=subplot(5,1,4);
area(ax1,x1,T2(:,4));
hold on
title('ISDV plot');
axis([min(x1) max(x1) 0 500])
hold off

wind=10; %0.68*mean depth�H
ax2=subplot(5,1,5);
findpeaks(T2(:,4),T2(:,1),'MinPeakProminence',wind,'Annotate','extents')
[pks,locs,widths,proms]=findpeaks(T2(:,4),T2(:,1),'MinPeakProminence',wind,'Annotate','extents');
axis([min(x1) max(x1) 0 500])
title('Peak detection');

%% 4.1 ISDV�Ŏ�����鋫�E����xyz�f�[�^���������������Ƃɂ���
% �ق����f�[�^��T3�ɏW�񂳂���̂ň��TT�Ƀf�[�^���W�߂ĊY���ɂ���
% distance����v����������o��
TT=[T2(:,1:3), d5_lpfil(1:end-zure-1),d6_lpfil(1:end-zure-1),d7_lpfil(1:end-zure-1)];  

%distance, lat, lon, x, y, z,
for j=1:size(locs,1);
    io=locs(j);
    ko=find(TT(:,1)==io);
    T3(j,:)=TT(ko,:);
end

%% 4.2 ���E�x�N�g���̐���
%���E�x�N�g���̐���@xx = A\B;
for j=1:size(locs,1);
    x=T3(j,4);y=T3(j,5);z=T3(j,6);
    A=[x 0 0;0 y 0; 0 0 z];
    B=[1;1;1];
    xx = A\B;
    xn=xx/norm(xx);
    M=mean(xn);
    T3(j,7:9)=transpose(xn);
    T3(j,10)=sqrt(1/2*((xn(1)-M)^2+(xn(2)-M)^2+(xn(3)-M)^2));
    %Vx,Vy,Vz,standard deviation
end

%peaks,width,prominens
T3(:,11)=pks; T3(:,12)=widths; T3(:,13)=proms;
%theta
[theta,rho] = cart2pol(T3(:,7),T3(:,8));
T3(:,14)=rad2deg(theta);

figure(5)
subplot(2,1,1)
plot(T2(:,3),T2(:,2))
hold on
co2 = linspace(1,size(T3(:,1),1),length(T3(:,1)));
scatter(T3(:,3),T3(:,2),25,co2,'filled');
quiver(T3(:,3),T3(:,2),T3(:,7),T3(:,8))
title('track of the ship');
hold off
subplot(2,1,2)
hold on
scatter(T3(:,3),T3(:,10),25,co2,'filled');
title('deviation');
hold off

figure(3);
plot(data3(:,5));
hold on;
plot(T4(:,4));
hold off;

figure(8)
area(T4(:,1),T4(:,6));
hold on;axis([min(T4(:,1)) max(T4(:,1)) -500 500]);

%% 6 save file rel
width=20;
[filepath,name,ext] = fileparts(infile);
outfile=[name,'.rel']
outfullpath=[inpath outfile];
fid=fopen(outfullpath,'w');
fprintf(fid,'%3.4f %3.4f %3.4f %.0f %.0f %.0f %.0f\n',T2');
fclose(fid);

%% 7 save file peak
width=20;
outfile=[name,'.peak']
outfullpath=[inpath outfile];
[filepath,name,ext] = fileparts(outfile);
fid=fopen(outfullpath,'w');
fprintf(fid,'%3.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',T3');
fclose(fid);
%distance lat lon Hx Hy	Hz Vx Vy Vz deviation pks width prominens direction_degrees

%% save file anmd-distance for wiggle
width=20;
outfile=[name,'.wiggle']
outfullpath=[inpath outfile];
[filepath,name,ext] = fileparts(outfile);
fid=fopen(outfullpath,'w');
fprintf(fid,'%3.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',T4');
fclose(fid);
%distance lat lon hx hy hz htotal
%%
disp('--End')
