import java.awt.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.awt.image.BufferedImage;
import org.json.simple.parser.JSONParser;
import org.json.simple.JSONObject;
import org.json.simple.JSONArray;

import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;

import java.io.File;
import java.io.FileReader;
import java.awt.event.*;

public class MemView extends JPanel implements KeyListener
{
    class Game {
        int[] paletteST;
        int offset;
        int width;
    }

    class Position {
        String name;
        int offset;
        int width;

        @Override
        public String toString() {
            return name;
        }

        public Position(String name, int offset, int width) {
            this.name = name;
            this.offset = offset;
            this.width = width;
        }
    }

    byte[] data;
    Color[] palette = new Color[16];
    int offset = 0x078000;
    int nb_bitplanes = 4;
    JFrame frame;
    HelpDialog helpDialog;
    JLabel filenameLabel;
    JLabel vizLabel;
    JLabel bitmapLabel;
    JLabel addressLabel;
    JLabel widthLabel;
    JLabel bitplanesLabel;
    JPanel bookmarksContainer;
    int width;
    int height;
    String filename;
    File file;
    String path;
    Position[] positions;
    JPanel controlPanel;
    BinaryVisualizer binViz;
    ExportDialog dialog;

    int getIntensity(int st) {
        return st * (255/7);
    }

    Color getColor(int rST, int gST, int bST) {
        return new Color(getIntensity(rST), getIntensity(gST), getIntensity(bST));
    }


    public boolean ReadJson() throws Exception {
        Matcher matcher = ParseFilename();
        if (matcher == null) return false;
        String filename = "";

        try {
            filename = matcher.group(1).toLowerCase() + ".json";

            JSONParser parser = new JSONParser();
            Object obj = parser.parse(new FileReader(filename));
            JSONObject root = (JSONObject)obj;
            JSONArray paletteST = (JSONArray)root.get("paletteST");
            for (int i=0; i<paletteST.size(); i++) {
                int color = Integer.decode((String)paletteST.get(i));
                int rST = color >> 8;
                int gST = (color >> 4) & 0xF;
                int bST = color & 0xF;
                palette[i] = getColor(rST, gST, bST);
            }
            JSONArray positionsJson = (JSONArray)root.get("positions");
            positions = new Position[positionsJson.size()];

            for (int i=0; i<positionsJson.size(); i++) {
                JSONObject position = (JSONObject)positionsJson.get(i);
                String name = (String)position.get("name");
                int offset = Integer.decode((String)position.get("offset"));
                int width = (int)(long)position.get("width");
                positions[i] = new Position(name, offset, width);
            }
            if (positions.length > 0) {
                offset = positions[0].offset;
                width = positions[0].width;
            }
            return true;
        } catch (Exception e) {
            System.out.printf("Error reading %s: %s\n", filename, e.getMessage());
            return false;
        }
    }    

    private void LoadData(File file) throws Exception {
        this.width = 320;
        this.height = 512;
        this.nb_bitplanes = 4;
        this.offset = 0x050000;
        this.filename = file.getName().toLowerCase();
        this.path = file.getPath();
        this.dialog = new ExportDialog(this);
        data = Files.readAllBytes(file.toPath());
        positions = new Position[] {};

        if (!ReadJson()) {
            int[] paletteST = new int[] { 0x000, 0x700, 0x070, 0x007, 0x770, 0x707, 0x077, 0x400, 0x040, 0x004, 0x440, 0x404, 0x044, 0x444, 0x744, 0x777 };
            for (int i=0; i<16; i++) {
                int rST = paletteST[i] >> 8;
                int gST = (paletteST[i] >> 4) & 0xF;
                int bST = paletteST[i] & 0xF;
                palette[i] = getColor(rST, gST, bST);
            }    
        }

        updateBookmarks();
        binViz = new BinaryVisualizer(data, height);
        // Round down to the highest power of 2
        int nbBits = 31 - Integer.numberOfLeadingZeros(data.length);
        int roundedDown = (1 << nbBits);
        int step = roundedDown / 64 / 64 / 16; // There are 16 64x64 tiles. step = how many bytes per pixel?
        Hilbert hilbert = new Hilbert(binViz, step, 1);
        for (int i=0; i<16; i++) {
            hilbert.curveD(6);
            hilbert.y += 1;
//            System.out.printf("Offset: %d\n", hilbert.d);
        }
//        binViz.Backup();
        ImageIcon bitmap = new ImageIcon( binViz.bi );
        vizLabel.setIcon(bitmap);
    }

    private void updateBookmarks() {
        bookmarksContainer.removeAll();
        bookmarksContainer.setLayout(new GridLayout(positions.length, 1));
        for (Position pos : positions) {
            JButton button = new JButton(pos.name);
            button.addKeyListener(this);
            button.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    width = pos.width;
                    offset = pos.offset;
                    try { Refresh();
                        frame.pack();
                        frame.setVisible( true );
                    } catch (Exception ex) {
                        System.out.println("Error in Update(): " + ex.getMessage());
                        for (StackTraceElement ste : ex.getStackTrace()) {
                            System.out.println(ste);
                        }
                    }
                }
            });
            bookmarksContainer.add(button);
        }

    }

    public Matcher ParseFilename() {
        Pattern pattern = Pattern.compile("([a-z]+)([0-9]*)\\.(.+)", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(filename);
        boolean matchFound = matcher.find();
        if (matchFound) return matcher;
        return null;
    }

    public void LoadNext(int inc) {
        Matcher matcher = ParseFilename();
        if (matcher == null) {
            return;
        }
        String dir = path.substring(0, path.length() - filename.length());
        int imageNb = Integer.parseInt(matcher.group(2));
        String newFilename = String.format("%s%d.%s", matcher.group(1), imageNb+inc, matcher.group(3));
        String newPath = dir + newFilename;
//        System.out.printf("Loading %s (%s)\n", newPath, newFilename);
        try {
            data = Files.readAllBytes(Paths.get(newPath));
            path = newPath;
            filename = newFilename;
            filenameLabel.setText(filename);
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
            System.out.println(path);
        }
    }

    public JLabel GetAddress() {
        JLabel label = new JLabel();
        label.setText(String.format("0x%06X", offset));
        label.setFont(new Font("Courier New", Font.BOLD, 16));
        return label;
    }

    public void Refresh() throws Exception
    {
        filenameLabel.setText(filename);
        addressLabel.setText(String.format("0x%06X", offset));
        widthLabel.setText(String.format("Width: %d px", width));

        binViz.DrawFrame(offset, offset + width*height/2);
        vizLabel.setIcon(new ImageIcon(binViz.bi));

        BufferedImage bi = getImageFromMemory(offset, height, 0, true);
        ImageIcon bitmap = new ImageIcon(bi);
        bitmap.getImage().flush();
        bitmapLabel.setIcon(bitmap);
    }

    BufferedImage getImageFromMemory(int offset, int height, int end, boolean largePixels) {
        int totalWidth = width;
        int colBytes = 1;
        if (width == 16) {
            totalWidth = (320 / width) * width;
            colBytes = width * height / 2;
            if (nb_bitplanes == 2) colBytes /= 2;
        }

        if (height == 0) {
            height = (end - offset) / (totalWidth / 2);
            if (nb_bitplanes == 2) height *= 2;
        }

        BufferedImage bi = new BufferedImage(largePixels ? totalWidth * 2 : totalWidth, largePixels ? height * 2 : height, BufferedImage.TYPE_INT_RGB);

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < totalWidth; x+= 16)
            {
                int mask = 32768;

                for (int pixel = 0; pixel < 16; pixel++) {
                    int colorIdx = 0;
                    int colorWeight = 1;
                    for (int bitplane=0; bitplane<nb_bitplanes; bitplane++) {
                        int colOffset = x % width;
                        if (nb_bitplanes == 2) colOffset /= 2;
                        int col = x / width;
                        int y_offset = nb_bitplanes == 2 ? y*width/4 : y*width/2;
                        int val1 = data[offset + y_offset + colOffset/2 + col*colBytes + bitplane*2];
                        int val2 = data[offset + y_offset + colOffset/2 + col*colBytes + bitplane*2 + 1];
                        val1 = val1 < 0 ? val1 + 256 : val1;
                        val2 = val2 < 0 ? val2 + 256 : val2;
                        int value = val1 * 256 + val2;
                        if ((value & mask) != 0) {
                            colorIdx += colorWeight;
                        }
                        colorWeight *= 2;
                    }

                    mask /= 2;
                    Color color = palette[colorIdx];
                    int colorValue = color.getRGB();
                    if (largePixels) {
                        bi.setRGB((x+pixel)*2, y*2, colorValue);
                        bi.setRGB((x+pixel)*2+1, y*2, colorValue);
                        bi.setRGB((x+pixel)*2, y*2+1, colorValue);
                        bi.setRGB((x+pixel)*2+1, y*2+1, colorValue);                        
                    } else {
                        bi.setRGB((x+pixel), y, colorValue);
                    }
                }
            }
        }

        return bi;
    }

    private static File openFile() {
        final JFileChooser fc = new JFileChooser("..\\..\\");
        fc.setFileFilter(new FileNameExtensionFilter("Memory Dump", "bin"));
        fc.setPreferredSize(new Dimension(800, 400));
        int returnVal = fc.showOpenDialog(null);
        if (returnVal != 0) return null;
        return fc.getSelectedFile();
    }

    @Override
    public void keyTyped(KeyEvent e) {
        if (e.getKeyCode() == KeyEvent.VK_UP) {
            offset -= 32000;
            try {
                Refresh();
            } catch (Exception ex) {

            }
        }
    }

    @Override
    public void keyPressed(KeyEvent e) {
        int keyCode = e.getKeyCode();
        // Jump one screen up
        if (keyCode == KeyEvent.VK_PAGE_UP) {
            if (e.isControlDown()) {
                LoadNext(1);
            } else {
                int jump = width*height/2;
                if (nb_bitplanes == 2) jump /= 2;
                offset = Math.max(0, offset - jump);
            }
        // Jump one screen down
        } else if (keyCode == KeyEvent.VK_PAGE_DOWN) {
            if (e.isControlDown()) {
                LoadNext(-1);
            } else {
                int jump = width*height/2;
                if (nb_bitplanes == 2) jump /= 2;
                offset = Math.min(offset + jump, data.length - jump);
            }
        // Jump one line up, 16 bytes or 2 bytes up
        } else if (keyCode == KeyEvent.VK_UP) {
            int jump = e.isShiftDown() ? 8 : (e.isControlDown() ? 2 : width/2);
            offset = Math.max(0, offset - jump);
        // Jump one line up, 16 bytes or 2 bytes down
        } else if (keyCode == KeyEvent.VK_DOWN) {
            int jump = e.isShiftDown() ? 8 : (e.isControlDown() ? 2 : width/2);
            offset = Math.min(offset + jump, data.length - jump);
        } else if (keyCode == KeyEvent.VK_LEFT) {
            if (e.isShiftDown()) {
                offset -= 2;
            }
            else width = Math.max(16, width - 16);
        } else if (keyCode == KeyEvent.VK_RIGHT) {
            if (e.isShiftDown()) {
                offset += 2;
            }
            else width = width + 16;
        } else if (keyCode == KeyEvent.VK_MINUS || keyCode == 109) {
            bitplanesLabel.setText("2 bitplanes mode");
            nb_bitplanes = 2;
        } else if (keyCode == KeyEvent.VK_PLUS || keyCode == 107 || keyCode == 61) {
            bitplanesLabel.setText(" ");
            nb_bitplanes = 4;
        } else {
//            System.out.printf("Unknown code: %d\n", keyCode);
            return;
        }

        try {
            Refresh();
            frame.pack();
            frame.setVisible( true );
        } catch (Exception ex) {

        }
    }

    @Override
    public void keyReleased(KeyEvent e) {
    }

    ////////////////////////////////////////////////////////////////////////////////////////
    // CREATE MEMVIEW WINDOW
    ////////////////////////////////////////////////////////////////////////////////////////

    public MemView(JFrame frame, File file) throws Exception {
        this.frame = frame;
        SetComponents();

        LoadData(file);
    }

    public void SetComponents() {
        removeAll();
        controlPanel = new JPanel();
        controlPanel.setLayout(new BoxLayout(controlPanel, BoxLayout.PAGE_AXIS));
        JPanel infoPanel = new JPanel(new GridLayout(8, 1));
        controlPanel.add(infoPanel);
        JPanel filePanel = new JPanel();
        filePanel.setLayout(new BoxLayout(filePanel, BoxLayout.LINE_AXIS));
        controlPanel.add(filePanel);
        filenameLabel = new JLabel(filename);
        filePanel.add(filenameLabel);
        filePanel.add(new JLabel(" "));

        Icon icon = UIManager.getIcon("Tree.openIcon");
        JButton loadButton = new JButton(icon);
        loadButton.setMargin(new Insets(0, 0, 0, 0));
        loadButton.addKeyListener(this);
        loadButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                File file = openFile();
                if (file == null) return;
                try {
                    LoadData(file);
                    Refresh();
                    frame.pack();
                } catch (Exception ex) {
                    System.out.printf("Error: %s\n", ex.getMessage());
                }
            }
            
        });
        filePanel.add(loadButton);
        infoPanel.add(filePanel);

        JPanel addressPanel = new JPanel();
        addressPanel.setLayout(new BoxLayout(addressPanel, BoxLayout.LINE_AXIS));
        addressPanel.add(new JLabel("Address:"));
        addressLabel = GetAddress();
        addressPanel.add(addressLabel);
        infoPanel.add(addressPanel);

        widthLabel = new JLabel(String.format("Width: %d px", width));
        infoPanel.add(widthLabel);

        JButton exportButton = new JButton("Export as PNG");
        exportButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                dialog.Show(offset);
            }
        });
        exportButton.addKeyListener(this);
        infoPanel.add(exportButton);

        bitplanesLabel = new JLabel(" ");
        infoPanel.add(bitplanesLabel);
        infoPanel.add(new JLabel(" "));

        JPanel positionsContainer = new JPanel();
        positionsContainer.setBorder(BorderFactory.createTitledBorder("Bookmarks"));
        BoxLayout positionsLayout = new BoxLayout(positionsContainer, BoxLayout.Y_AXIS);
        positionsContainer.setLayout(positionsLayout);
        controlPanel.add(positionsContainer);
        GridLayout bookmarksLayout = new GridLayout(1, 1);
        bookmarksContainer = new JPanel();
        bookmarksContainer.setLayout(bookmarksLayout);
        bookmarksLayout.minimumLayoutSize(bookmarksContainer);
        positionsContainer.add(bookmarksContainer);

        helpDialog = new HelpDialog();
        icon = UIManager.getIcon("OptionPane.informationIcon");
        JButton helpButton = new JButton(icon);
        helpButton.setMargin(new Insets(0, 0, 0, 0));
        helpButton.addKeyListener(this);
        helpButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                helpDialog.Show();
                helpDialog.setVisible(true);
            }
        });
        controlPanel.add(new JLabel(" "));
        controlPanel.add(new JLabel(" "));
        controlPanel.add(helpButton);
//        updateBookmarks();

/*        for (Position pos : positions) {
            JButton button = new JButton(pos.name);
            button.addKeyListener(this);
            button.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    width = pos.width;
                    offset = pos.offset;
                    try { Update();
                        frame.pack();
                        frame.setVisible( true );
                    } catch (Exception ex) {
                        System.out.println("Error in Update(): " + ex.getMessage());
                        for (StackTraceElement ste : ex.getStackTrace()) {
                            System.out.println(ste);
                        }
                    }
                }
            });
            bookmarksContainer.add(button);
        }
*/
        add(controlPanel);
/*
        binViz = new BinaryVisualizer(data, height);
        // Round down to the highest power of 2
        int nbBits = 31 - Integer.numberOfLeadingZeros(data.length);
        int roundedDown = (1 << nbBits);
        int step = roundedDown / 64 / 64 / 16; // There are 16 64x64 tiles. step = how many bytes per pixel?
        Hilbert hilbert = new Hilbert(binViz, step, 1);
        for (int i=0; i<16; i++) {
            hilbert.curveD(6);
            hilbert.y += 1;
//            System.out.printf("Offset: %d\n", hilbert.d);
        }
        binViz.Backup();
        ImageIcon bitmap = new ImageIcon( binViz.bi );
        bitmapLabel = new JLabel(bitmap);
        add(bitmapLabel);*/

        ImageIcon vizmap = new ImageIcon();
        vizLabel = new JLabel(vizmap);
        add(vizLabel);

        ImageIcon bitmap = new ImageIcon();
        bitmapLabel = new JLabel(bitmap);
        add(bitmapLabel);
    }

    ////////////////////////////////////////////////////////////////////////////////////////
    // AT STARTUP
    ////////////////////////////////////////////////////////////////////////////////////////

    private static void createAndShowGUI() throws Exception
    {
        File file = openFile();
        if (file == null) return;
        
        JFrame frame = new JFrame("ST MemView");
        MemView memView = new MemView(frame, file);
        memView.Refresh();

        JScrollPane scrollPane = new JScrollPane(memView);
        scrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_NEVER);
        scrollPane.setBounds(50, 30, 320, 1000);

        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.add(scrollPane);
        frame.setLocationByPlatform( true );
        frame.pack();
        frame.setVisible( true );
        frame.addKeyListener(memView);
    }

    public static void main(String[] args)
    {
        EventQueue.invokeLater(new Runnable()
        {
            public void run()
            {
                try {
                    createAndShowGUI();
                } catch (Exception e) {
                    System.out.println(e.getMessage());
                    for (StackTraceElement ste : e.getStackTrace()) {
                        System.out.println(ste);
                    }
                }
            }
        });
    }
}
