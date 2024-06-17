import javax.swing.BorderFactory;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import java.awt.GridLayout;

public class HelpDialog extends JPanel {
    JFrame frame;

    public HelpDialog() {
        this.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));
        GridLayout layout = new GridLayout(17, 2);
        this.setLayout(layout);

        this.add(new JLabel("Page Up"));
        this.add(new JLabel("Move one page up"));
        this.add(new JLabel("Page Down"));
        this.add(new JLabel("Move one page down"));

        this.add(new JLabel("Up key"));
        this.add(new JLabel("Move one line up"));
        this.add(new JLabel("Down key"));
        this.add(new JLabel("Move one line down"));

        this.add(new JLabel("Shift + Up key"));
        this.add(new JLabel("Move eight bytes up"));
        this.add(new JLabel("Shift + Down key"));
        this.add(new JLabel("Move eight bytes down"));

        this.add(new JLabel("Ctrl + Up key"));
        this.add(new JLabel("Move two bytes"));
        this.add(new JLabel("Ctrl + Down key"));
        this.add(new JLabel("Move two bytes down"));

        this.add(new JLabel(" "));
        this.add(new JLabel(" "));

        this.add(new JLabel("Left key"));
        this.add(new JLabel("Decrease the width"));
        this.add(new JLabel("Right key"));
        this.add(new JLabel("Increase the width"));

        this.add(new JLabel(" "));
        this.add(new JLabel(" "));

        this.add(new JLabel("-"));
        this.add(new JLabel("Switch to 2 bitplanes mode"));
        this.add(new JLabel("+"));
        this.add(new JLabel("Switch to 4 bitplanes mode"));

        this.add(new JLabel(" "));
        this.add(new JLabel(" "));

        this.add(new JLabel("Ctrl + Page Up"));
        this.add(new JLabel("Load next memory dump"));
        this.add(new JLabel("Ctrl + Page Down"));
        this.add(new JLabel("Load previous memory dump"));
    }

    public void Show() {
        frame = new JFrame("Help");        
        frame.add(this);
        frame.setLocationByPlatform(true);
        frame.pack();
        frame.setVisible(true);
    }
}
