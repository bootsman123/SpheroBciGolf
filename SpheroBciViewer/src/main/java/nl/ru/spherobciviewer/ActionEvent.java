package nl.ru.spherobciviewer;

/**
 * Action event.
 * @author Bas Bootsma
 */
public enum ActionEvent
{        
    WEBCAM_SHOW,
    WEBCAM_HIDE,
    WEBCAM_LOAD,
    DIRECTION_METER_SHOW,
    DIRECTION_METER_HIDE,
    DIRECTION_METER_RESET,
    DIRECTION_METER_VALUE, // 0 up till 2*pi
    DIRECTION_METER_CLOCKWISE,
    DIRECTION_METER_COUNTER_CLOCKWISE,
    POWER_METER_SHOW,
    POWER_METER_RESET,
    POWER_METER_HIDE,
    POWER_METER_VALUE, // 0 up to 1 
    BASELINE_SHOW,          // Not supported.
    BASELINE_HIDE,          // Not supported.
    TEXT_SHOW, // Text frame pops up
    TEXT_HIDE,
    TEXT_VALUE  // Set the value of the text frame
};
