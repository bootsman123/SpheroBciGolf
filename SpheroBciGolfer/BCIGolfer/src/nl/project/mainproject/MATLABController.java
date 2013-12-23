package nl.project.mainproject;

import java.io.IOException;

import nl.fcdonders.fieldtrip.BufferEvent;
import nl.ru.spherobciviewer.Buffer;
import nl.ru.spherobciviewer.BufferEventListener;

/**
 *
 * @author bootsman
 */
public class MATLABController 
{
    
    public static final String DIRECTION_METER_PANEL = "direction-meter-panel";
    public static final String POWER_METER_PANEL = "power-meter-panel";
    private WorldModel model;
    public static final double MAXIMUM_DURATION = 5000.0;
    public static final double MINIMUM_DURATION = 500.0;


    private Buffer buffer;
    
    
    /**
     * Constructor.
     */
    public MATLABController(WorldModel model)
    {
    	this.model = model;
    	System.out.println("Started MATLAB controller");
        try
        {
            this.buffer = new Buffer("localhost", 1972);
            this.buffer.addEventListener(new ApplicationBufferEventListener());
            this.buffer.execute();
        }
        catch(IOException e)
        {
            System.out.println("Unable to connect to the buffer: " + e.getMessage());
        }
    }

    private class ApplicationBufferEventListener implements BufferEventListener
    {
        public void onReceived(BufferEvent event)
        {
        	if (event.getType().equals("GOLFER_SHOOT"))
        	{
        		model.executeCommandOnSphero();
        	}
        	else if (event.getType().equals("GOLFER_POWER_VALUE;")) // Between 0 and 1
        	{
        		String message = event.getValue().toString();
        		double receivedDurationOnScale = Double.parseDouble(message);
	        	int duration = (int) (MINIMUM_DURATION + receivedDurationOnScale * 1.0/(MAXIMUM_DURATION - MINIMUM_DURATION));
	        	model.setDuration(duration);
        	}
        	else if (event.getType().equals("GOLFER_DIRECTION_VALUE;"))  // In degrees
        	{
        		String message = event.getValue().toString();
        		int directionValue = Integer.parseInt(message);
        		model.setHeading(directionValue);
        	}
        }
    }
}
