classdef StateQ1 < uint8
    enumeration
        HEALTHY         (0)
        IN_QUARANTINE   (1)
        INFECTED        (2)
        SICK            (3)
        INFECTED_SICK   (4)
        IN_HOSPITAL     (5)
        RECOVERED       (6)
        DEAD            (7)
    end
end
