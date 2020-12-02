%stcm2stc
clear all;
close all;
%% memo
% v1 finddelay‚ÅŠexyz‚Ì’x‚ê‚ð•]‰¿‚·‚é‚æ‚¤‚É‚µ‚½
% ŠT‚Ë‚«‚ê‚¢‚É“®‚¢‚Ä‚¢‚é‚Ì‚ÅA‰ü‘P‚Ì—\’è‚Í‚È‚¢Š´‚¶B
% .stc‚É‰Á‚¦‚Äxyz¬•ª‚Ìdelay‚ðŒvŽZ‚µ‚Äo—Í‚·‚é‚æ‚¤‚É‚µ‚½B(.delay)
% delay‚Í‘ªü’·‚É‚æ‚Á‚Ä•Ï‰»‚·‚é‚Ì‚ÅAˆê—l‚É‚¸‚ç‚µ‚½‚è‚·‚é‚Æ8‚ÌŽš‚ªŽÀÛ‚Æ•Ï‚í‚Á‚Ä‚µ‚Ü‚¤‰Â”\«‚ ‚é‚Ì‚Å
% anmd2rel‚Ìdelay‚Ì‚Æ‚±‚ë‚É“ü‚ê‚é‚ÆˆÚ“®•½‹Ï‚Å–Â‚ç‚µ‚Ä‚­‚ê‚éB
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

data1(:,1)=data1(:,1)+2000;
    timeA = datetime(data1(:,1:6));
    format longG
    timeB = posixtime(timeA);

%% 1.save file STC
data2=zeros(size(timeB,1),10);
    data2(:,1)=timeB;
    data2(:,2:3)=data1(:,7:8);
    data2(:,4)=data1(:,10);
    data2(:,5:10)=data1(:,12:17);
%% check synclonize
for i=8:10;
    s0=[data2(:,1),data2(:,i)];
    s1=[data2(:,1),data2(:,5)];
    s2=[data2(:,1),data2(:,6)];
    s3=[data2(:,1),data2(:,7)];
    t10 = finddelay(s1,s0);
    t20 = finddelay(s2,s0);
    t30 = finddelay(s3,s0);
    t=[t10(2), t20(2), t30(2)];
    t=t-min(t);
    t(i-7,:)=0.125*t;
end

width=20;

[filepath,name,ext] = fileparts(infile);
outfile=[name,'.stc']
outfullpath=[inpath outfile];
fid=fopen(outfullpath,'w');
fprintf(fid,'%10.4f %.0f %.0f %.0f %.0f %.0f %.0f %.0f %.0f %.0f\n',data2');%stable ver 
fclose(fid);

outfile2=[name,'.delay']
outfullpath2=[inpath outfile2];
fid=fopen(outfullpath2,'w');
fprintf(fid,'%3.4f %3.4f %3.4f \n',t');%stable ver 
fclose(fid);
tt=array2table(t,'VariableNames',{'Hx_cell','Hy_cell','Hz_cell'});
ttt=t*0.125;
ttt=array2table(ttt,'VariableNames',{'Hx_sec','Hy_sec','Hz_sec'});

%% suggest the next step
k1 = ['stc2fld ',outfile,' -C8-2.proton_c.coeff > ',name,'.fld'];
k2 =['fld2anm ',name,'.fld > ',name,'.anm'];
k3 = ['anm2anmd ',name,'.anm > ',name,'.anmd'];
disp(' ')
disp('Delay of Hx, Hy, Hz depends on Heading, roll, pitch')
disp(tt)
disp(' ')
disp(ttt)
disp(' ')
disp(k1)
disp(k2)
disp(k3)
disp('--> next anmd2rel_v2_3.m')