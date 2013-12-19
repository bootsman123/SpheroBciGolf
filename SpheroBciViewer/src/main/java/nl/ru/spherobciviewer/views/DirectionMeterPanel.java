package nl.ru.spherobciviewer.views;

import java.awt.Graphics;
import nl.ru.spherobciviewer.State;
import org.apache.commons.configuration.Configuration;

/**
 * Direction meter panel.
 * @author Bas Bootsma
 */
public class DirectionMeterPanel extends MeterPanel
{
    /**
     * Constructor.
     * @param configuration
     * @param state 
     */
    public DirectionMeterPanel(Configuration configuration, State state)
    {
        super(configuration, state);
    }

    @Override
    protected void paintArrow(Graphics g)
    {
        this.paintArrow(g, this.getState().getDirection());
    }
}
