package nl.ru.spherobciviewer;

import java.util.ArrayList;
import java.util.List;

/**
 * Meter.
 * @author Bas Bootsma
 */
public class Meter
{
    /**
     * In radians from 0 to 2 * Math.pi.
     */
    private double direction;
    
    /**
     * From 0 to 100.
     */
    private int power;
    
    private List<MeterListener> listeners;
    
    /**
     * Constructor.
     */
    public Meter()
    {
        this.listeners = new ArrayList<MeterListener>();
        
        this.setDirection(0);
        this.setPower(0);
    }
    
    /**
     * Add listener.
     * @param listener 
     */
    public void addListener(MeterListener listener)
    {
        this.listeners.add(listener);
    }
    
    /**
     * Remove listener.
     * @param listener 
     */
    public void removeListener(MeterListener listener)
    {
        this.listeners.remove(listener);
    }
    
    /**
     * Set direction.
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
        
        for(MeterListener listener : this.listeners)
        {
            listener.onDirectionChanged(this.direction);
        }
    }
    
    /**
     * Return direction.
     * @return 
     */
    public double getDirection()
    {
        return this.direction;
    }
    
    /**
     * Set power.
     * @param power 
     */
    public void setPower(int power)
    {
        this.power = power;
        
        for(MeterListener listener : this.listeners)
        {
            listener.onPowerChanged(this.power);
        }
    }
    
    /**
     * Return the power.
     * @return 
     */
    public int getPower()
    {
        return this.power;
    }
}
