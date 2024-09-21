function varargout = stft(x,varargin)
narginchk(1,12);
if coder.target('MATLAB') % For MATLAB
    nargoutchk(0,3);
else
    nargoutchk(1,3);
end

%---------------------------------
% Parse inputs
[data,opts,timeDimension] = signal.internal.stft.stftParser('stft',x,varargin{:});

% No convenience plot for multichannel signals
coder.internal.errorIf(nargout == 0 && (opts.NumChannels >1),...
    'signal:stft:InvalidNumOutputMultiChannel');

%---------------------------------
% Compute STFT

if coder.target('MATLAB')
    [S,F,T] = computeSTFT(data,opts);
else
    
    allConst = coder.internal.isConst(data) && coder.internal.isConst(opts);
    
    if ~allConst && signalwavelet.internal.isGPUCoder()
        [S,F,T] = signal.internal.stft.computeSTFT_GPUCoder(data,opts);
    else % CPU code generation
        [S,F,T] = computeSTFT(data,opts);
    end
end
%---------------------------------
% Set outputs

% Format time output
if coder.target('MATLAB') && ~isempty(opts.InitialDate)
    % Set times to datetime format if time information is in datetimes
    T = seconds(T)+opts.InitialDate;
end

% Convenience plot
if coder.target('MATLAB') && nargout==0
    signal.internal.stft.displaySTFT(T,F,S,opts);
end


% Set varargout. The if statement has been changed from acrosscol
%to downrows so that optimal code is generated for the default case.
%GPU Coder doesn't give optimal code for downrows as of now
if nargout >= 1
    if strcmp(timeDimension,'downrows')
        varargout{1} = permute(S,[2,1,3]);
    else
        varargout{1} = S;
    end
end
if nargout >= 2
    if opts.IsNormalizedFreq
        varargout{2} = F.*pi; % rad/sample
    else
        varargout{2} = F;
    end
end
if nargout == 3
    if coder.target('MATLAB') && isnumeric(T) && ~isempty(opts.TimeUnits)
        T = duration(0,0,T,'Format',opts.TimeUnits);
    end
    % Ensure time output is a column vector
    varargout{3} = T(:);
end

end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Helper functions
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [S,F,T] = computeSTFT(x,opts)
% Computes the short-time Fourier transform
classCast = class(x);

% Set variables
nx = opts.DataLength;
win = opts.Window;
nwin = opts.WindowLength;
noverlap = opts.OverlapLength;
nfft = opts.FFTLength;
Fs = opts.EffectiveFs;


% Place x into columns and return the corresponding central time estimates
[xin,t] = signal.internal.stft.getSTFTColumns(x,nx,nwin,noverlap,Fs);

% Apply the window to the array of offset signal segments and perform a DFT
[S,f] = computeDFT(bsxfun(@times,win,xin),nfft,Fs);

% Outputs format ('centered', 'onesided', 'twosided')
[S,f] = signal.internal.stft.formatSTFTOutput(S,f,opts);

% Scale frequency and time vectors in the case of normalized frequency
if opts.IsNormalizedFreq
    t = t.*opts.EffectiveFs; % samples
end

% Set outputs
F = cast(f(1:size(S,1)),classCast); % specify the index for codegen
T = cast(t(1:size(S,2)),classCast);

end
