package nl.ru.spherobciviewer.views;

import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.geom.Rectangle2D;
import nl.ru.spherobciviewer.State;
import nl.ru.spherobciviewer.StateListener;
import org.apache.commons.configuration.Configuration;

/**
 * Text panel.
 * @author Bas Bootsma.
 */
public class TextPanel extends BasePanel
{
    /**
     * Constructor.
     * @param configuration
     * @param state 
     */
    public TextPanel(Configuration configuration, State state)
    {
        super(configuration, state);
        
        this.getState().addListener(new StateListener()
        {
            public void onTextChanged(String text)
            {
                repaint();
            }

            public void onDirectionChanged(double direction)
            {
            }

            public void onPowerChanged(int power)
            {
            }
        });
    }
    
    @Override
    public void paintComponent(Graphics g)
    {
        super.paintComponent(g);
        
        Graphics2D g2d = (Graphics2D)g;
        
        // Draw text.
        Font font = new Font(this.getConfiguration().getString("text.font"), Font.PLAIN, this.getConfiguration().getInt("text.size"));
        FontMetrics fontMetrics = this.getFontMetrics(font);

        Rectangle2D textBounds = fontMetrics.getStringBounds(this.getState().getText(), g);

        g2d.setFont(font);
        g2d.setColor(Color.decode(this.getConfiguration().getString("text.color")));
        g2d.drawString(this.getState().getText(),
                      (int)((this.getWidth() - textBounds.getWidth()) / 2),
                      (int)((this.getHeight() - textBounds.getHeight()) / 2));
    }
}
