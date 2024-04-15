classdef DistortionSetting < int8
    % DISTORTION TYPES FOR DROPDOWN
    enumeration
        FuzzEXP         (0)
        GLORPY          (1)
        RECTANGLE       (2)
        HARDCLIP        (3)
        SATDOWN         (4)
        HARMONIC        (5)
    end
end
