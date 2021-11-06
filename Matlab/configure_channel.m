function channel_params = configure_channel(waveform_params, coding_params, varargin)
% CONFIGURE_CHANNEL cree une structure de parametres du canal
%
% CHANNEL_PARAMS = CONFIGURE_CHANNEL(waveform_params, coding_params, EbN0dB, FrequencyOffset, PhaseOffset, Gain, Delai)
% construit CHANNEL_PARAMS a partir des parametres suivants :
% EbN0dB : liste des valeurs de EbN0 en dB a simuler - DEFAUT 30
% FrequencyOffset : Decalage Frequentiel  - DEFAUT 0
% PhaseOffset : Dephasage  - DEFAUT 0
% Gain : Facteur d'amplification/attenuation - DEFAUT 1
% Delai : retard du au canal - DEFAUT 0

if nargin < 1
    channel_params.EbN0dB = 30;
else
    channel_params.EbN0dB = varargin{1};
end
if nargin < 2
    channel_params.FrequencyOffset = 0;
else
    channel_params.FrequencyOffset = varargin{2};
end
if nargin < 3
    channel_params.PhaseOffset = 0;
else
    channel_params.PhaseOffset = varargin{3};    
end
if nargin < 4
    channel_params.Gain = 1;
else
    channel_params.Gain = varargin{4};    
end
if nargin < 5
    channel_params.Delai = 0;
else
    channel_params.Delai = varargin{5};    
end

channel_params.EbN0   = 10.^(channel_params.EbN0dB/10);
channel_params.EsN0   = channel_params.EbN0 * waveform_params.mod.ModulationBPS * coding_params.code_rate;
channel_params.EsN0dB = 10 * log10(channel_params.EsN0);
