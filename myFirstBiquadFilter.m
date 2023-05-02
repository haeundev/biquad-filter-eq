classdef myFirstBiquadFilter < audioPlugin
    properties
        Gain = 0
        Frequency = 1000
        Q = 0.707
    end
    properties (Constant)
        PluginInterface = audioPluginInterface( ...
            audioPluginParameter('Gain', 'Mapping', {'lin', -60, 24}), ...
            audioPluginParameter('Frequency', 'Mapping', {'log', 20, 20000}), ...
            audioPluginParameter('Q', 'Mapping', {'lin', 0.1, 10}));
    end
    
    properties (Access = private)
        a = [1 0 0]
        b = [1 0 0]
    end
    
    properties (Access = private)
        z = [0 0; 0 0]
    end
    
    methods
        function out = process(plugin, in)
            plugin.designParametricEQ()
            [out, plugin.z] = filter(plugin.b, plugin.a, in, plugin.z);
        end
        
        function reset(plugin)
            plugin.z = zeros(size(plugin.z));
        end
    end
    
    methods (Access = private)
        function designParametricEQ(plugin)
            A = sqrt(10^(plugin.Gain/20));
            w0 = 2*pi*plugin.Frequency/getSampleRate(plugin);
            alpha = sin(w0)/(2*plugin.Q);
            
            plugin.b(1) = 1 + alpha*A;
            plugin.b(2) = -2*cos(w0);
            plugin.b(3) = 1 - alpha*A;
            plugin.a(1) = 1 + alpha/A;
            plugin.a(2) = -2*cos(w0);
            plugin.a(3) = 1 - alpha/A;
            
            plugin.b = plugin.b/plugin.a(1);
            plugin.a = plugin.a/plugin.a(1);
        end
    end
end
