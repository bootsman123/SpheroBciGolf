package nl.ru.spherobcigolfer;
import java.awt.Color;
import java.util.Observable;


public class WorldModel extends Observable
{
	private int heading;
	private int velocity;
	private int duration; 
	private boolean shouldStartRolling;
	private boolean shouldChangeColor;
	private boolean shouldDisconnect ;
	
	private Color color;
	
	public WorldModel()
        {
            heading = 0; 
            velocity = 100;
            duration = 0;
            shouldStartRolling = false;
            shouldChangeColor = false;
            shouldDisconnect = false; 
        }
        
	public int getHeading()
        {
            return heading;
	}
        
	public int getVelocity()
        {
            return velocity;
	}
        
	public int getDuration()
        {
            return duration; 
	}
        
	public void setDuration(int duration)
        {
            this.duration = duration;
            setChanged();
            notifyObservers();
	}
        
	public void setHeading(int heading)
        {
            this.heading = heading;
            setChanged();
            notifyObservers();
	}
        
	public void setVelocity(int velocity)
        {
            this.velocity = velocity;
            setChanged();
            notifyObservers();
	}
        
	public void executeCommandOnSphero()
        {
            this.shouldStartRolling = true;
            setChanged();
            notifyObservers();
	}
	/**
	 * Indicates whether there is a command that should be executed on the sphero. After this is read by the sphero it is set back to false. 
	 * @return
	 */
	public boolean getShouldExecuteOnSphero(){
		if (!shouldStartRolling){
			return false;
		}
		else{
			shouldStartRolling = false; 
			return true;
		}
		
	}
	public void exitProgram(){
		this.shouldDisconnect = true; 
		setChanged();
		notifyObservers();
	}
	public boolean shouldExitProgram(){
		return this.shouldDisconnect;
	}
	public void setColor(Color c) {
		this.color = c; 
		this.shouldChangeColor = true;
		setChanged();
		notifyObservers();
	}
	public Color getColor() {
		return color;
	}
	public boolean shouldChangeColor() {
		return this.shouldChangeColor;
	}

}
