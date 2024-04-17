classdef distALG < handle
    
    properties
        type = "" % Distortion Type
        last_sample = 0; % Last Sample
        z2_sample = 0; % last last sample
        drywet_log = 0; % DryWet As Log
        sat = 0; % Saturaton
    end
    
    methods
        function obj = distALG(type, sat)
            % Constructor
            obj.type = type; % Set Type
            obj.sat = sat; % Set Saturation
            %obj.drywet_log = (.001*10^(3*obj.sat/100)); % Define DryWet 
            
        end


        
        function out = distort(obj,in)
            if obj.type == 0 % Fuzzexp
                    % This algorithm takes inspiration and is modified from
                    % FEXP2 from Will Pirkle - Designing Audio Effect Plugins in C++: For AAX, AU, and VST3 with DSP Theory 
                    % Page 548
                    % ISBN : 9780429954320
                    % It was modified primarily to allow for the saturation
                    % control 
                    out = (1 - exp(1)^(-abs(obj.sat * in))) / (1 - (exp(1)^-obj.sat));
                    if in < 0
                        out = -out;
                    end
            elseif  obj.type == 1 % glorpy

                out = sin(exp(in * obj.sat) * sin(sin((exp(1) * in)+ (abs(in^2) * obj.sat))));

            elseif obj.type == 2 % Rectangle

                    out = (abs(in)) + (abs(-in));

                   
            elseif obj.type == 3 % hardclip

                    in_mod = in * (obj.sat*2);
                    if in_mod > 1
                        out = 1;
                    elseif in_mod < -1
                        out = -1;
                    else
                        out = in_mod;
                    end

            elseif obj.type == 4 % SAT

                    dist = (obj.sat / 3.333);
                    if in * dist > 1
                        out = dist;
                    elseif in < -1
                        out = -dist;
                    else
                        out = in * dist;
                    end

            elseif  obj.type == 5 % HARMONIC

                dist = obj.sat * 10;
                
                out = tanh((dist * in^2) + (dist * in^4) + (dist * in^6) + (dist* in^8) + (dist * in^10) ...
                    + (dist * in^12) + (dist * in^14) + (dist * in^16) + (dist * in^18) + (dist * in^20) ...
                    + (dist * in^22) + (dist * in^24) + (dist * in^26) + (dist * in^28) + (dist * in^30) ...
                    + (dist * in^32));

            % UNUSED / PROTOTYPE DISTORTION TYPES
            elseif  obj.type == 6
                out = sawtooth(obj.sat*100) * in;
            elseif obj.type == 7
                out = sin(obj.sat) * in^round(obj.sat);
            
            
            elseif obj.type == 8
                    out = obj.last_sample;
            
            else
                out = in;
            end
            obj.last_sample = in;
            obj.z2_sample = obj.last_sample;
            
        end
        
        % UPDATE DISTORTION TYPE
        function update_type(obj,new_type)
            obj.type = new_type;
        end
        % UPDATE SATURATION
        function update_sat(obj, new_sat)
            obj.sat = new_sat;
        end
    end
end

