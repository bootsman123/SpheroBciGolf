package nl.ru.spherobciviewer;

import java.util.ArrayList;
import java.util.List;

/**
 * State.
 * @author Bas Bootsma
 */
public class State
{
    /**
     * Text to be displayed.
     */
    private String text;
    
    /**
     * In radians from 0 to 2 * Math.pi.
     */
    private double direction;
    
    /**
     * From 0 to 100.
     */
    private int power;
    
    private List<StateListener> listeners;
    
    /**
     * Constructor.
     */
    public State()
    {
        this.listeners = new ArrayList<StateListener>();
        
        this.setDirection(0);
        this.setPower(0);
    }
    
    /**
     * Add listener.
     * @param listener 
     */
    public void addListener(StateListener listener)
    {
        this.listeners.add(listener);
    }
    
    /**
     * Remove listener.
     * @param listener 
     */
    public void removeListener(StateListener listener)
    {
        this.listeners.remove(listener);
    }
    
    /**
     * Sets the text.
     * @param text 
     */
    public void setText(String text)
    {
        this.text = text;
        
        for(StateListener listener : this.listeners)
        {
            listener.onTextChanged(this.text);
        }
    }
    
    /**
     * Returns the text.
     * @return 
     */
    public String getText()
    {
        return this.text;
    }
    
    /**
     * Sets the direction.
     * @param direction 
     */
    public void setDirection(double direction)
    {
        this.direction = -direction;
        
        while(this.direction < 0)
        {
            this.direction += 2 * Math.PI;
        }
        
        while(this.direction > 2 * Math.PI)
        {
            this.direction -= 2 * Math.PI;
        }
        
        for(StateListener listener : this.listeners)
        {
            listener.onDirectionChanged(this.direction);
        }
    }
    
    /**
     * Returns the direction.
     * @return 
     */
    public double getDirection()
    {
        return this.direction;
    }
    
    /**
     * Sets the power.
     * @param power 
     */
    public void setPower(int power)
    {
        this.power = power;
        
        for(StateListener listener : this.listeners)
        {
            listener.onPowerChanged(this.power);
        }
    }
    
    /**
     * Returns the power.
     * @return 
     */
    public int getPower()
    {
        return this.power;
    }
}
