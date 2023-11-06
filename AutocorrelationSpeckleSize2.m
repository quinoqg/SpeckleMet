%Autocorrelation function, created by J Bobin,  29/10/23

% Load the speckle pattern image 
input_image = imread('Speckle2A.jpg');

% Convert the input image to double precision
input_image = double(input_image);

% Calculate the autocorrelation function
[n, m] = size(input_image);
N = n*m; %Total number of pixels
autocorr = zeros(1,200);

image_vect = reshape(input_image,[1,N]);
image_squared = image_vect.^2; %Formula for autocorrelation
index = 1; %To fill autocorrelation array

for u = -100:100 %Range of u-values

    image_transformed = circshift(image_vect,u); %Shift elements by u, this is the horizontal transformation

    autocorr(index) = sum((image_vect.*image_transformed))/sum(image_squared);

    index = index + 1;


end

% Find the feature size (width) at y = 0.95

u = -100:100;

autocorr_coeffs = polyfit(u,autocorr,99);
autocorr_val = -0.95;
autocorr_solver = cat(2,autocorr_coeffs,autocorr_val);

% Estimate the feature size

autocorr_roots = roots(autocorr_solver);

%Difference between root values closest to zero will give feature size.

abs_array = abs(autocorr_roots);
[sorted_values, sorted_indices] = sort(abs_array);

% The two closest values to zero are at indices sorted_indices(1) and sorted_indices(2)
closest_values = sorted_values(1:2);

% Calculate the difference between the two closest values - this gives
% estimate of feature size.
feature_size = abs(closest_values(1) - closest_values(2));


% Display the autocorrelation function
figure;
plot(u,autocorr);
title('Autocorrelation Function');
xlabel('Shift (u)');
ylabel('Normalized Autocorrelation');

% Display the estimated feature size in string output
disp(['Estimated Feature Size: ', num2str(feature_size)]);