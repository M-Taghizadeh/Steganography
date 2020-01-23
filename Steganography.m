clear all;
close all;
clc;

%%% Reading Audio
r = audiorecorder(44100, 16, 2, 0);
disp('Start Recording...');
recordblocking(r, 2); %%% recording 2 sec
disp('End of Recording.');
audio_data = getaudiodata(r);
audio_binary = dec2bin(typecast(single(audio_data(:)), 'uint8'), 8) - '0';
orig_size = size(audio_data);
voice_size = orig_size(1);
audio_binary_vector = audio_binary(:);
len_voice_samples = numel(audio_binary_vector);

%%% Reading Video
[fname path] = uigetfile('*.mp4');
fname = strcat(path, fname);
fin = fname;
avi = VideoReader(fin);
nFrames = avi.NumberOfFrames - 1; %%% or floor(avi.Duration * avi.FrameRate)
vidHeight = avi.Height;
vidWidth = avi.Width;

%%% Preallocate movie structure.
disp('Start encoding..');
frame_list(1 : nFrames) = struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'), 'colormap', []); % struct is an array with 2 columns(data, colormap) with 2 value for each columns

%%% calculate number of bitplanes : 
number_of_bitplanes = ceil(len_voice_samples / (vidHeight * vidWidth));

count = 1;
for k = 1:nFrames
	frame_list(k).cdata = read(avi, k);
    im = frame_list(k).cdata;
    if k==1
        %%% embedding number of bit planes into image
        im(1, 1, 1) = number_of_bitplanes;
        
        %%% embedding voice size into image
        str_tmp = num2str(voice_size);
        im(1, 1, 2) = numel(str_tmp);
        for i = 1:numel(str_tmp)
            im(1, i, 1) = str_tmp(i);
            str_tmp(i)
        end
    else
        %%% ncode voice samples into n bitplanes
        if(count<=len_voice_samples)
            if(k<=number_of_bitplanes + 1)
                %%% separate 3 channel of image 
                rc = im(:, :, 1);
                gc = im(:, :, 2);
                bc = im(:, :, 3);
                rcbin = de2bi(rc, 8); %%% change image from decimal to binary 8
                lsb_bitplane = rcbin(:, 1); %%% LSB bit plane (column1):

                %%%ncoding process :
                for z = 1:size(lsb_bitplane)
                    if(count <= len_voice_samples)
                        lsb_bitplane(z) = audio_binary_vector(count);
                        count = count + 1;
                    end
                end

                %%% reconstructe ncoded image(red channel)
                simage = zeros(size(rc));
                for i = 1:8
                    if i == 1
                        x = lsb_bitplane;
                    else
                        x = rcbin(:, i);
                    end
                    x = reshape(x, size(rc));
                    simage = simage + double(x)*2^(i-1);
                end
                %%% concat 3 channel of image (red channel and green channel and blue channel)
                im = cat(3,simage,gc,bc);
            end
        end
        
    end % end of if(k==1)
    
    frame_list(k).cdata = im;
end

%%% createing new video file :
disp('creating video file');
writerObj = VideoWriter('newVideo.avi', 'Uncompressed AVI');
writerObj.FrameRate = avi.FrameRate;
open(writerObj);

for k = 1 : 1 : nFrames
    writeVideo(writerObj, frame_list(k));
end

close(writerObj);
