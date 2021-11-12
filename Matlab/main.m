clear
close all
clc

% disconnects and deletes all instrument objects (serial port)
instrreset

%% Parametres des objets participant a l'emetteur
% Parametre du flux TS
% -------------------------------------------------------------------------
tx_vid_fname   = 'tx_stream.ts';  % Fichier contenant le message a transmettre
rx_vid_prefix  = 'rx_stream';  % Fichier contenant le message a transmettre
msg_oct_sz     = 188;
msg_bit_sz     = msg_oct_sz*8; % Taille de la payload des paquets en bits
pckt_per_frame = 8;
frame_oct_sz   = pckt_per_frame * msg_oct_sz;
frame_bit_sz   = 8*frame_oct_sz; % Une trame = 8 paquets
store_rx_vid   = false;
% -------------------------------------------------------------------------

%% Creation des structures de parametres
waveform_params        = configure_waveform(1e6,0.25e6,0.25e6); % Les parametres de la mise en forme
coding_params.code_rate  = 0.5*(188)/204;

channel_params         = configure_channel(waveform_params, coding_params, 0:0.25:10,0,0,1,0); % Les parametres du canal
[tx_filter, rx_filter] = build_flt(waveform_params); % La couche de mise en forme

%% Cr?ation des objets
[mod_psk, demod_psk]                   = build_mdm(waveform_params); % Construction des modems
dvb_scramble                           = build_dvb_scramble(); %Construction du scrambler
[awgn_channel, doppler, channel_delay] = build_channel(channel_params, waveform_params); % Blocs du canal
stat_erreur                            = comm.ErrorRate('ReceiveDelay', 2*frame_bit_sz,'ComputationDelay',2*frame_bit_sz); % Calcul du nombre d'erreur et du BER
mac_sync_delay                         = dsp.Delay(752); %

% Parametres du code convolutif et du decodeur
% -------------------------------------------------------------------------
cc_treillis = poly2trellis(7,[171,133]); % Definition du treillis
viterbi_traceback_length = 35;%204*8; % Taille de la fenetre pour Viterbi
% -------------------------------------------------------------------------

%%  Construction des objets
% Construction de l'encodeur convolutif
% -------------------------------------------------------------------------
cc_enc = comm.ConvolutionalEncoder('TrellisStructure',cc_treillis);
% -------------------------------------------------------------------------

% Construction du decodeur de Viterbi
% -------------------------------------------------------------------------
cc_dec = comm.ViterbiDecoder(...
    'TrellisStructure', cc_treillis,...
    'InputFormat', 'Unquantized',...
    'TracebackDepth', viterbi_traceback_length,...
    'TerminationMethod', 'Continuous');
% -------------------------------------------------------------------------
K_RS = 239;
N_RS = 255;
S_RS = 188;

gp = rsgenpoly(N_RS,K_RS,[],0);
rs_enc = comm.RSEncoder('ShortMessageLength', S_RS, 'CodewordLength', N_RS, 'MessageLength',K_RS,'BitInput', false, 'GeneratorPolynomial', gp);
rs_dec = comm.RSDecoder('ShortMessageLength', S_RS, 'CodewordLength', N_RS, 'MessageLength',K_RS,'BitInput', false, 'GeneratorPolynomial', gp);


cv_itl   = comm.ConvolutionalInterleaver('NumRegisters',12,'RegisterLengthStep',17);
cv_deitl = comm.ConvolutionalDeinterleaver('NumRegisters',12,'RegisterLengthStep',17);
rs_sync_delay                         = dsp.Delay(204*8-35);

% Conversions octet <-> bits
o2b = OctToBit();
b2o = BitToOct();

% Lecture octet par octet du fichier video d'entree
message_source = BinaryFileReader(...
    'Filename', tx_vid_fname,...
    'SamplesPerFrame', msg_oct_sz*pckt_per_frame,...
    'DataType', 'uint8');

% Ecriture octet par octet du fichier video de sortie

message_destination = BinaryFileWriter('DataType','uint8');

%%
ber = zeros(1,length(channel_params.EbN0dB));
Pe = qfunc(sqrt(2*channel_params.EbN0));
tx_rx_flt_delay = frame_bit_sz;% - waveform_params.rxflt.FilterSpanInSymbols*waveform_params.mod.ModulationBPS;
%% Preparation de l'affichage
figure(1)
semilogy(channel_params.EbN0dB,Pe);
hold all
h_ber = semilogy(channel_params.EbN0dB,ber,'XDataSource','channel_params.EbN0dB', 'YDataSource','ber');
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('$P_b$, TEB','Interpreter', 'latex', 'FontSize',14)
legend({'$P_b$ (Th\''eorique)', 'TEB (Exp\''erimentale)'}, 'Interpreter', 'latex', 'FontSize',14);

msg_format = '|   %7.2f  |   %7d   |  %7d | %2.2e |  %8.2f kO/s |   %8.2f kO/s |\n';

fprintf(      '|------------|-------------|----------|----------|----------------|-----------------|\n')
msg_header =  '|  Eb/N0 dB  |   Bit nbr   |  Bit err |   TEB    |    Debit Tx    |     Debit Rx    |\n';
fprintf(msg_header);
fprintf(      '|------------|-------------|----------|----------|----------------|-----------------|\n')




%% Simulation
for i_snr = 1:length(channel_params.EbN0dB)
    instrreset
    %s = serial('/dev/ttyUSB1'); % Linux
    s = serial('COM4'); % Windows
    %s.Baudrate=115200;
    %s.Baudrate=256000;
    s.Baudrate=921600;
    s.StopBits=1;
    s.Parity='none';
    s.FlowControl='none';
    s.TimeOut = 1;
    s.OutputBufferSize = 1000000;
    s.InputBufferSize = 5000000;
    fopen(s);
    
    
    if store_rx_vid
        message_destination.release;
        message_destination.Filename = [rx_vid_prefix, num2str(channel_params.EbN0dB(i_snr)),'dB.ts'];
    end
    reverseStr = ''; % Pour affichage en console
    awgn_channel.EsNo=channel_params.EsN0dB(i_snr);% Mise a jour du EbN0 pour le canal
    
    stat_erreur.reset; % reset du compteur d'erreur
    err_stat = [0 0 0];
    
    tb_file = fopen('message_source.txt','w');
    
    tb_frame_nb = 3;
    T_rx = 0;
    T_tx = 0;
    while (err_stat(2) < 100 && err_stat(3) < 1e6)

        message_source.reset;        
        while(~message_source.isDone)
            % Emetteur
            tic
            tx_oct     = step(message_source); % Lire une trame
            
            
            
            
            
            
            
            
            
            
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            %% SOFTWARE ONLY
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            
%             tx_scr_oct = bitxor( tx_oct, dvb_scramble);
%             tx_rs_oct  = step  ( rs_enc, tx_scr_oct  ); % Encodage RS
%             tx_itl_oct = step  ( cv_itl, tx_rs_oct   ); % Entrelaceur
%             tx_itl_bit = step  ( o2b   , tx_itl_oct  ); % Octets -> Bits
%             tx_cc      = step  ( cc_enc, tx_itl_bit  ); % Encodage Convolutif
%            
%             % generate test vectors for VHDL simulation
%             if( tb_frame_nb ~=0)
%                fprintf(tb_file, '%d \n', tx_oct);
%                tb_frame_nb = tb_frame_nb-1;
%             end
            




%             %%%%%%%%%%%%%%%%%%%%%%%%%%
%             %% HARDWARE IN THE LOOP
%             %%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%
%             % RS + ITL + CC
%             
%             tx_scr_oct = bitxor(tx_oct, dvb_scramble); % scrambler
%             
% %             %generate test vectors for VHDL simulation
% %             if( tb_frame_nb ~=0)
% %                fprintf(tb_file, '%d \n', tx_scr_oct);
% %                tb_frame_nb = tb_frame_nb-1;
% %             end
%             
%             fwrite(s, tx_scr_oct);
%             cc_hw = uint8((fread(s, 8*pckt_per_frame*204))); % 13056
%             cc_hw_bin = de2bi(cc_hw,2,'left-msb');
%             tx_cc = reshape(cc_hw_bin',numel(cc_hw_bin),1);
%             %%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            %% ITL + CC
            tx_scr_oct = bitxor( tx_oct, dvb_scramble); % scrambler
            tx_rs_oct  = step  ( rs_enc, tx_scr_oct  ); % Encodage RS
            
%             %generate test vectors for VHDL simulation
%             if( tb_frame_nb ~=0)
%                fprintf(tb_file, '%d \n', tx_rs_oct);
%                tb_frame_nb = tb_frame_nb-1;
%             end
            
            fwrite(s, tx_rs_oct);
            cc_hw = uint8((fread(s, 8*pckt_per_frame*204))); % 13056
            cc_hw_bin = de2bi(cc_hw,2,'left-msb');
            tx_cc = reshape(cc_hw_bin',numel(cc_hw_bin),1);
            
            
            
            
            
            %% CC
%             tx_scr_oct = bitxor( tx_oct, dvb_scramble); % scrambler
%             tx_rs_oct  = step  ( rs_enc, tx_scr_oct  ); % Encodage RS
%             %tx_itl_bit = step  ( o2b   , tx_rs_oct  ); % Octets -> Bits
%             tx_itl_oct = step  ( cv_itl, tx_rs_oct   ); % Entrelaceur
%           
%             %generate test vectors for VHDL simulation
%             if( tb_frame_nb ~=0)
%                fprintf(tb_file, '%d \n', tx_itl_oct);
%                tb_frame_nb = tb_frame_nb-1;
%             end
%             
%             %tx_itl_bin = step  (o2b, tx_itl_oct);
%             fwrite(s, tx_itl_oct );
%             cc_hw = uint8((fread(s, 8*pckt_per_frame*204))); % 13056
%             cc_hw_bin = de2bi(cc_hw,2,'left-msb');
%             tx_cc = reshape(cc_hw_bin',numel(cc_hw_bin),1);          

            %%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
          
            tx_sym     = step(mod_psk,  tx_cc); % Modulation QPSK
            T_tx       = T_tx+toc;
            %% Canal
            tx_sps_dpl = step(doppler, tx_sym); % Simulation d'un effet Doppler
            rx_sps_del = step(channel_delay, tx_sps_dpl, channel_params.Delai); % Ajout d'un retard de propagation
            rx_sps     = step(awgn_channel,channel_params.Gain * rx_sps_del); % Ajout d'un bruit gaussien
            
            %% Recepteur
            tic
            
            rx_scr_llr = step(demod_psk,rx_sps);% Ce bloc nous renvoie des LLR (meilleur si on va interface avec du codage)
            
            rx_dec_bit = step(cc_dec,rx_scr_llr); % Viterbi decoding
            rx_dec_sync = step(rs_sync_delay,rx_dec_bit);
            rx_rs_oct = step(b2o, rx_dec_sync); % bin 2 oct
            rx_oct_deitl = step(cv_deitl, rx_rs_oct );
            rx_msg_oct = step(rs_dec, rx_oct_deitl);
            rx_scr_sync = step(mac_sync_delay, rx_msg_oct); % synchronisation couche acces.
            rx_oct      = bitxor(rx_scr_sync,dvb_scramble); % descrambler
            
            T_rx        = T_rx + toc;
            %% Compate des erreurs binaires
            tx_bit     = step(o2b,tx_oct);
            rx_bit     = step(o2b,rx_oct);
            err_stat   = step(stat_erreur, tx_bit, rx_bit);
            
            %% Destination
            if store_rx_vid
                step(message_destination, rx_oct); % Ecriture du fichier
            end
        end
        msg = sprintf(msg_format,channel_params.EbN0dB(i_snr), err_stat(3), err_stat(2), err_stat(1), err_stat(3)/8/T_tx/1e3, err_stat(3)/8/T_rx/1e3);
        fprintf(reverseStr);
        msg_sz =  fprintf(msg);
        reverseStr = repmat(sprintf('\b'), 1, msg_sz);
    end
    if err_stat(2) == 0
        break
    end
    ber(i_snr) = err_stat(1);
    refreshdata(h_ber);
    drawnow limitrate
end
fprintf(      '|------------|-------------|----------|----------|----------------|-----------------|\n')