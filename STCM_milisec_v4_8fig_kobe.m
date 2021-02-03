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
% �_�ˑ�̂�8hz���ϊ�����Ƃ��Ɋ��ɓ����Ă�̂ŁA�~���ߋ�̕⊮�Ƃ������̓v���g���Ƃ̃f�[�^�⊮�̂ق��ɒ��͂����B
%----------
proton=1; %�v���g���̃f�[�^������ꍇ�A������1�Ƃ���B
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

timeA = datetime(data1(:,1:6));
format longG
timeB = posixtime(timeA); %�O���[�v���ϐ��̂��߂�unixtime���Z�b�g


%% 1.5 �v���g���̃f�[�^���ォ����ꍞ��
if (proton == 0)
    disp('skip --1.5  supply proton')
else
    [infile, inpath] = uigetfile('*dat.matd', 'Open input file:');
    disp('--0. import proton')
    if (inpath == 0) 
            %break;
    else
        infullpath=[inpath infile];
        dataP=load(infullpath);
        display(infile);
    end
    %
    desiredFs = 8;
    desiredS = 1/desiredFs;
    %
    timePA = datetime(dataP(:,1:6));
    timePB = posixtime(timePA);
    propro =timeseries(dataP(:,7),timePB,'Name','data');
    ttx = fix(min(timePB))+1:desiredS:max(timePB);
    propro_r =resample(propro,ttx);
    tttx=transpose(ttx); 
    
    ttttx=datetime(ttx,'ConvertFrom','posixtime');
    clear dataP
    [dataP(:,1),dataP(:,2),dataP(:,3)]= ymd(ttttx);
    [dataP(:,4),dataP(:,5),dataP(:,6)] = hms(ttttx);
    dataP(:,7)=propro_r.data;
    %
    dataP_j(:,1)=tttx;
    dataP_j(:,2)=propro_r.data;
    T1 = array2table(dataP_j,'VariableNames',{'time','proton'});
end

%% 2.resampling
disp('--2. resampling at 8Hz')
disp('--for kobe data, this part was for innerjoin two data')

timeA = datetime(data1(:,1:6)); %�~���b�t���̃f�[�^�ɍĒ�`
steps=0; %stcm�ƃv���g���̃f�[�^�ɂ͂��ꂪ����B2�b�Ƃ��B
timeB = posixtime(timeA)+steps; %timeseries��cell�Ƃ��Ĉ������߂ɕϊ�,timeA�̓~���b�t���ɍĒ�`���ꂽ����

%innerjoin�̂��߂̏���
    data1_j(:,1)=timeB; %dummy
    data1_j(:,2:12)=data1(:,7:17);
    T2=array2table(data1_j,'VariableNames',{'time','lat','lon','depth','protonF','grav','hx','hy','hz','heading','roll','pitch'});
    format long
%innerjoin
T = innerjoin(T2,T1);
%����
TT=table2array(T);
TT(:,5)=TT(:,13);
TT(:,13)=[];

%STCMkit�ɓn�����߂̃f�[�^����
data2=zeros(size(TT,1),17);
tt=datetime(TT(:,1),'ConvertFrom','posixtime');
    [data2(:,1),data2(:,2),data2(:,3)]= ymd(tt);
    [data2(:,4),data2(:,5),data2(:,6)] = hms(tt);
    data2(:,7:17)=TT(:,2:12);
    %
    data2(:,1)=data2(:,1)-2000;
    data2(:,7:8)=data2(:,7:8)*10000000;
    data2(:,15:17)=data2(:,15:17)*100;
    format long

    for i=7:17
        data2(:,i)=round(data2(:,i),0);
    end


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
plot(data2(:,12))
subplot(5,1,2)
plot(data2(:,13))
subplot(5,1,3)
plot(data2(:,14))
subplot(5,1,4)
plot(data2(:,15))
subplot(5,1,5)
plot(data2(:,16))

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
la=data2(1,7)/10000000;
lo=data2(1,8)/10000000;
k1=fix(la);
k2=fix((la-fix(la))*60);
k3=fix(lo);
k4=fix((lo-fix(lo))*60);
k5 = ['calc_coeff_prep ',outfile,' -D',num2str(data2(1,1)),'/',num2str(data2(1,2)),'/',num2str(data2(1,3)),' -P',num2str(k1),':',num2str(k2),'/', num2str(k3),':',num2str(k4),' -S >temp.dat'];
disp(k5)
k6 = ['calc_coeff temp.dat > 8figure_coeff.dat'];
disp(k6)
disp('next stcm2stc.m')
