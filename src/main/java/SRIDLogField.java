import weblogic.servlet.logging.CustomELFLogger;
import weblogic.servlet.logging.FormatStringBuffer;
import weblogic.servlet.logging.HttpAccountingInfo;

public class SRIDLogField implements CustomELFLogger {
	
	public void logField(HttpAccountingInfo metrics, FormatStringBuffer buff) {
		String srid = (String)metrics.getAttribute("srid");
		if (srid != null) {
            try {
                buff.appendValueOrDash(srid);
            } catch(Exception e) {
				buff.appendValueOrDash("exception");
            }
        } else {
			buff.appendValueOrDash("srid attribute not found");
		}
	}
}