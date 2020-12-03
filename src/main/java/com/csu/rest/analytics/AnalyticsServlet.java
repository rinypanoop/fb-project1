package com.csu.rest.analytics;

import com.google.appengine.api.urlfetch.URLFetchService;
import com.google.appengine.api.urlfetch.URLFetchServiceFactory;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.http.client.utils.URIBuilder;

@SuppressWarnings("serial")
// With @WebServlet annotation the webapp/WEB-INF/web.xml is no longer required.
@WebServlet(
    name = "analytics",
    description = "Analytics: Send Analytics Event to Google Analytics",
    urlPatterns = "/analytics"
)
public class AnalyticsServlet extends HttpServlet {

  @Override
  public void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws IOException, ServletException {
    String trackingId = "UA-184503196-2";
    URIBuilder builder = new URIBuilder();
    builder
        .setScheme("http")
        .setHost("www.google-analytics.com")
        .setPath("/collect")
        .addParameter("v", "1") // API Version.
        .addParameter("tid", trackingId) // Tracking ID / Property ID.
        // Anonymous Client Identifier. Ideally, this should be a UUID that
        // is associated with particular user, device, or browser instance.
        .addParameter("cid", "555")
        .addParameter("t", "event") // Event hit type.
        .addParameter("ec", "fb server side tracking") // Event category.
        .addParameter("ea", "test action"); // Event action.
    URI uri = null;
    try {
      uri = builder.build();
    } catch (URISyntaxException e) {
      throw new ServletException("Problem building URI", e);
    }
    URLFetchService fetcher = URLFetchServiceFactory.getURLFetchService();
    URL url = uri.toURL();
    fetcher.fetch(url);
    resp.getWriter().println("Event tracked.");
  }
}