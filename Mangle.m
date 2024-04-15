classdef Mangle < audioPlugin
    %MANGLE 
    %   Weird Distortion plugin
    %   SID: 2105221
    %   
    
    properties
        distortionL = 0; % Distortion Left Object
        distortionR = 0; % Distortion Right Object
        distortionL_out = 0; % Dist L Out
        distortionR_out = 0; % Dist R Out
        distortionsetting = DistortionSetting.RECTANGLE; % Dist Setting Default
        combOptions = CombOptions.Disabled; % Comb Options Setp
        fs = 192000; % Sample Rate Default
        APF1 = 0; % ALL Pass Object

        LCOMB1 = 0; % Left Comb Object
        LCOMB2 = 0; % Left Comb 2 Object
        RCOMB1 = 0; % Right Comb Object
        RCOMB2 = 0;  % Right Comb 2 Object

        noiseL = 0; % Noise Left Storage
        noiseR = 0; % Noise Right Storage
        noise_level = -60; % Default Noise level (dB)
        noise_level_bounded = 0.1000; % Noise level (linear 0-1)
        RT60 = 0.5; % RT60
        SAT = 0; % Saturation
        input_gain = 1; % Input Gain (dB)
        input_gain_normalised = 1.1220; % Input Gain linear (0-1)
        inL = 0; % Input Left
        inR = 0; % Input Right
        mInL = 0; %normalised left input
        mInR = 0; % normalised right input

        output_gain = 1; % outgain (dB)
        output_gain_normalised = 0; % outgain (linear 0-1)
    end

     properties (Constant)
        PluginInterface = audioPluginInterface( ...
                audioPluginParameter('input_gain','Mapping',{'pow',1/3,-140,32},'DisplayName', 'Input Gain', 'Label','dB', 'Style', 'rotaryknob', 'Layout',[2,1],'DisplayNameLocation', 'above'), ...
                audioPluginParameter('combOptions','Mapping',{'enum','Disabled','CombSeries', 'CombParallel', 'SoloComb'},'Style','dropdown','Layout', [2,3],'DisplayName', 'Comb Filter Types','DisplayNameLocation', 'above'), ...
                audioPluginParameter('RT60', 'Mapping', {'lin',0,5},'Style','vslider', 'Layout', [2,5],'DisplayNameLocation', 'above'), ...
                audioPluginParameter('noise_level','Mapping',{'pow',1/3,-60,24},'Style','rotaryknob', 'Layout', [2,7],'DisplayName', 'White Noise Level','DisplayNameLocation', 'above'), ...
                audioPluginParameter('distortionsetting','Mapping',{'enum','FuzzEXP','GLORPY', 'RECTANGLE', 'HARDCLIP', 'SATDOWN', 'HARMONIC'},'Style','dropdown','Layout', [2,9],'DisplayName', 'Distortion Algorithm','DisplayNameLocation', 'above'), ...
                audioPluginParameter('SAT', 'Mapping', {'lin',0,100},'Style','vslider', 'Layout', [2,11],'DisplayName', 'Distortion Intensity','DisplayNameLocation', 'above'), ...
                audioPluginParameter('output_gain','Mapping',{'pow',1/3,-140,32},'DisplayName', 'Output Gain', 'Label','dB', 'Style', 'rotaryknob', 'Layout',[2,13],'DisplayNameLocation', 'above'),...
                audioPluginGridLayout('RowHeight',[25,100,5], 'ColumnWidth', [100,5,115,5,100,5,100,5,115,5,115,1,100]),...
                'VendorName', 'Hazell Design', 'PluginName', 'MANGLE', 'VendorVersion', '1.1.1', 'InputChannels',2,'OutputChannels',2);

        % Define UI Elements
            
    end
    
    methods
        function plugin = Mangle()
             plugin.distortionL = distALG(plugin.distortionsetting, 100); % Instantiate Distortion Object 
             plugin.distortionR = distALG(plugin.distortionsetting, 100); % Instantiate Distortion Object 
             plugin.LCOMB1 = COMB(2000,plugin.RT60,plugin.fs); % Instantiate Comb Object 
             plugin.LCOMB2 = COMB(4000,plugin.RT60,plugin.fs); % Instantiate Comb Object 

             plugin.RCOMB1 = COMB(2000,plugin.RT60,plugin.fs); % Instantiate Comb Object 
             plugin.RCOMB2 = COMB(4000,plugin.RT60,plugin.fs); % Instantiate Comb Object 

             plugin.APF1 = APF(round(0.3 * plugin.fs),0.8); % Instantiate All Pass Object 
        end
        
        function out = process(plugin,in)
            % Define size of buffer
            [N,M] = size(in);
            % Define output array
            out = zeros(N,M);
            % Time loop
            for n = 1:N
                % Normalise input gain
                plugin.mInL = in(n,1)  * plugin.input_gain_normalised;
                plugin.mInR = in(n,2)  * plugin.input_gain_normalised;
                %plugin.distortion.update_type(plugin.distortionsetting)
                % Check what comb setting to use
                if plugin.combOptions == 0
                    plugin.inL = plugin.mInL;
                    plugin.inR = plugin.mInR;
                elseif plugin.combOptions == 1
                    % COMB 1 to COMB 2
                    %% LEFT
                    plugin.inL = plugin.LCOMB2.read();
                    plugin.LCOMB2.calc(plugin.LCOMB1.read());
                    plugin.LCOMB1.calc(plugin.mInL);
                    

                    plugin.LCOMB1.inc;
                    plugin.LCOMB2.inc;

                    %% RIGHT
                    plugin.inR = plugin.RCOMB2.read();
                    plugin.RCOMB2.calc(plugin.RCOMB1.read());
                    plugin.RCOMB1.calc(plugin.mInR);
                    

                    plugin.RCOMB1.inc;
                    plugin.RCOMB2.inc;
                elseif plugin.combOptions == 2
                    % COMB PARALLEL
                    %% LEFT
                    plugin.inL = (0.5 * plugin.LCOMB1.read()) + (0.5 * plugin.LCOMB2.read());
                    plugin.LCOMB1.calc(plugin.mInL);
                    plugin.LCOMB2.calc(plugin.mInL);
                    
                    

                    plugin.LCOMB1.inc;
                    plugin.LCOMB2.inc;

                    %% RIGHT
                    plugin.inR = (0.5 * plugin.RCOMB1.read()) + (0.5 * plugin.RCOMB2.read());
                    plugin.RCOMB1.calc(plugin.mInR);
                    plugin.RCOMB2.calc(plugin.mInR);
                    
                    

                    plugin.RCOMB1.inc;
                    plugin.RCOMB2.inc;

                elseif plugin.combOptions == 3
                    % SOLO COMB
                    %% LEFT
                    plugin.inL = (plugin.LCOMB1.read());
                    plugin.LCOMB1.calc(plugin.mInL);
                    
                    
                    

                    plugin.LCOMB1.inc;
                   

                    %% RIGHT
                    plugin.inR = (plugin.RCOMB1.read());
                    plugin.RCOMB1.calc(plugin.mInR);
                   
                    
                    

                    plugin.RCOMB1.inc;
                  

                end

                
               
                % calculate noise
                plugin.noiseL = randn(1);
                plugin.noiseR = randn(1);
                % aplpy distortion to input with noise
                plugin.distortionL_out = plugin.distortionL.distort(plugin.inL + ((0.01 * plugin.noise_level_bounded) * plugin.noiseL));
                plugin.distortionR_out = plugin.distortionR.distort(plugin.inR + ((0.01 * plugin.noise_level_bounded) * plugin.noiseR));
                % output
                out(n,1) = plugin.distortionL_out * plugin.output_gain_normalised;
                out(n,2) = plugin.distortionR_out * plugin.output_gain_normalised;
                % This was an error but has given the plugin a more broken
                % sound and creates a stereo effect so has been left in.
                plugin.LCOMB1.inc;
                plugin.LCOMB2.inc;
            end
        end

        function reset(plugin)
            plugin.fs = plugin.getSampleRate; % get sample rate
            
            % Noise Gate set default
            noiseGain = 10^(plugin.noise_level/20);
            plugin.noise_level_bounded = noiseGain;

            % Set Default Saturation
            plugin.distortionL.update_sat(plugin.SAT);
            plugin.distortionR.update_sat(plugin.SAT);

            % Set Default in gain
            plugin.input_gain_normalised = 10^(plugin.input_gain/20);

            %Set Default output gain
            plugin.output_gain_normalised = 10^(plugin.output_gain/20);
            
            % Update Combs with sample rate and RT60
            plugin.LCOMB1.update(plugin.RT60, plugin.fs);
            plugin.LCOMB2.update(plugin.RT60, plugin.fs);
            plugin.RCOMB1.update(plugin.RT60, plugin.fs);
            plugin.RCOMB2.update(plugin.RT60, plugin.fs);
        end

        function set.distortionsetting(plugin,val)
           plugin.distortionsetting = val; 
           % Update distortion type
           plugin.distortionL.update_type(val)
           plugin.distortionR.update_type(val)
        end

        function set.noise_level(plugin,val)
            plugin.noise_level = val;
            % Recalculate noise level
            noiseGain = 10^(plugin.noise_level/20);
            plugin.noise_level_bounded = noiseGain;
        end

        function set.SAT(plugin,val)
            plugin.SAT = val;
            % Apply new saturation amount to class
            plugin.distortionL.update_sat(plugin.SAT);
            plugin.distortionR.update_sat(plugin.SAT);
        end

        function set.input_gain(plugin,val)
            plugin.input_gain = val; 
            % calculate new input gain 
            plugin.input_gain_normalised = 10^(plugin.input_gain/20);
        end

        function set.output_gain(plugin,val)
            plugin.output_gain = val; 
            % Calculate new input gain
            plugin.output_gain_normalised = 10^(plugin.output_gain/20);
        end

        function set.RT60(plugin, val)
            plugin.RT60 = val;
            plugin.LCOMB1.update_RT60(plugin.RT60)
            plugin.LCOMB2.update_RT60(plugin.RT60)
            plugin.RCOMB1.update_RT60(plugin.RT60)
            plugin.RCOMB2.update_RT60(plugin.RT60)
        end
    end
end

