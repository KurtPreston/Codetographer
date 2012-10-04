package codetographer.views.widgets;

import java.io.File;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.StatusTextEvent;
import org.eclipse.swt.browser.StatusTextListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;

public class EcumeneBrowser implements SelectionListener, StatusTextListener
{
	private Composite parent;

	private Browser browser;

	private SWTError error;

	private Button button;

	public EcumeneBrowser(Composite parent, boolean top)
	{
		this.parent = parent;
		try
		{
			Composite c = new Composite(parent, SWT.NONE);
			c.setLayout(new FillLayout());
			/*
			button = new Button(c, SWT.NONE);
			button.setText("GO!");
			button.addSelectionListener(this);*/
			browser = new Browser(c, SWT.BORDER);
			browser.addStatusTextListener(this);
			File f = new File("webroot/Ecumene.html");
			System.out.println(f.getAbsolutePath());
			browser.setUrl(f.getAbsolutePath());
		}
		catch (SWTError e)
		{
			error = e;
			/* Browser widget could not be instantiated */
			parent.setLayout(new FillLayout());
			Label label = new Label(parent, SWT.CENTER | SWT.WRAP);
			label.setText("Couldnt create browser");
			parent.layout(true);
			return;
		}
	}

	private void dispose()
	{
		// TODO Auto-generated method stub

	}

	public void widgetSelected(SelectionEvent e)
	{
		sendStringToFlash("helloFromSWT", "This is from SWT");
	}

	public void sendStringToFlash(String methodName, String message)
	{
		browser.execute("flashProxy.call('" + methodName + "', '" + message
				+ "');");
	}

	public void sendResponse(String response)
	{
		browser.execute("response='" + response + "';");
	}
	
	public void widgetDefaultSelected(SelectionEvent e)
	{
		// TODO Auto-generated method stub

	}

	public void changed(StatusTextEvent event)
	{
		if(event.text.length() < 2) return;
		
		char command = event.text.charAt(0);
		String text = event.text.substring(1);
		
		if (command == '#')
		{
			button.setText("Flash says: " + text);
			sendResponse("SWT can hear you!");
		}
		else if(command == '!')
		{
			button.setText("Flash responds: " + text);
		}
	}

	public static void main(String[] args)
	{
		Display display = new Display();
		Shell shell = new Shell(display);
		shell.setLayout(new FillLayout());
		shell.setText("FlashBrowser");
		EcumeneBrowser app = new EcumeneBrowser(shell, true);
		shell.open();
		while (!shell.isDisposed())
		{
			if (!display.readAndDispatch())
				display.sleep();
		}
		app.dispose();
		display.dispose();
	}
}
