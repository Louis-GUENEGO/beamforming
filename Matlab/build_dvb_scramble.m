function dvb_scramble = build_dvb_scramble()
scrambler  = comm.Scrambler(...
    'CalculationBase', 2,...
    'Polynomial',[0,-14,-15],...
    'InitialConditions',[1 0 0 1 0 1 0 1 0 0 0 0 0 0 0]);        

frame_sz = 8*8*188;
pckt_sz = 188*8;

scramble_sequence = step(scrambler,zeros(frame_sz-8,1));
scrambler_enable = ones(size(scramble_sequence));

for i_pckt = 0:6
    scrambler_enable((pckt_sz-8) + i_pckt*pckt_sz + (1:8)) = 0;
end

dvb_scramble_bit = scramble_sequence & scrambler_enable;

dvb_scramble = uint8([255; bi2de(reshape(dvb_scramble_bit,8,[])','left-msb')]);
% -------------------------------------------------------------------------

