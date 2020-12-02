% AORI STCM calc milisecond and resampling
% 2020 Koge H.
% 02_AORIstcm_cat.sh->STCM_milisec_v3.m->stc2fld->fld2anm->STCM_filtering(including
% remove duplicate point),cut lines-> anm2anmd
clear all;
close all;
%--Note------------
% AORI��STCM�̓~���b�̎��^���Ȃ��̂Ōォ��⊮���Ă��K�v������̂ŁA��������B
% v3 STCMkit�p�ɏo�͂�ύX�B�ܓx�o�x�̏����_���ȗ����Aheading,roll,pitch��100�{�ɂ���B 
% v4 stc, stcm�ǂ�����o�͂���悤�ɉ��P�B->���̋@�\��stcm2stc�Ɏ������āA�{�v���O��������͏����B
% v4 8�̎��p�̃`���[�j���O�������B�Ƃ����Ă��R�}���h���o�Ă���悤�ɂ��������Ȃ̂ŁA���ۂ̓t�c�[�̃t�@�C���ɂ��g����B
%----------
milisecound=0; % �~���b�����^����Ă���ꍇ�Amilisecound=0�Ƃ���΁A�~���b�⊮�̂Ƃ�����X�L�b�v����B
%-----------
%% 0. open data
[infile, inpath] = uigetfile('*_stcm.dat', 'Open input file:');
disp('--0. import')
if (inpath == 0) 
        %break;
else
    infullpath=[inpath infile];
    data1=load(infullpath);
    display(infile);
end

% step=2;
% data=data(1+step:end,:);

%% 1.�~���b��⊮����B
if (milisecound == 0)
    disp('skip --1. supply the milisecond')
    timeA = datetime(data1(:,1:6));
else
    disp('--1. supply the milisecond')
    timeA = datetime(data1(:,1:6));
    format longG
    timeB = posixtime(timeA); %�O���[�v���ϐ��̂��߂�unixtime���Z�b�g
    T = table2array(table(data1(:,6),timeB)); %���ʂ̐��l�f�[�^�ɕϊ�
    mi_i=min(T(:,2)); %Unixtime�̍ő�ŏ����Z�b�g���ă��[�v������͈͂̌��f�[�^�����
    ma_i=max(T(:,2));
    for i = mi_i:ma_i
        k=find(T(:,2) == i); %Unixtime��i�ƈ�v����s������Ԕ����o��
        nominalFs=1/length(k); %��v�s�̐��𒲂ׂāA1�b�������āA�K�؂ȃ~���b���o���B 
        ad=0:nominalFs:1-nominalFs; 
        T(k,3)=transpose(ad)+T(k,1);%����ꂽ�~���b�����ꂼ��̕b�ɑ����B
    end
    data1(:,6) = T(:,3);
    timeA = datetime(data1(:,1:6)); %�~���b�t���̃f�[�^�ɍĒ�`
end

%% 2.resampling
disp('--2. resampling at 8Hz')
desiredFs = 8;
desiredS = 1/desiredFs;
%
steps=2; %stcm�ƃv���g���̃f�[�^�ɂ�2�b���ꂪ����̂ŁA���炵�Ă�����
timeB = posixtime(timeA)+steps; %timeseries��cell�Ƃ��Ĉ������߂ɕϊ�,timeA�̓~���b�t���ɍĒ�`���ꂽ����
%
%���[�v�������Ă����Ă��������ǂ�
%�Ⴆ�� i=7:17, k(i)=timeseries(data1(:,i),''Name...�Ƃ���
%data2�ɓ����Ƃ��܂ł����[�v�ɂ����猋�\�������肵����
lat = timeseries(data1(:,7),timeB,'Name','data');
lon = timeseries(data1(:,8),timeB,'Name','data');
depth= timeseries(data1(:,9),timeB,'Name','data');
% 
proton= timeseries(data1(:,10),timeB,'Name','data');
grav=timeseries(data1(:,11),timeB,'Name','data');
%
hx=timeseries(data1(:,12),timeB,'Name','data');
hy=timeseries(data1(:,13),timeB,'Name','data');
hz=timeseries(data1(:,14),timeB,'Name','data');
%
heading=timeseries(data1(:,15),timeB,'Name','data');
roll=timeseries(data1(:,16),timeB,'Name','data');
pitch=timeseries(data1(:,17),timeB,'Name','data');
%
tx = fix(min(timeB))+1:desiredS:max(timeB);
%�~���b��0����ɂȂ�悤��1�ԍŏ��̂Ƃ���͐؂�̂Ă�+1�����b���烊�T���v�����O����B
%
lat_r = resample(lat,tx);
lon_r = resample(lon,tx);
depth_r = resample(depth,tx);
% 
proton_r =resample(proton,tx);
grav_r =resample(grav,tx);
%
hx_r=resample(hx,tx);
hy_r=resample(hy,tx);
hz_r=resample(hz,tx);
%
heading_r=resample(heading,tx);
roll_r=resample(roll,tx);
pitch_r=resample(pitch,tx);
%
% hx.Data�Ńf�[�^���Z���Ƃ��Ď��o����̂ŁA��͉��̏o�͂Ɠ������тɂ��Ă��B
data2=zeros(size(transpose(tx),1),12);
data2(:,1)=transpose(tx); 
tt=datetime(data2(:,1),'ConvertFrom','posixtime');
    [data2(:,1),data2(:,2),data2(:,3)]= ymd(tt);
    [data2(:,4),data2(:,5),data2(:,6)] = hms(tt);
%STCNkit�ɓn�����߂̃f�[�^����
    data2(:,1)=data2(:,1)-2000; %dummy
    data2(:,7)=lat_r.data*10000000;
    data2(:,8)=lon_r.data*10000000;
    data2(:,9)=depth_r.data;
    data2(:,10)=proton_r.data;
    data2(:,11)=grav_r.data;
    data2(:,12)=hx_r.data;
    data2(:,13)=hy_r.data;
    data2(:,14)=hz_r.data;
    data2(:,15)=heading_r.data*100;
    data2(:,16)=roll_r.data*100;
    format long

    for i=7:16
        data2(:,i)=round(data2(:,i),0);
    end

%% 1hour���ƂɃv���b�g
desiredS2 = 60*30; %1/desiredFs;
    tx2 = fix(min(timeB))+1:desiredS2:max(timeB);
    %�~���b��0����ɂȂ�悤��1�ԍŏ��̂Ƃ���͐؂�̂Ă�+1�����b���烊�T���v�����O����B
    %
    lat_rp = resample(lat,tx2);
    lon_rp = resample(lon,tx2);

%% plot and check
figure(1) %tracks and per 1 hour dots
hold on;
plot3(data2(:,8),data2(:,7),tt)
plot3(data2(1,8),data2(1,7),tt(1),'o')
title(['Track at ',num2str(infile)])
hold off
datacursormode
%�ǂݎ��B
display('--3. digitize to cut time-start time-end')
%
figure(2)
subplot(5,1,1)
plot(hx_r)
subplot(5,1,2)
plot(hy_r)
subplot(5,1,3)
plot(hz_r)
subplot(5,1,4)
plot(roll_r)
subplot(5,1,5)
plot(pitch_r)

%% end. save file STCM
width=20;
[outfile, outpath] = uiputfile('*.ms.stcm', 'Save as:');
outfullpath=[outpath outfile];
fid=fopen(outfullpath,'w');
% %data=data1(1+width:size(data2(:,1)),1:17);
%fprintf(fid,'%02d %02d %02d %02d %02d %2.4f %09d %10.0f %4.0f %04d %04d %.0f %.0f %.0f\n',data2');%stable ver 
fprintf(fid,'%02d %02d %02d %02d %02d %2.4f %09d %10.0f %4.0f %04d %04d %.0f %.0f %.0f %.0f %.0f %.0f\n',data2');%test 
fclose(fid);

%% suggest the next step
k1=fix(lat.data(1));
k2=fix((lat.data(1)-fix(lat.data(1)))*60);
k3=fix(lon.data(1));
k4=fix((lon.data(1)-fix(lon.data(1)))*60);
k5 = ['calc_coeff_prep ',outfile,' -D',num2str(data2(1,1)),'/',num2str(data2(1,2)),'/',num2str(data2(1,3)),' -P',num2str(k1),':',num2str(k2),'/', num2str(k3),':',num2str(k4),' -S >temp.dat'];
disp(k5)
k6 = ['calc_coeff temp.dat > 8figure_coeff.dat'];
disp(k6)
disp('next stcm2stc.m')
