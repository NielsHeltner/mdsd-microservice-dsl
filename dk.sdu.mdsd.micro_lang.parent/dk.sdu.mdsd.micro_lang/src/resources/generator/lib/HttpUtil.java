package lib;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.lang.reflect.MalformedParametersException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import com.sun.net.httpserver.HttpExchange;

public class HttpUtil {
	
	private final String keyValueSeparator = "=";
    private final String parameterSeparator = "&";
	
	/**
     * Converts a String of parameters of the format
     * 'parameterName=parameterValue', where each pair is separated with an '&',
     * to a map where the key is parameter name and the value is the parameter
     * value.
     *
     * @param parameters
     * @return
     */
    public Map<String, String> toMap(String parameters) {
    	Map<String, String> result = new HashMap<>();
        if (!parameters.isEmpty()) {
            String[] parameterList = parameters.split(parameterSeparator);
            for (String parameter : parameterList) {
                String[] keyAndValue = parameter.split(keyValueSeparator);
                if (keyAndValue.length != 2) {
                	throw new MalformedParametersException();
                }
                result.put(keyAndValue[0], keyAndValue[1]);
            }
        }
        return result;
    }
	
	public String getBody(InputStream bodyStream) {
		StringBuilder result = new StringBuilder();
		try {
			BufferedReader reader = new BufferedReader(new InputStreamReader(bodyStream));
			String input;
			while ((input = reader.readLine()) != null) {
				result.append(input);
			}
		}
		catch (IOException e) {
			e.printStackTrace();
		}
		return result.toString();
	}
	
	public void sendResponse(HttpExchange exchange, int code, Object responseObj) {
		try {
			String response = String.valueOf(responseObj);
			System.out.println(response);
			exchange.sendResponseHeaders(code, response.length());
			OutputStream os = exchange.getResponseBody();
			os.write(response.getBytes());
			os.close();
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public void sendResponse(HttpExchange exchange, int code) {
		sendResponse(exchange, code, "");
	}
	
	public String sendRequest(String urlString, String method, String body) throws IOException {
		URL url = new URL(urlString);
		HttpURLConnection con = (HttpURLConnection) url.openConnection();
		con.setRequestMethod(method);
		if (!body.isEmpty()) {
			con.setDoOutput(true);
			DataOutputStream out = new DataOutputStream(con.getOutputStream());
			out.writeBytes(body);
			out.flush();
			out.close();
		}
		con.disconnect();
		return getBody(con.getInputStream());
	}

}
