function [fadedSamples, gain]=ApplyFading(inputSamples, fadingModel, maxDelaySpreadInSamples) 

    % fadingModel = 0 is no fading
    % fadingModel = 1 is uniform profile
    % fadingModel = 11 is uniform profile with constant gain ( for testing)
    % fadingModel = 2 is Exponential profile
    % fadingModel = 22 is Exponential profile with constant gain ( for testing)

    numPaths=maxDelaySpreadInSamples;
    if fadingModel == 0
        % No fading is applied, go back
        fadedSamples = inputSamples ;
        gain=1;
        return
    elseif fadingModel == 1 | fadingModel == 11
     % Uniform Power Profile  
        variance(1:numPaths)=1/numPaths ;
    elseif fadingModel == 2 | fadingModel == 22
    % Exponential Power Profile :
       % variance(1) = (1.0 - exp(-1.0/numPaths)) / (1.0 - exp(-1));
        variance(1)=1.0;
        variance(2:numPaths)= variance(1) .* exp(-(2:numPaths)/numPaths);
    end
    
    variance=variance/sum(variance);
    sumPower=sum(variance) ;
    
    if fadingModel == 11 | fadingModel == 22
        gain(1:numPaths)=sqrt(variance(1:numPaths));
    else
        gain(1:numPaths)=(randn(1,numPaths)+ 1j*randn(1,numPaths)) .* sqrt(variance(1:numPaths)/2);
    end

    fadedSamples=conv(inputSamples, gain);
    
    %fadedSamples=0;
    %for n=1 : numPaths
    %    fadedSamples = fadedSamples + ...
    %        gain(n)* ...
    %        [zeros(1,(n-1)*numSamplesPerSymbol) inputSamples zeros(1,(numPaths-n)*numSamplesPerSymbol) ];
    %end 

    
     
 end