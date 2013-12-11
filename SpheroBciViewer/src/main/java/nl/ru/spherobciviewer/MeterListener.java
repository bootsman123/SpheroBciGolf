package nl.ru.spherobciviewer;

/**
 * Meter listener.
 * @author Bas Bootsma
 */
public interface MeterListener
{
    public void onDirectionChanged(double direction);
    public void onPowerChanged(int power);
}
