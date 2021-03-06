%First, let's make some series of harmonics added to some noise:
points = 500;
t = linspace(0, .1, points);
f = 444; %angular frequency of signal
offset = 0.8;
no_harmonics = 10;
signal = sin(f*t) + offset;
for i = 2:no_harmonics
    if rand(1) > 0.5
        signal = signal + sin(f*i*t)/i;
    else
        signal = signal - sin(f*i*t)/i;
    end
end

r_noise = randn(1,points)/2; %divide by a number to supress noise

signal = signal + r_noise;

figure()
plot(t, signal)
title("Unfiltered signal")
xlabel("Time")
ylabel("Amplitude")

%Next design the filter to correct all the noise

b = fir1(100,[0.054, 0.058]);
figure()
freqz(b,1,10000)

%Finally perform the filtering and display the result:

processed = filter(b, 1, signal);
figure()
plot(t, processed)
title("Filtered signal")
xlabel("Time")
ylabel("Amplitude")