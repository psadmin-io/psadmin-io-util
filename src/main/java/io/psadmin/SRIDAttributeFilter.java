package io.psadmin;

import java.io.IOException;
import java.util.Properties;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import psft.pt8.util.PSHttpUtil;
import psft.pt8.adapter.PSHttpServletRequest;

public class SRIDAttributeFilter implements Filter {

	private int logFence;
	
	@Override
	public void init(FilterConfig cfg) throws ServletException {	
		logFence = Integer.parseInt(cfg.getInitParameter("logFence"));
		log("Filter enabled.", 0);
	}

	@Override
	public void destroy() {
		logFence = 0;
	}
	
	@Override
	public void doFilter(ServletRequest servReq, ServletResponse servRes, FilterChain chain) throws IOException, ServletException {
		String srid = new String();
		HttpServletRequest req = (HttpServletRequest)servReq;
		HttpServletResponse res = (HttpServletResponse)servRes;
	
		// get session
		HttpSession localHttpSession = req.getSession(false);
		if (localHttpSession == null) {
			localHttpSession = req.getSession(true);
		}	
		
		// get properties from session
	    PSHttpServletRequest localPSHttpServletRequest = new PSHttpServletRequest(req);	
		Object sessionPropName = PSHttpUtil.getSessionPropName(localPSHttpServletRequest, "portalSessionProps");
	    Properties prop = (Properties)localHttpSession.getAttribute((String)sessionPropName);
		
		// get srid from properties
		if (prop != null) {	
			srid = prop.getProperty("SRID"));
		} else {
			log("props not found",1);
		}
		
		// set data to Request attributes
		req.setAttribute("srid", srid);		
		log("Setting attribute srid: " + srid,1);
		
		// continue chain towards servlet
		chain.doFilter(req,res);		
	}	
	
	private void log(String print, Integer level ) {
		if (logFence >= level) {
			System.out.print("SRIDAttributeFilter: ");
			System.out.println(print);
		}
	}	
}