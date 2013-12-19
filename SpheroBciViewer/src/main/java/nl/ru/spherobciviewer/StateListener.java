package nl.ru.spherobciviewer;

/**
 * State listener.
 * @author Bas Bootsma
 */
public interface StateListener
{
    public void onTextChanged(String text);
    public void onDirectionChanged(double direction);
    public void onPowerChanged(double power);
}
