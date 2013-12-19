package nl.ru.spherobciviewer.views;

import java.awt.Graphics;
import nl.ru.spherobciviewer.State;
import org.apache.commons.configuration.Configuration;

/**
 * Power meter panel.
 * @author Bas Bootsma
 */
public class PowerMeterPanel extends MeterPanel
{
    /**
     * Constructor.
     * @param configuration
     * @param state 
     */
    public PowerMeterPanel(Configuration configuration, State state)
    {
        super(configuration, state);
    }

    @Override
    protected void paintArrow(Graphics g)
    {
        double angleMin = Math.toRadians(this.getConfiguration().getInt("frame.angle.start"));
        double angleTotal = (Math.toRadians(this.getConfiguration().getInt("frame.angle.end")) - Math.toRadians(this.getConfiguration().getInt("frame.angle.start")));
        
        int power = this.getState().getPower();
        double direction = (double)power * angleTotal - angleMin;
        
        this.paintArrow(g, direction);
    }
}
