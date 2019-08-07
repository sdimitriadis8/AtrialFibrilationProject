% Peak detect
% Forked from peakdetect.m
% - Accept all recordings.
% - Stop showing hart rate text box, output at terminal instead.
% - Recording & plotting (supposedly) peak of P wave
% - Clear all unnecessary terminal output.
% - Loop to read all files
% - P wave range [peak-18, peak+18]
% - Extract 12 features
% - Record features in .mat 12x8*** matrix
% - Flip list added

clear all;
close all; % close the active plots
clc;
warning off;

load('input_data.mat')
load('AF_fliplist2.mat')

% Defining variables
HR = []; % Heart Rates #1
Pavg = []; % Trapezoid of P wave #2
REavg = []; % Shanon Entropy #3
RApproxAvg = []; % Approximate Entropy #4
RRlenAvg = []; % AVG length of R-R Range #5
Pstd = []; % AVG standard deviation of P, finding f wave #6
RRlogEn = []; % Wavelet of log energy #7
PpeakAvg = []; % AVG amplitude of P waves #8
PmeanFreq = []; % Mean freq of P #9
PsgnChgAVG = []; % Signal Change of P - Average #10
PsgnChgVar = []; % Signal Change of P - Vaiance #11
RstdDev = []; %STD DEV of R-R Range #12

view = 10; % on default the first 8 seconds are viewed
fs = 300; %default Sampling frequency

for smp = 1:size(sample,1)
%for smp = 1:10 % For testing in small number

   str1 = sample{smp};  
   str2= '.mat';
   str = [str1 str2]
   
   load(str)
   ecg = val;

if any(smp==fliplist)
    disp('flip')
    ecg = -val; % on default the program uses EKG
end

%% initialize
E = []; %Entropy of T-Q wave
P_i = []; %Save index of P wave
P_amp = []; %Save amp of P wave
R_i = [];%save index of R wave
R_amp = []; %save amp of R wave
S_i = [];%save index of S wave
S_amp = []; %save amp of S wave
T_i = [];%save index of T wave
T_amp = [];%save amp of T wave
thres_p =[]; %for plotting adaptive threshold
buffer_plot =[];
buffer_long=[]; % buffer for online processing
state = 0 ; % determines the state of the machine in the algorithm
c = 0; % counter to determine that the state-machine doesnt get stock in T wave detection wave
T_on = 0; % counter showing for how many samples the signal stayed above T wave threshold
T_on1=0; % counter to make sure its the real onset of T wave
S_on = 0; % counter to make sure its the real onset of S wave
sleep = 0; % counter that avoids the detection of several R waves in a short time
S_amp1 = []; % buffer to set the adaptive T wave onset
buffer_base=[]; %buffer to determine online adaptive mean of the signal
dum = 0; %counter for detecting the exact R wave
window = round(fs/25); % averaging window size
weight = 1.8; %initial value of the weigth
co = 0; % T wave counter to come out of state after a certain time
thres2_p = []; %T wave threshold indices
thres_p_i = []; %to save indices of main thres
S_amp1_i = []; %to save indices of S thres
thres2_p_i = []; %to save indices of T threshold
Q_i = []; % vectors to store Q wave
Q_amp =[]; %vectors to store Q wave
%% preprocess

ecg = ecg (:); % make sure its a vector
ecg_raw =ecg; %take the raw signal for plotting later
time_scale = length(ecg_raw)/fs; % total time;
%Noise cancelation(Filtering)
f1=0.5; %cuttoff low frequency to get rid of baseline wander
f2=45; %cuttoff frequency to discard high frequency noise
Wn=[f1 f2]*2/fs; % cutt off based on fs
N = 3; % order of 3 less processing
[a,b] = butter(N,Wn); %bandpass filtering
ecg = filtfilt(a,b,ecg);

%% define two buffers

buffer_mean=mean(abs(ecg(1:2*fs)-mean(ecg(1:2*fs)))); % adaptive threshold DC corrected (baseline removed)
buffer_T = mean(ecg(1:2*fs));%second adaptive threshold to be used for T wave detection
%% start online inference (Assuming the signal is being acquired online)
for i = 1 : length(ecg)
    
buffer_long = [buffer_long ecg(i)] ; % save the upcoming new samples
buffer_base = [buffer_base ecg(i)] ; % save the baseline samples

%% Renew the mean and adapt it to the signal after 1 second of processing
if length(buffer_base) >= 2*fs
    buffer_mean = mean(abs(buffer_base(1:2*fs)-mean(buffer_base(1:2*fs))));
    buffer_T = mean(buffer_base(1:2*fs));
    buffer_base =[];
end

%% smooth the signal by taking the average of 15 samples and add the new upcoming samples
  if length(buffer_long)>= window % take a window with length 15 samples for averaging
      mean_online = mean(buffer_long);  % take the mean
      buffer_plot =[buffer_plot mean_online]; % save the processed signal
      
      
    %% Enter state 1(putative R wave) as soon as that the mean exceeds the double time of threshold  
    if state == 0  
     if length(buffer_plot) >= 3   %added to handle bugg for now
      if mean_online > buffer_mean*weight && buffer_plot(i-1-window) > buffer_plot(i-window)    %2.4*buffer_mean   
          state = 1; % entered R peak detection mode
          currentmax = buffer_plot(i-1-window);
          ind = i-1-window;
          thres_p = [thres_p buffer_mean*weight];
          thres_p_i = [thres_p_i ind];
      else     
          state = 0;
      end
     end
    end
    
%% Locate the R wave location by finding the highest local maxima
if state == 1 % look for the highest peak
          
            if  currentmax > buffer_plot(i-window)
                dum = dum + 1;
                if dum > 4 
                R_i = [R_i ind];%save index
                %R_i
                R_amp = [R_amp buffer_plot(ind)]; %save index
                
                %Old value = 36, new = 24 for 80ms before R wave
                if ind-36 > 0
                P_i = [P_i (ind-36)];
                P_amp = [P_amp buffer_plot(ind-36)];
                %P_amp = [P_amp buffer_plot(ind)];
                % Locate Q wave

                [Q_tamp Q_ti] = min(buffer_plot(ind-round(0.040*fs):(ind)));
                Q_ti = ind-round(0.040*fs) + Q_ti -1;
                Q_i = [Q_i Q_ti];
                Q_amp = [Q_amp Q_tamp];
                
                end
                
                if length(R_amp) > 8
                weight = 0.30*mean(R_amp(end-7:end)); %calculate the 35% of the last 8 R waves
                weight = weight/buffer_mean;
                end
                state = 2; % enter S detection mode state 2
                dum = 0;
                end
            else
                dum = 0;
                state = 0;
            end 
            
      end
      
    %% check weather the signal drops below the threshold to look for S wave
      if state == 2 
        if  mean_online <= buffer_mean     % check the threshold
             state = 3;   %enter S detection           
        end
      end
      
      %% Enter S wave detection state3 (S detection)
          if state == 3
            co = co + 1; 
            
          if co < round(0.200*fs)
            if buffer_plot(i-window-1) <= buffer_plot(i-window) % see when the slope changes
             S_on = S_on + 1; % set a counter to see if its a real change or just noise
             if S_on >= round(0.0120*fs)
             S_i = [S_i i-window-4];%save index of S wave
             S_amp = [S_amp buffer_plot(i-window-4)];%save index
             S_amp1 = [S_amp1  buffer_plot(i-window-4)]; %ecg(i-4)
             S_amp1_i = [S_amp1_i ind]; %index of S_amp1_i
             state = 4; % enter T detection mode
             S_on = 0;
             co = 0;
             end
            end
          else
              state = 4;
              co = 0;
          end
          end
      
       %% enter state 4 possible T wave detection
       if state == 4    
         if mean_online < buffer_mean % see if the signal drops below mean 
           state = 6; % confirm
         end
       end
       %% Enter state 6 which is T wave possible detection
       if state ==6   
         c = c + 1; % set a counter to exit the state if no T wave detected after 0.3 second
         %testamp = ((abs(abs(buffer_T)-abs(S_amp1(end))))*3/4 + S_amp1(end))

         if c <= 0.7*fs && isempty(S_amp1) == 0
             % set a double threshold based on the last detected S wave and
             % baseline of the signal and look for T wave in between these
             % two threshold
             thres2 = ((abs(abs(buffer_T)-abs(S_amp1(end))))*3/4 + S_amp1(end)); 
             thres2_p =[thres2_p thres2];
             thres2_p_i =[thres2_p_i ind];
             if mean_online > thres2
              T_on = T_on +1; % make sure it stays on for at least 3 samples
              if T_on >= round(0.0120*fs)
               if buffer_plot(i-window-1)>= buffer_plot(i-window)
                   T_on1 = T_on1+1; % make sure its a real slope change
                  if T_on1 > round(0.0320*fs) 
                   T_i = [T_i i-window-11];%save index of T wave
                   T_amp = [T_amp  buffer_plot(i-window-11)];%save index
                   state = 5; % enter sleep mode
                   T_on = 0;
                   T_on1 = 0;
                  end
                                      
               end
              end
             end
             
            
          
         else
             state= 5; % enter Sleep mode
         end
         
       end  
      
        
       %% this state is for avoiding the detection of a highly variate noise or another peak
       % this avoids detection of two peaks R waves less than half a second
       if state==5
           sleep =sleep+c+1;
           c = 0;
           if sleep/fs >= 0.400
               state = 0;
               sleep = 0;%look for the next peak
           end  
       end
      
      % update the online buffer by removing the oldest sample
      buffer_long(1)=[];
      
      
  end
  
end


%%% Extract features from P-waves
Pint = [];
Pstddev = [];
Ppeak = [];
PFreq = [];
PS = [];
for pdet = 4:size(P_i,2)
    if P_i(pdet)-18 > 0 && P_i(pdet)+18 < size(ecg,1)
    start = P_i(pdet)-18;
    stop =  P_i(pdet)+18;
    
    B = buffer_plot(start:stop);
    Praw = ecg(start:stop);
        Pint = [Pint;abs(trapz(B))];
        Pstddev = [Pstddev;std(Praw)];
        Ppeak = [Ppeak;P_amp(pdet)];
        PFreq = [PFreq ; meanfreq(B,fs)];
        PS = [PS ; nnz(diff(sign(diff(B)))~=0)];
    end
end

Pavg = [Pavg ; mean(Pint)];
Pstd = [Pstd  ; mean(Pstddev)];
PpeakAvg = [PpeakAvg  ; mean(Ppeak)];
PmeanFreq = [PmeanFreq ; mean(PFreq)];
PsgnChgAVG = [PsgnChgAVG ; mean(PS,fs)];
PsgnChgVar = [PsgnChgVar ; var(PS)];

%%% Extract features from R-R wave
RE = [];
RA = [];
RL = [];
RRs = [];
for rdet = 4:size(R_i,2)-1
    start = R_i(rdet);
    stop =  R_i(rdet+1);
    
    B = buffer_plot(start:stop);
    RE = [RE ; wentropy(B,'shannon')];
    RA = approx_entropy(window,0.7,B);
    RL = [RL ; wentropy(B,'log energy')];
    RRs = [RRs;std(B)];
end
RRlogEn = [RRlogEn ; mean(RL)];
REavg = [REavg ; mean(RE)];
RApproxAvg = [RApproxAvg ; mean(RA)];
RstdDev = [RstdDev ; mean(RRs)];

%%% Extract feature from R-R length
RRlen = [];
for rr = 4:numel(R_i)-3
    RRlen = [RRlen R_i(rr+1)-R_i(rr)];
end
RRlenAvg = [RRlenAvg ; mean(RRlen)];

%label(smp)
%% conditions
R_R = diff(R_i); % calculate the distance between each R wave
heart_rate=length(R_i)/(time_scale/60); % calculate heart rate
HR = [HR ; heart_rate];

end
DAT = [HR Pavg REavg RApproxAvg RRlenAvg Pstd RRlogEn PpeakAvg PmeanFreq PsgnChgAVG PsgnChgVar RstdDev];
save DAT