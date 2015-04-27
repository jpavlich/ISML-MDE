package co.edu.javeriana.mwe.utils;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.eclipse.emf.mwe.core.WorkflowContext;
import org.eclipse.emf.mwe.core.issues.Issues;
import org.eclipse.emf.mwe.core.lib.AbstractWorkflowComponent2;
import org.eclipse.emf.mwe.core.monitor.ProgressMonitor;

public class CreateFolder extends AbstractWorkflowComponent2 {
	private String folderName = null;
	
	private static final String COMPONENT_NAME = "Directory Creator";
	private static final Log LOG = LogFactory.getLog(CreateFolder.class);
	

	public void setFolderName(String sourceFile) {
		this.folderName = sourceFile;
	}

	public void checkConfigurationInternal(Issues issues) {
		super.checkConfigurationInternal(issues);
		if (folderName == null) {
			issues.addError("No folder set.");
		}
	}

	@Override
	public String getLogMessage() {
		return "Creating folder " + folderName;
	}

	@Override
	protected void invokeInternal(WorkflowContext ctx, ProgressMonitor monitor,
			Issues issues) {
		File folder = new File(folderName);
		folder.mkdirs();
	}
	
	@Override
	public String getComponentName() {
		return COMPONENT_NAME;
	}
}