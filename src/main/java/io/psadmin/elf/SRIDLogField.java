package io.psadmin.elf;

import weblogic.servlet.logging.CustomELFLogger;
import weblogic.servlet.logging.FormatStringBuffer;
import weblogic.servlet.logging.HttpAccountingInfo;

public class SRIDLogField implements CustomELFLogger {
	
	public void logField(HttpAccountingInfo metrics, FormatStringBuffer buff) {
		String srid = (String)metrics.getAttribute("srid");
		buff.appendValueOrDash(srid);
	}
}