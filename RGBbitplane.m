%%% reading audio
wavdata = audioread('C:\Users\Zanis\Desktop\Matlab Project\Matlab Final Project\Files\ahhh.mp3');
wavbinary = dec2bin(typecast(single(wavdata(:)), 'uint8'), 8) - '0';
wavbinary_reshaped = wavbinary(:);

%%% reading image
im = imread('C:\Users\Zanis\Desktop\Matlab Project\Files\001.jpg');
%%% separate 3 channel of image 
rc = im(:, :, 1);
gc = im(:, :, 2);
bc = im(:, :, 3);

%%% calculate number of bitplanes
number_of_bitplanes = ceil(size(wavbinary_reshaped) / numel(rc));

%%% change image from decimal to binary 8
rcbin = de2bi(rc, 8);
%figure;
%for i = 1:8
%   x = rcbin(:, i);
%   x = reshape(x, size(rc));
%   subplot(2, 4, i);imshow(x, []);title(num2str(i));
%end


%%% LSB bit plane (column1):
lsb_bitplane = rcbin(:, 1);


%%% ncode wavbinary into lsb bitplane
for i = 1:size(wavbinary_reshaped)
    lsb_bitplane(i) = wavbinary_reshaped(i);
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
figure;imshow(simage, []);title('red channel reconstructed');


%%% concat 3 channel of image (red channel and green channel and blue channel)
image_RGB = cat(3,simage,gc,bc);
