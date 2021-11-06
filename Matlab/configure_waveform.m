function waveform_params = configure_waveform(varargin)
% CONFIGURE_WAVEFORM cree une structure de parametres de la parte mise en
% forme du signal (TX et RX)
%
% WAVEFORM_PARAMS = CONFIGURE_WAVEFORM(FE, FEI, DS, FILTER_ROLLOFF, FILTER_SPAN, M, PHI0)
% construit WAVEFORM_PARAMS a partir des parametres suivants :
% FE : frequence d'echantillonnage (canal) - DEFAUT 4e6
% FEI : Frequence intermediaire en sortie de filtre adapte - DEFAUT 2e6
% DS : Debit symbole - DEFAUT 1e6
% FILTER_ROLLOFF : rolloff du filtre en racine de cosinus sur-eleve - DEFAUT 0.35
% FILTER_SPAN : etendue du filtre en racine de cosinus sur-eleve  - DEFAUT 4
% M : Ordre de la PSK (2, 4 ou 8) - DEFAUT 4
% PHI0 : Phase initiale de la PSK  - DEFAUT pi/4

if nargin < 1
    Fe = 4e6;
else
    Fe = varargin{1};
end

if nargin < 2
    Fei = 2e6;
else
    Fei = varargin{2};
end

if nargin < 3
    Ds = 1e6;
else
    Ds = varargin{3};
end

if nargin < 4
    filter_rolloff = 0.35;
else
    filter_rolloff = varargin{4};
end

if nargin < 5
    filter_span = 8;
else
    filter_span = varargin{5};
end

if nargin < 6
    M=4;
else
    M = varargin{2};
end

if nargin < 7
    phi0=pi/4;
else
    phi0 = varargin{3};
end

waveform_params.sim.Fe = Fe;        % Frequence d'echantillonnage
waveform_params.sim.Ds = Ds; % Sampling frequency (Hz)

Fse = floor(Fe/Ds);
Fsei = floor(Fei/Ds);

waveform_params.sim.Fse = Fse;   % sapn du filtre de mise en forme
waveform_params.sim.Fsei = Fsei;   % sapn du filtre de mise en forme

% Parametres du filtre de mise en forme
% -------------------------------------------------------------------------
waveform_params.txflt.RolloffFactor          = filter_rolloff; % roll-off du filtre de mise en forme
waveform_params.txflt.FilterSpanInSymbols    = filter_span;   % span du filtre de mise en forme
waveform_params.txflt.OutputSamplesPerSymbol = Fse;   % sapn du filtre de mise en forme
% -------------------------------------------------------------------------


% Parametres du filtre adapté
% -------------------------------------------------------------------------
waveform_params.rxflt.RolloffFactor          = filter_rolloff; % roll-off du filtre de mise en forme
waveform_params.rxflt.FilterSpanInSymbols    = filter_span;   % span du filtre de mise en forme
waveform_params.rxflt.InputSamplesPerSymbol  = Fse;   % Nombre d'echantillons par symboles
waveform_params.rxflt.DecimationFactor       = floor(Fse/Fsei);   % Facteur de sous-échantillonnage
waveform_params.rxflt.DecimationOffset       = 0;   % Phase du sous-échantillonnage
% -------------------------------------------------------------------------


switch M
    case 2
        waveform_params.mod.Name = 'BPSK';
    case 4
        waveform_params.mod.Name = 'QPSK';
    case 8
        waveform_params.mod.Name = '8PSK';
    otherwise
        error('Ce code ne fonctionne que pour des BPSK, QPSK, et 8PSK');
end
waveform_params.demod.Name = waveform_params.mod.Name;

% Parametres de la modulation numérique
% -------------------------------------------------------------------------
waveform_params.mod.ModulationOrder = M; % Taille de la modulation
waveform_params.mod.ModulationBPS   = log2(waveform_params.mod.ModulationOrder); % Nombre de bits par symboles
waveform_params.mod.PhaseOffset     = phi0; % Phase initiale nulle
waveform_params.mod.SymbolMapping   = 'Gray'; % Mapping de Gray
waveform_params.mod.BitInput        = true;
% -------------------------------------------------------------------------


% Parametres de la modulation numérique
% -------------------------------------------------------------------------
waveform_params.demod.ModulationOrder = M; % Taille de la modulation
waveform_params.demod.ModulationBPS   = log2(waveform_params.demod.ModulationOrder); % Nombre de bits par symboles
waveform_params.demod.PhaseOffset     = phi0; % Phase initiale nulle
waveform_params.demod.SymbolMapping   = 'Gray'; % Mapping de Gray
waveform_params.demod.BitOutput        = true;
waveform_params.demod.DecisionMethod  = 'Log-likelihood ratio';
waveform_params.demod.Variance        = 1;
% -------------------------------------------------------------------------