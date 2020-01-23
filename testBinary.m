clc;
%%% Reading Audio
r = audiorecorder(44100, 16, 2, 0);
disp('Start Recording...');
recordblocking(r, 2); %%% recording 2 sec
disp('End of Recording.');
audio_data = getaudiodata(r);
orig_size = size(audio_data);


a100 = audio_data(100)
a100_bin = dec2bin(typecast(single(audio_data(100)), 'uint8'), 8) - '0'
a100_new = typecast( uint8(bin2dec( char(a100_bin + '0') )), 'single' )
