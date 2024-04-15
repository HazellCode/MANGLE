%
%
%  FileName: filters.m
%  Date: 11-Feb-2024
%  Author: SID 2105221
%  Description: All Pass Filter
%  
%
%
classdef APF < handle
    properties
        sdel = 0; % Sample Delay
        ddl = 0; % Delay Line
        idx = 1; % Index
        g = 0; % G Value
        apf_out = 0; % All Pass Output
        temp_in = 0; % Intermediary Storage Value
    end
    methods(Access = private)

    end
    methods(Access = public)
        function obj = APF(sample_delay, g)
               % Define variables based on input values
               obj.sdel = sample_delay;
               obj.ddl = zeros(obj.sdel, 1);
               obj.g = g;
        end
        function out = calc(obj,in)
            % Calculate All Pass filter
            obj.temp_in = in + (obj.ddl(obj.idx) * obj.g);
            obj.apf_out = (obj.temp_in * -obj.g) + obj.ddl(obj.idx);
            obj.ddl(obj.idx) = obj.temp_in;
            % Output
            out = obj.apf_out;
        end
        function out = calcMod(obj,in, read) % Alternative Calculation function that takes the read position as an input
            obj.temp_in = in + (obj.ddl(read) * obj.g);
            obj.apf_out = (obj.temp_in * -obj.g) + obj.ddl(read);
            obj.ddl(obj.idx) = obj.temp_in;
            out = obj.apf_out;
        end
        % Incremention the index
        function inc(obj)
            obj.idx = obj.idx + 1;
            if obj.idx > obj.sdel
                obj.idx = 1;
            end
        end
        % GETTER FUNCTIONS
        function out = get_del(obj)
            % Return Sample Delay
            out = obj.sdel;
        end
        function out = read(obj)
            % Return current value of all pass
            out = obj.apf_out;
        end
        function out = get_idx(obj)
            % return sample index
            out = obj.idx;
        end
        
        
    end
end