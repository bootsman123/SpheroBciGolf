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
        	if (event.getType().equals("golfer.shoot"))
        	{
	        	String message = event.getValue().toString();
	        	System.out.println("Received: " + message);
	        	try{
		        	String[] parts = message.split(",");
		        	int heading = Integer.parseInt(parts[0]);
		        	int velocity = Integer.parseInt(parts[1]);
		        	int duration = Integer.parseInt(parts[2]);
		        	boolean shouldStart = Boolean.parseBoolean(parts[3]);
		        	
		        	model.setHeading(heading);
		        	model.setVelocity(velocity);
		        	model.setDuration(duration);
		        	if(shouldStart)
		        	{
		        		model.executeCommandOnSphero();
		        	}
	        	}
	        	catch(Exception e)
	        	{
	        		e.printStackTrace();
	        	}
        	}
        }
    }
}
