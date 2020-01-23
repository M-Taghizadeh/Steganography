clc;
clear all;
close all;
%% Read NCoded Video
[fname path] = uigetfile('*.avi');
fname = strcat(path, fname);
fin = fname;
avi = VideoReader(fin);
nFrames = avi.NumberOfFrames - 1; %%% or floor(avi.Duration * avi.FrameRate)
vidHeight = avi.Height;
vidWidth = avi.Width;

%%% Decoding..
disp('Start Decoding..');
N = 1;
count = 1;
audio_binary_vector = [];
number_of_bitplanes = 1;
k = 1;
while k <= number_of_bitplanes+1
	im = read(avi, k); %%% read cdata of this frame 
    
    if k==1
        %%% decoding number of bitplane from image
        number_of_bitplanes = im(1, 1, 1);

        %%% decoding voice size from image
        numel_str_tmp = im(1, 1, 2);
        for i = 1:numel_str_tmp
            str_tmp(i) = im(1, i, 1);
        end
        voice_size = str2num(char(str_tmp));
        len_voice_samples = voice_size * 2 * 4 * 8; % 2 channel , 32 bit for each sample
        
    else
        %%% decode voice samples into n bitplanes
        if(count<=len_voice_samples)
            if(k<=number_of_bitplanes + 1)
                %%% separate 3 channel of image 
                rc = im(:, :, 1);
                rcbin = de2bi(rc, 8); %%% change image from decimal to binary 8
                lsb_bitplane = rcbin(:, 1); %%% LSB bit plane (column1):
                
                disp(count)
                %%%ncoding process :
                for z = 1:size(lsb_bitplane)
                    if(count <= len_voice_samples)
                        audio_binary_vector(count) = lsb_bitplane(z);
                        count = count + 1;
                    end
                end
            end
        end        
    end % end of if(k==1)
    k = k + 1;
end

orig_size = [voice_size, 2];
audio_binary = reshape(audio_binary_vector, voice_size * 4 * 2, 8); % 2 channel , 32 bit for each sample(4 row and 8 column)
audio_data = reshape( typecast( uint8(bin2dec( char(audio_binary + '0') )), 'single' ), orig_size );
audiowrite('decodedAudio.wav', audio_data, 44100);
plot(audio_data)
