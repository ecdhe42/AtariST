all: STMemViewer.jar

STMemViewer.jar: MemView.class
	copy json-simple-1.1.1.jar STMemViewer.jar
	jar /U STMemViewer.jar *.class
	jar /U STMemViewer.jar -C . META-INF/MANIFEST.MF

MemView.class: MemView.java Hilbert.java BinaryVisualizer.java ExportDialog.java HelpDialog.java
	javac -cp .;json-simple-1.1.1.jar MemView.java

#run: STMemViewer.jar
#	java STMemViewer.jar

run: MemView.class
	java -cp .;json-simple-1.1.1.jar MemView
